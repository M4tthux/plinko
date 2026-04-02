import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/material.dart' show Color;
import '../config/plinko_config.dart';
import '../models/prize_lot.dart';
import '../data/trajectory_loader.dart';
import 'board.dart';
import 'ball.dart';

/// Jeu principal Plinko — Balleck Team.
///
/// Dev Session 1 : rendu visuel, physique manuelle, collisions bille-picots.
/// Dev Session 2 : trajectoires pré-calculées JSON + mode replay.
/// Dev Session 4 : overlay récompense via ValueNotifier.
/// Dev Session 5 : système de lots (table de prix + draw probabiliste).
///   - drawLot() : tire un lot au sort selon les probabilités configurées.
///   - assignSlots() : place le lot gagnant dans une case, remplit les autres
///     avec des lots aléatoires (décor). Jackpot → toujours case centrale.
///   - landedSlotNotifier → LandedResult (nom + isJackpot).
class PlinkoGame extends FlameGame with TapCallbacks {
  Ball? _currentBall;
  bool _ballInFlight = false;
  bool _resetPending = false;
  double _launchX = PlinkoConfig.worldWidth / 2;

  /// Notifie le widget Flutter de l'atterrissage avec le lot gagné.
  /// null = pas d'overlay affiché.
  final ValueNotifier<LandedResult?> landedSlotNotifier = ValueNotifier(null);

  /// DEBUG — affiche le lot tiré + la case cible avant l'atterrissage.
  /// Format : "Café offert · Case 2". null = aucun lancer en cours.
  final ValueNotifier<String?> debugTargetNotifier = ValueNotifier(null);

  /// Positions des picots — pour les collisions en mode physique (fallback).
  final List<Vector2> _pegPositions = [];

  final _rng = Random();

  /// Compteur de frames physiques — utilisé pour le cooldown par picot.
  int _physicsFrame = 0;

  /// Cooldown par picot : pegIndex → frame à partir de laquelle la collision
  /// est à nouveau active. Évite les rebonds répétés sur le même picot
  /// qui causent l'effet d'orbite.
  final Map<int, int> _pegCooldownFrames = {};

  @override
  Color backgroundColor() => const Color(0xFF08040f); // fond sombre opaque

  // ── Chargement initial ───────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Assert : la bille passe entre les picots
    assert(PlinkoConfig.ballFitsThrough,
        'GX (${PlinkoConfig.pegGX}) doit être > 2×PEG_RADIUS + 2×BALL_RADIUS '
        '(${2 * PlinkoConfig.pegRadius + 2 * PlinkoConfig.ballRadius})');

    // Configurer la caméra — fixe, centrée sur tout le plateau
    camera.viewfinder.zoom = PlinkoConfig.zoom;
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position =
        Vector2(PlinkoConfig.worldWidth / 2, PlinkoConfig.worldHeight / 2);

    // Précalculer les positions des picots (grille triangulaire)
    _buildPegPositions();

    // Assigner des lots aux cases dès le démarrage (décor)
    _assignSlotsDecor();

    // Fond + plateau
    await world.add(BoardBuilder.buildBackground());
    await world.addAll(BoardBuilder.buildWalls());
    await world.addAll(BoardBuilder.buildPegs());
    await world.addAll(BoardBuilder.buildSlotDividers());
    await world.addAll(BoardBuilder.buildSlotLabels());
    await world.add(BoardBuilder.buildTitle());
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

  // ── Tap pour lancer ──────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    _launchX = _screenToWorld(event.localPosition).x;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_ballInFlight) {
      // Si une bille est déjà en vol avec overlay affiché, fermer l'overlay
      if (_resetPending) dismissReward();
      return;
    }
    _launchBall(_launchX);
  }

  // ── Système de lots ──────────────────────────────────────────────────────

  /// Tire un lot au sort selon les probabilités de la table de lots.
  PrizeLot _drawLot() {
    final lots = PlinkoConfig.lots;
    if (lots.isEmpty) {
      return PrizeLot(name: '?', probability: 100);
    }
    final roll = _rng.nextDouble() * 100.0;
    double cumulative = 0.0;
    for (final lot in lots) {
      cumulative += lot.probability;
      if (roll < cumulative) return lot;
    }
    return lots.last;
  }

  /// Assigne les lots aux cases pour la partie :
  ///   - Le lot gagnant est placé dans une case choisie selon ses règles.
  ///   - Les cases restantes sont remplies avec des lots aléatoires (décor).
  /// Retourne l'index de la case du lot gagnant.
  int _assignSlots(PrizeLot winner) {
    final assignment =
        List<PrizeLot?>.filled(PlinkoConfig.slotCount, null);

    // Choisir la case du lot gagnant
    final int winnerSlot;
    if (winner.isJackpot) {
      // Jackpot → toujours au centre
      winnerSlot = PlinkoConfig.jackpotSlotIndex;
    } else {
      // Autres lots → case aléatoire (on évite le centre pour garder le jackpot spécial)
      final available = List<int>.generate(PlinkoConfig.slotCount, (i) => i)
        ..remove(PlinkoConfig.jackpotSlotIndex);
      available.shuffle(_rng);
      winnerSlot = available.first;
    }
    assignment[winnerSlot] = winner;

    // La case centrale affiche TOUJOURS le jackpot (décor ou gagnant).
    // Si le gagnant n'est pas le jackpot, on place le lot jackpot en décor au centre.
    if (!winner.isJackpot && assignment[PlinkoConfig.jackpotSlotIndex] == null) {
      final jackpotLot = PlinkoConfig.lots.where((l) => l.isJackpot).firstOrNull;
      if (jackpotLot != null) {
        assignment[PlinkoConfig.jackpotSlotIndex] = jackpotLot;
      }
    }

    // Remplir les cases restantes avec des lots au hasard (décor)
    // Le jackpot est exclu des fillers — il n'apparaît QUE au centre.
    final fillers = PlinkoConfig.lots.where((l) => !l.isJackpot).toList();
    for (int i = 0; i < PlinkoConfig.slotCount; i++) {
      if (assignment[i] == null) {
        if (fillers.isNotEmpty) {
          fillers.shuffle(_rng);
          assignment[i] = fillers.first;
        } else {
          assignment[i] = winner;
        }
      }
    }

    PlinkoConfig.currentSlotAssignment = assignment;
    return winnerSlot;
  }

  /// Assigne des lots aléatoirement aux cases (décor uniquement, sans tirage gagnant).
  /// Utilisé à l'initialisation et après application de la table de lots.
  void _assignSlotsDecor() {
    final lots = PlinkoConfig.lots;
    if (lots.isEmpty) {
      PlinkoConfig.currentSlotAssignment = List.filled(PlinkoConfig.slotCount, null);
      return;
    }
    final assignment = List<PrizeLot?>.filled(PlinkoConfig.slotCount, null);
    // Jackpot au centre si disponible
    final jackpot = lots.where((l) => l.isJackpot).toList();
    if (jackpot.isNotEmpty) {
      assignment[PlinkoConfig.jackpotSlotIndex] = jackpot.first;
    }
    // Remplir les autres cases — jackpot exclu des fillers
    final fillers = lots.where((l) => !l.isJackpot).toList();
    for (int i = 0; i < PlinkoConfig.slotCount; i++) {
      if (assignment[i] == null) {
        fillers.shuffle(_rng);
        assignment[i] = fillers.first;
      }
    }
    PlinkoConfig.currentSlotAssignment = assignment;
  }

  // ── Lancement ────────────────────────────────────────────────────────────

  void _launchBall(double x) {
    final startPos = Vector2(x, PlinkoConfig.ballStartY);

    // 1. Draw winning lot
    final winner = _drawLot();

    // 2. Assign slots — returns winning slot index
    final targetSlot = _assignSlots(winner);

    // 3. Load pre-calculated trajectory
    final trajectory = PlinkoConfig.forcePhysicsMode
        ? null
        : TrajectoryLoader.select(
            slotIndex: targetSlot,
            fingerX: x,
          );

    if (trajectory != null) {
      _currentBall = Ball.replay(startPos, trajectory.frames);
    } else {
      _currentBall = Ball(startPos);
    }

    debugTargetNotifier.value = '${winner.name} · Case $targetSlot';

    world.add(_currentBall!);
    _ballInFlight = true;
  }

  // ── Conversion écran → monde ─────────────────────────────────────────────

  Vector2 _screenToWorld(Vector2 screenPos) {
    final screenCenter = size / 2;
    final zoom = camera.viewfinder.zoom;
    return Vector2(
      camera.viewfinder.position.x + (screenPos.x - screenCenter.x) / zoom,
      camera.viewfinder.position.y + (screenPos.y - screenCenter.y) / zoom,
    );
  }

  // ── Boucle principale ────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    // Les collisions physiques ne s'appliquent qu'en mode fallback
    final ball = _currentBall;
    if (ball != null && !ball.isReplay) {
      _resolvePegCollisions();
      _resolveSlotDividerCollisions();
    }

    _followBall();
    _checkLanded();
  }

  /// Collision bille ↔ picots — mode physique uniquement.
  ///
  /// Fix orbite (v4) — trois mécanismes combinés :
  ///   1. Décomposition normale/tangentielle : amortissement de la composante
  ///      tangentielle HORIZONTALE uniquement — la vitesse vers le bas (Y > 0)
  ///      est préservée pour éviter de bloquer la descente.
  ///   2. Cooldown par picot : après collision, le picot est ignoré pendant
  ///      [cooldownDuration] frames pour éviter les re-collisions immédiates.
  ///   3. Kick anti-orbite : un kick vertical vers le bas est injecté si la
  ///      composante Y de vitesse est trop faible après rebond.
  void _resolvePegCollisions() {
    final ball = _currentBall;
    if (ball == null || ball.hasLanded) return;

    _physicsFrame++;

    final collisionDist   = PlinkoConfig.ballRadius + PlinkoConfig.pegRadius;
    final collisionDistSq = collisionDist * collisionDist;

    const double minExitSpeed        = 1.5;
    const double horizontalDamping   = 0.5;  // amortit uniquement l'horizontal
    const double randomKickAmplitude = 0.8;
    const double minDownwardVelocity = 1.0;  // kick si la bille ne descend pas assez
    const int    cooldownDuration    = 8;    // augmenté pour mieux casser l'orbite

    for (int i = 0; i < _pegPositions.length; i++) {
      final coolUntil = _pegCooldownFrames[i];
      if (coolUntil != null && _physicsFrame < coolUntil) continue;

      final pegPos = _pegPositions[i];
      final delta  = ball.position - pegPos;
      final distSq = delta.x * delta.x + delta.y * delta.y;

      if (distSq < collisionDistSq && distSq > 0.0001) {
        final dist   = sqrt(distSq);
        final normal = delta / dist;

        ball.position = pegPos + normal * (collisionDist + 0.1);

        final dotProduct = ball.velocity.dot(normal);
        final vNormal    = normal * dotProduct;
        final vTangent   = ball.velocity - vNormal;

        // ── Clé du fix orbite ──────────────────────────────────────────────
        // On amortit uniquement le X tangentiel.
        // Le Y tangentiel VERS LE BAS (> 0) est préservé intégralement.
        // Le Y tangentiel vers le haut (< 0) est amorti normalement.
        final dampedTangent = Vector2(
          vTangent.x * horizontalDamping,
          vTangent.y > 0 ? vTangent.y : vTangent.y * horizontalDamping,
        );

        ball.velocity = normal * (-dotProduct.abs() * PlinkoConfig.pegRestitution)
                      + dampedTangent;

        // Kick horizontal aléatoire pour casser la symétrie
        ball.velocity.x += (_rng.nextDouble() - 0.5) * randomKickAmplitude;

        // Vitesse minimum de sortie le long de la normale
        final exitSpeed = ball.velocity.dot(normal);
        if (exitSpeed < minExitSpeed) {
          ball.velocity += normal * (minExitSpeed - exitSpeed);
        }

        // Kick vertical : si la bille ne descend pas assez, on lui donne une impulsion
        if (ball.velocity.y < minDownwardVelocity) {
          ball.velocity.y = minDownwardVelocity;
        }

        _pegCooldownFrames[i] = _physicsFrame + cooldownDuration;
      }
    }
  }

  /// Collision bille ↔ séparateurs de cases — mode physique uniquement.
  void _resolveSlotDividerCollisions() {
    final ball = _currentBall;
    if (ball == null || ball.hasLanded) return;

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

  /// Caméra qui suit la bille avec lerp.
  void _followBall() {
    // Caméra fixe — plateau toujours visible en entier (board frame PNG overlay).
  }

  /// Vérifie si la bille a atterri et notifie le widget Flutter.
  void _checkLanded() {
    final ball = _currentBall;
    if (ball == null) return;
    if (ball.hasLanded && _ballInFlight && !_resetPending) {
      _resetPending = true;

      // Identifier le lot gagnant depuis l'assignation courante
      final slotIdx = ball.landedSlotIndex;
      final lot = (slotIdx != null && slotIdx >= 0 && slotIdx < PlinkoConfig.slotCount)
          ? PlinkoConfig.currentSlotAssignment[slotIdx]
          : null;

      // Jackpot → highlight la case gagnante (toutes les autres s'estompent)
      if (lot?.isJackpot ?? false) {
        PlinkoConfig.highlightedSlotIndex = slotIdx;
      }

      landedSlotNotifier.value = LandedResult(
        prizeName: lot?.name ?? '?',
        isJackpot: lot?.isJackpot ?? false,
        isLoss: lot?.isLoss ?? false,
      );
    }
  }

  /// Appelée par RewardOverlay quand l'utilisateur tape pour fermer.
  void dismissReward() {
    PlinkoConfig.highlightedSlotIndex = null;
    landedSlotNotifier.value = null;
    _resetBall();
  }

  void _resetBall() {
    _currentBall?.removeFromParent();
    _currentBall = null;
    _ballInFlight = false;
    _resetPending = false;
    _physicsFrame = 0;
    _pegCooldownFrames.clear();
    debugTargetNotifier.value = null;
    camera.viewfinder.position = Vector2(PlinkoConfig.worldWidth / 2, PlinkoConfig.worldHeight / 2);
  }

  // ── Reconstruction du plateau (appelée par ConfigPanel) ──────────────────

  /// Reconstruit entièrement le plateau avec la config actuelle de PlinkoConfig.
  /// Appelé après modification des sliders physiques.
  void rebuildBoard() {
    _resetBall();

    world.removeAll(world.children.whereType<Peg>().toList());
    world.removeAll(world.children.whereType<SlotDivider>().toList());
    world.removeAll(world.children.whereType<SlotLabel>().toList());

    world.addAll(BoardBuilder.buildPegs());
    world.addAll(BoardBuilder.buildSlotDividers());
    world.addAll(BoardBuilder.buildSlotLabels());

    _buildPegPositions();
  }

  /// Rafraîchit les labels des cases sans reconstruire le plateau.
  /// Appelé après modification de la table de lots via ConfigPanel.
  void refreshLotLabels() {
    _assignSlotsDecor();
    // SlotLabel.render() lit PlinkoConfig.currentSlotAssignment dynamiquement
    // → pas besoin de recréer les composants, la mise à jour est automatique.
  }
}
