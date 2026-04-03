import 'dart:math' show max;
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

  // (Anti-orbite retiré — physique pure)

  // ── Mode replay ───────────────────────────────────────────────────────────
  final List<TrajectoryFrame>? _replayFrames;
  int _replayIndex   = 0;
  int _tickCount     = 0;

  /// Vitesse de replay — lue depuis la config pour être ajustable facilement.
  static int get _replayStride => PlinkoConfig.replayStride;

  bool get isReplay => _replayFrames != null;

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
  }

  // ── Mode replay ───────────────────────────────────────────────────────────

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

    // Halo externe or
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
  }
}
