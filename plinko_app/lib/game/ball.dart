import 'dart:math' show atan2, max;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment;
import '../config/plinko_config.dart';
import '../models/trajectory.dart';

/// Bille Plinko — Balleck Team.
///
/// Deux modes de fonctionnement :
///
/// [Mode physique] — Ball(startPosition)
///   Physique manuelle frame par frame (gravité + collisions).
///   Utilisé en mode fallback si aucune trajectoire disponible.
///
/// [Mode replay] — Ball.replay(startPosition, frames)
///   Rejoue une trajectoire pré-calculée frame par frame.
///   Aucune physique calculée au runtime — position lue depuis le JSON.
///   C'est ce mode qui garantit l'atterrissage dans la case cible.
class Ball extends PositionComponent {
  /// Vitesse courante — utilisée uniquement en mode physique.
  Vector2 velocity = Vector2.zero();

  bool hasLanded = false;
  int? landedSlotIndex;

  // ── Trail lumineux ──────────────────────────────────────────────────────
  static const int _trailLength = 10;
  final List<Vector2> _trailPositions = [];
  int _trailSkip = 0; // échantillonne 1 frame sur 2 pour espacer le trail

  // ── Squash & stretch ──────────────────────────────────────────────────
  double _squashScaleX = 1.0; // >1 = étiré horizontalement, <1 = écrasé
  double _squashScaleY = 1.0;
  double _squashAngle  = 0.0; // angle de l'impact (radians)
  double _squashTimer  = 0.0; // temps restant de l'animation
  static const double _squashDuration = 0.12; // 120ms
  static const double _squashAmount   = 0.15; // 15% de déformation max

  // ── Mode replay ───────────────────────────────────────────────────────────
  final List<TrajectoryFrame>? _replayFrames;
  int _replayIndex   = 0;
  int _tickCount     = 0;

  /// Vitesse de replay — lue depuis la config pour être ajustable facilement.
  static int get _replayStride => PlinkoConfig.replayStride;

  bool get isReplay => _replayFrames != null;

  /// Déclenche l'animation squash & stretch lors d'un rebond.
  /// [impactNormal] : direction de l'impact (du picot vers la bille).
  void triggerBounce(Vector2 impactNormal) {
    _squashAngle = atan2(impactNormal.y, impactNormal.x);
    _squashTimer = _squashDuration;
  }

  // ── Constructeurs ─────────────────────────────────────────────────────────

  /// Mode physique (fallback si pas de trajectoire disponible).
  Ball(Vector2 startPosition)
      : _replayFrames = null,
        super(position: startPosition, anchor: Anchor.center);

  /// Mode replay — la bille suit exactement la trajectoire pré-calculée.
  Ball.replay(Vector2 startPosition, List<TrajectoryFrame> frames)
      : _replayFrames = frames,
        super(position: startPosition, anchor: Anchor.center);

  // ── Update ────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    if (hasLanded) return;

    if (_replayFrames != null) {
      _updateReplay();
    } else {
      _updatePhysics(dt);
    }

    // Enregistrer la position pour le trail (1 frame sur 2)
    _trailSkip++;
    if (_trailSkip >= 2) {
      _trailSkip = 0;
      _trailPositions.add(position.clone());
      if (_trailPositions.length > _trailLength) {
        _trailPositions.removeAt(0);
      }
    }

    // Animer le squash & stretch (retour progressif à la forme ronde)
    if (_squashTimer > 0) {
      _squashTimer = max(0.0, _squashTimer - dt);
      final progress = _squashTimer / _squashDuration; // 1→0
      // Phase squash (première moitié) puis stretch (seconde moitié)
      final double deform;
      if (progress > 0.5) {
        // Squash : écrasé dans la direction d'impact
        deform = _squashAmount * ((progress - 0.5) * 2);
      } else {
        // Stretch : étiré dans la direction d'impact (rebond)
        deform = -_squashAmount * 0.6 * (progress * 2);
      }
      _squashScaleX = 1.0 - deform;
      _squashScaleY = 1.0 + deform; // volume constant
    } else {
      _squashScaleX = 1.0;
      _squashScaleY = 1.0;
    }
  }

  // ── Mode replay ───────────────────────────────────────────────────────────

  int _lastBounceFrame = -10; // évite les doublons de détection

  void _updateReplay() {
    final frames = _replayFrames!;
    _tickCount++;

    final stride  = _replayStride;
    final frameIdx = (_tickCount - 1) ~/ stride;
    final t = ((_tickCount - 1) % stride) / stride;

    // Dernière frame ou au-delà → atterrissage
    if (frameIdx >= frames.length - 1) {
      final last = frames.last;
      position = Vector2(last.x, last.y);
      if (!hasLanded) {
        hasLanded = true;
        _replayIndex = frames.length - 1;
        landedSlotIndex = _detectSlot();
      }
      return;
    }

    // Interpolation linéaire entre frame[frameIdx] et frame[frameIdx+1]
    final curr = frames[frameIdx];
    final next = frames[frameIdx + 1];
    position = Vector2(
      curr.x + (next.x - curr.x) * t,
      curr.y + (next.y - curr.y) * t,
    );

    // Détection de rebond en replay : changement de direction X brusque
    if (frameIdx > 0 && frameIdx - _lastBounceFrame > 3) {
      final prev = frames[frameIdx - 1];
      final dxBefore = curr.x - prev.x;
      final dxAfter  = next.x - curr.x;
      // Rebond = inversion de direction X ou changement Y brusque
      if (dxBefore * dxAfter < -0.01) {
        final nx = dxBefore > 0 ? -1.0 : 1.0;
        triggerBounce(Vector2(nx, -0.5)..normalize());
        _lastBounceFrame = frameIdx;
      }
    }

    _replayIndex = frameIdx;
  }

  // ── Mode physique (fallback) ───────────────────────────────────────────────

  void _updatePhysics(double dt) {
    // Gravité
    velocity.y += PlinkoConfig.gravity * dt;

    // Déplacement
    position += velocity * dt;

    // Sortie du plateau (pas de parois) → perdu
    if (position.x < -PlinkoConfig.ballRadius * 2 || position.x > PlinkoConfig.worldWidth + PlinkoConfig.ballRadius * 2) {
      hasLanded = true;
      landedSlotIndex = -1; // hors plateau = perdu
      return;
    }

    // Atterrissage
    if (position.y >= PlinkoConfig.slotBaseY - PlinkoConfig.ballRadius) {
      hasLanded = true;
      position.y = PlinkoConfig.slotBaseY - PlinkoConfig.ballRadius;
      landedSlotIndex = _detectSlot();
    }
  }

  /// Détection de case — alignée sur la grille triangulaire.
  int _detectSlot() {
    final relX = position.x - PlinkoConfig.slotStartX;
    return (relX / PlinkoConfig.slotWidth)
        .clamp(0, PlinkoConfig.slotCount - 1)
        .floor();
  }

  // ── Rendu néon ───────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    final r = PlinkoConfig.ballRadius;

    // ── Trail lumineux (10 positions précédentes, fade opacity) ────────────
    // Le trail est dessiné AVANT la transformation squash (positions absolues)
    for (int i = 0; i < _trailPositions.length; i++) {
      final t = (i + 1) / _trailPositions.length; // 0→1 (ancien→récent)
      final trailPos = _trailPositions[i];
      final offset = Offset(
        trailPos.x - position.x,
        trailPos.y - position.y,
      );
      final trailRadius = r * (0.3 + 0.5 * t); // 30%→80% du rayon
      final opacity = 0.35 * t;                  // 0→0.35

      // Glow flou
      canvas.drawCircle(offset, trailRadius * 1.6, Paint()
        ..color      = const Color(0xFFf0c040).withOpacity(opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5));

      // Point solide
      canvas.drawCircle(offset, trailRadius, Paint()
        ..color = const Color(0xFFf0c040).withOpacity(opacity));
    }

    // ── Squash & stretch (déformation au rebond) ──────────────────────────
    canvas.save();
    canvas.rotate(_squashAngle);
    canvas.scale(_squashScaleX, _squashScaleY);
    canvas.rotate(-_squashAngle);

    // ── Halo externe or ───────────────────────────────────────────────────
    canvas.drawCircle(Offset.zero, r * 2.2, Paint()
      ..color      = const Color(0xFFf0c040).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9));

    // Halo interne
    canvas.drawCircle(Offset.zero, r * 1.45, Paint()
      ..color      = const Color(0xFFf0c040).withOpacity(0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.45));

    // Corps principal — sphère dorée
    canvas.drawCircle(Offset.zero, r, Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: [
          Color(0xFFfffbe6),
          Color(0xFFf0c040),
          Color(0xFF8a5c00),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)));

    // Reflet spéculaire
    canvas.drawCircle(
      Offset(-r * 0.35, -r * 0.35),
      r * 0.28,
      Paint()..color = Colors.white.withOpacity(0.85));

    canvas.restore(); // fin squash & stretch
  }
}
