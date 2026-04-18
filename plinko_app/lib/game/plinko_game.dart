import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/material.dart' show Color;
import '../config/plinko_config.dart';
import 'board.dart';
import 'ball.dart';

/// Jeu principal Plinko — Balleck Team.
///
/// Refonte build 40 : mode casino multiplicateur.
///   - 17 cases avec multiplicateurs positionnels (x0.1 au centre → x100 aux bords)
///   - Chaque tap = 1€ dépensé → une nouvelle bille lancée (multi-ball)
///   - Atterrissage → balance créditée de (multiplicateur × 1€)
///   - Plus d'overlay récompense : la balance affichée en coin d'écran suffit
class PlinkoGame extends FlameGame with TapCallbacks {
  /// Mise par défaut pour une bille (en €). Overridable via betAmountNotifier.
  static const double kDefaultBet = 1.0;

  /// Délai entre deux lancers en mode multi-bille (ms).
  static const int _stagggerMs = 120;

  /// Durée pendant laquelle la bille reste visible après atterrissage
  /// avant d'être retirée du monde (permet de voir la case d'arrivée).
  static const double _lingerAfterLand = 0.8; // secondes

  /// Nombre de sous-pas physiques par frame — empêche le tunneling.
  static const int _physicsSubSteps = 4;

  // ── État du jeu ──────────────────────────────────────────────────────────

  /// Balance en € — démarre à 50€. Source de vérité du score.
  final ValueNotifier<double> balanceNotifier = ValueNotifier<double>(50.0);

  /// Mise courante par bille — pilotée par la rangée de boutons (1/2/5/10€).
  final ValueNotifier<double> betAmountNotifier =
      ValueNotifier<double>(kDefaultBet);

  /// Nombre de billes en vol (vol + linger). 0 = on peut relancer.
  final ValueNotifier<int> ballsInFlightNotifier = ValueNotifier<int>(0);

  /// Stream des gains crédités — 1 event par bille atterrissant dans une case.
  /// Écouté par l'UI pour afficher l'animation "+X€" flottante.
  final StreamController<double> gainEvents =
      StreamController<double>.broadcast();

  /// Billes actuellement en vol ou en phase de linger post-atterrissage.
  final List<Ball> _activeBalls = [];

  /// Billes dont l'atterrissage a déjà été crédité (évite double-compte).
  final Set<Ball> _creditedBalls = {};

  /// Temps écoulé depuis l'atterrissage (pour le linger avant despawn).
  final Map<Ball, double> _landedLinger = {};

  /// Positions des picots — pour les collisions physiques.
  final List<Vector2> _pegPositions = [];

  final _rng = Random();

  @override
  Color backgroundColor() => const Color(0xFF08040f);

  // ── Chargement initial ───────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    assert(PlinkoConfig.ballFitsThrough,
        'GX (${PlinkoConfig.pegGX}) doit être > 2×PEG_RADIUS + 2×BALL_RADIUS '
        '(${2 * PlinkoConfig.pegRadius + 2 * PlinkoConfig.ballRadius})');

    camera.viewfinder.anchor = Anchor.center;
    _applyResponsiveCamera(size);

    _buildPegPositions();

    await world.add(BoardBuilder.buildBackground());
    await world.add(BoardBuilder.buildLaunchHole());
    await world.addAll(BoardBuilder.buildWalls());
    await world.addAll(BoardBuilder.buildPegs());
    await world.addAll(BoardBuilder.buildSlotDividers());
    await world.addAll(BoardBuilder.buildSlotLabels());
    // Titre PLINKO déplacé en overlay Flutter (main.dart) pour positionnement
    // pixel-exact indépendant du zoom caméra.
  }

  /// Recalcule zoom + centre caméra pour fit la largeur de l'écran.
  /// Le contenu utile va de y≈1.8 (LaunchHole) à y≈slotBaseY (~15.5).
  void _applyResponsiveCamera(Vector2 size) {
    if (size.x <= 0 || size.y <= 0) return;
    // Marge horizontale 4% pour respirer
    final fitZoom = (size.x * 0.96) / PlinkoConfig.worldWidth;
    camera.viewfinder.zoom = fitZoom;
    final contentTop = PlinkoConfig.ballStartY - 0.5;
    final contentBottom = PlinkoConfig.slotBaseY + 0.3;
    camera.viewfinder.position = Vector2(
      PlinkoConfig.worldWidth / 2,
      (contentTop + contentBottom) / 2,
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (camera.viewfinder.zoom > 0) _applyResponsiveCamera(size);
  }

  /// Grille triangulaire : rang R contient R+1 picots (à partir de startRow).
  void _buildPegPositions() {
    _pegPositions.clear();
    for (int row = PlinkoConfig.startRow; row < PlinkoConfig.rows; row++) {
      final colCount = PlinkoConfig.pegCount(row);
      final y = PlinkoConfig.pegY(row);
      for (int col = 0; col < colCount; col++) {
        final x = PlinkoConfig.pegX(row, col);
        _pegPositions.add(Vector2(x, y));
      }
    }
  }

  // ── Lancer piloté par l'UI (plus de tap-to-launch) ───────────────────────

  @override
  void onTapUp(TapUpEvent event) {
    // Tap sur le plateau = no-op : le lancer passe par les boutons en bas.
  }

  /// Lance [count] billes en rafale (décalées de [_stagggerMs]).
  /// Appelé par l'UI (boutons "N billes").
  void launchBalls(int count) {
    if (count <= 0) return;
    if (ballsInFlightNotifier.value > 0) return; // double-protection
    for (int i = 0; i < count; i++) {
      Future.delayed(
        Duration(milliseconds: i * _stagggerMs),
        _launchBall,
      );
    }
  }

  void _launchBall() {
    final bet = betAmountNotifier.value;
    balanceNotifier.value = balanceNotifier.value - bet;

    final jitter = (_rng.nextDouble() - 0.5) * 0.4;
    final startX = PlinkoConfig.boardCenterX + jitter;
    final startPos = Vector2(startX, PlinkoConfig.ballStartY);

    final ball = Ball(startPos);
    world.add(ball);
    _activeBalls.add(ball);
    ballsInFlightNotifier.value = _activeBalls.length;
  }

  // ── Boucle principale ────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    final subDt = dt / _physicsSubSteps;
    final toRemove = <Ball>[];

    for (final ball in _activeBalls) {
      // Physique tant que la bille n'a pas atterri
      if (!ball.hasLanded) {
        for (int s = 0; s < _physicsSubSteps; s++) {
          ball.stepPhysics(subDt);
          _resolvePegCollisionsFor(ball);
          _resolveSlotDividerCollisionsFor(ball);
          if (ball.hasLanded) break;
        }
      }

      // Traitement du crédit à l'atterrissage (une seule fois par bille)
      if (ball.hasLanded && !_creditedBalls.contains(ball)) {
        _creditedBalls.add(ball);
        _creditLanding(ball);
        _landedLinger[ball] = 0;
      }

      // Linger : on laisse la bille visible un court instant puis on despawn
      if (ball.hasLanded) {
        final t = (_landedLinger[ball] ?? 0) + dt;
        _landedLinger[ball] = t;
        if (t > _lingerAfterLand) {
          toRemove.add(ball);
        }
      }
    }

    // Nettoyage des billes à supprimer
    for (final ball in toRemove) {
      ball.removeFromParent();
      _activeBalls.remove(ball);
      _creditedBalls.remove(ball);
      _landedLinger.remove(ball);
    }
    if (toRemove.isNotEmpty) {
      ballsInFlightNotifier.value = _activeBalls.length;
    }
  }

  /// Crédite la balance du multiplicateur × mise, et joue les particules.
  void _creditLanding(Ball ball) {
    final slotIdx = ball.landedSlotIndex;
    if (slotIdx == null || slotIdx < 0 || slotIdx >= PlinkoConfig.slotCount) {
      // Bille sortie du plateau → pas de crédit (la mise est déjà déduite)
      return;
    }

    final mult = PlinkoConfig.slotMultiplierAt(slotIdx);
    final gain = betAmountNotifier.value * mult;
    balanceNotifier.value = balanceNotifier.value + gain;

    // Émet le gain pour l'animation "+X€" flottante
    gainEvents.add(gain);

    // Particules d'impact (plus intense si case majeure)
    world.add(ImpactParticles(
      ball.position.clone(),
      isJackpot: PlinkoConfig.slotIsMajor(slotIdx),
    ));
  }

  // ── Collisions ───────────────────────────────────────────────────────────

  /// Collision bille ↔ picots — réflexion sur la normale.
  void _resolvePegCollisionsFor(Ball ball) {
    if (ball.hasLanded) return;

    final collisionDist   = PlinkoConfig.ballRadius + PlinkoConfig.pegRadius;
    final collisionDistSq = collisionDist * collisionDist;
    const double separationGap = 0.02;

    for (int i = 0; i < _pegPositions.length; i++) {
      final pegPos = _pegPositions[i];
      final delta  = ball.position - pegPos;
      final distSq = delta.x * delta.x + delta.y * delta.y;

      if (distSq < collisionDistSq && distSq > 0.0001) {
        final dist   = sqrt(distSq);
        final normal = delta / dist;

        ball.position = pegPos + normal * (collisionDist + separationGap);

        final dot = ball.velocity.dot(normal);
        if (dot < 0) {
          ball.velocity -= normal * (dot * (1 + PlinkoConfig.pegRestitution));
        }

        ball.triggerBounce(normal);
        _triggerPegHit(i);
      }
    }
  }

  /// Collision bille ↔ séparateurs de cases.
  void _resolveSlotDividerCollisionsFor(Ball ball) {
    if (ball.hasLanded) return;

    final slotZoneTop = PlinkoConfig.slotBaseY - PlinkoConfig.slotWallHeight;
    if (ball.position.y < slotZoneTop) return;

    const double slotDividerRestitution = 0.15;

    for (int i = 0; i <= PlinkoConfig.slotCount; i++) {
      final divX = PlinkoConfig.slotStartX + i * PlinkoConfig.slotWidth;
      final dx   = ball.position.x - divX;
      if (dx.abs() < PlinkoConfig.ballRadius) {
        final sign = dx >= 0 ? 1.0 : -1.0;
        ball.position.x = divX + sign * PlinkoConfig.ballRadius;
        ball.velocity.x = -ball.velocity.x * slotDividerRestitution;
      }
    }
  }

  /// Active le glow flash sur le picot d'index [pegIndex].
  void _triggerPegHit(int pegIndex) {
    final pegs = world.children.whereType<Peg>().toList();
    if (pegIndex >= 0 && pegIndex < pegs.length) {
      pegs[pegIndex].triggerHit();
    }
  }

  // ── Reconstruction du plateau (appelée par ConfigPanel) ──────────────────

  /// Reconstruit entièrement le plateau avec la config actuelle.
  void rebuildBoard() {
    // Nettoyer toutes les billes en vol
    for (final ball in _activeBalls) {
      ball.removeFromParent();
    }
    _activeBalls.clear();
    _creditedBalls.clear();
    _landedLinger.clear();
    ballsInFlightNotifier.value = 0;

    world.removeAll(world.children.whereType<Peg>().toList());
    world.removeAll(world.children.whereType<SlotDivider>().toList());
    world.removeAll(world.children.whereType<SlotLabel>().toList());

    world.addAll(BoardBuilder.buildPegs());
    world.addAll(BoardBuilder.buildSlotDividers());
    world.addAll(BoardBuilder.buildSlotLabels());

    _buildPegPositions();
  }

  /// Hook legacy (ConfigPanel) — no-op en mode multiplicateur.
  void refreshLotLabels() {
    // SlotLabel lit directement slotMultiplierLabel — rien à rafraîchir.
  }
}
