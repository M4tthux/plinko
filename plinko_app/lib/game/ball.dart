import 'dart:math' show max;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, RadialGradient, Alignment;
import '../config/plinko_config.dart';

/// Bille Plinko — Balleck Team.
///
/// Mode physique : gravité + collisions gérées par PlinkoGame.
/// Le système de trajectoire forcée (generatePath) sera ajouté en étape 2.
class Ball extends PositionComponent {
  /// Vitesse courante.
  Vector2 velocity = Vector2.zero();

  bool hasLanded = false;
  int? landedSlotIndex;

  // ── Anti-orbite : détecteur de blocage ────────────────────────────────────
  int _stuckFrames = 0;
  static const int _stuckLimit      = 30;
  static const double _stuckVyMin   = 2.0;
  static const double _stuckNudgeY  = 12.0;
  static const double _stuckDampX   = 0.1;

  bool get isReplay => false; // sera réactivé en étape 2

  // ── Constructeur ──────────────────────────────────────────────────────────

  Ball(Vector2 startPosition)
      : super(position: startPosition, anchor: Anchor.center);

  // ── Update ────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    if (hasLanded) return;
    _updatePhysics(dt);
  }

  // ── Physique ──────────────────────────────────────────────────────────────

  void _updatePhysics(double dt) {
    // Anti-orbite
    if (velocity.y < _stuckVyMin && position.y > PlinkoConfig.pegStartY) {
      _stuckFrames++;
      if (_stuckFrames >= _stuckLimit) {
        velocity.y = _stuckNudgeY;
        velocity.x *= _stuckDampX;
        _stuckFrames = 0;
      }
    } else {
      _stuckFrames = 0;
    }

    // Gravité
    velocity.y += PlinkoConfig.gravity * dt;

    // Déplacement
    position += velocity * dt;

    // Parois gauche / droite
    final minX = PlinkoConfig.ballRadius;
    final maxX = PlinkoConfig.worldWidth - PlinkoConfig.ballRadius;
    if (position.x < minX) {
      position.x = minX;
      velocity.x = max(
        velocity.x.abs() * PlinkoConfig.wallRestitution,
        PlinkoConfig.minWallKick,
      );
    } else if (position.x > maxX) {
      position.x = maxX;
      velocity.x = -max(
        velocity.x.abs() * PlinkoConfig.wallRestitution,
        PlinkoConfig.minWallKick,
      );
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
