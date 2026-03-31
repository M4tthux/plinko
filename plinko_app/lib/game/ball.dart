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

  // ── Anti-orbite : détecteur de blocage (mode physique) ────────────────────
  /// Compte les frames consécutives où la bille ne descend pas assez.
  /// Si trop long → impulsion forcée vers le bas.
  int _stuckFrames = 0;
  static const int _stuckLimit      = 30;   // ~0.5s à 60fps (90 trop long — orbite visible)
  static const double _stuckVyMin   = 2.0;  // seuil relevé : détecte l'orbite plus tôt
  static const double _stuckNudgeY  = 12.0; // impulsion plus forte pour casser l'orbite
  static const double _stuckDampX   = 0.1;  // amortissement X plus agressif

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
    // frameIdx : quelle paire de frames on est en train d'interpoler
    final frameIdx = (_tickCount - 1) ~/ stride;
    // t : 0.0 au début de la paire, ~1.0 juste avant la suivante
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
    // → la bille glisse continuellement au lieu de téléporter entre frames,
    //   ce qui évite l'effet "passe à travers les picots".
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
    // ── Détecteur de blocage anti-orbite ──────────────────────────────────
    // Si la bille ne descend pas assez pendant trop longtemps (orbite entre
    // deux picots), on lui applique une impulsion vers le bas.
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

    // Parois gauche / droite — rebond avec kick minimum
    // Si velocity.x ≈ 0 (bille qui glisse le long du mur), on impose
    // un élan minimum vers l'intérieur pour éviter le couloir latéral.
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

    // Entonnoir — dès l'entrée dans la zone de picots, force centripète si
    // la bille est dans le couloir mur↔premier picot. Empêche la chute verticale.
    if (position.y > PlinkoConfig.pegStartY) {
      if (position.x < PlinkoConfig.funnelZoneWidth) {
        velocity.x += PlinkoConfig.funnelForce * dt;
      } else if (position.x > PlinkoConfig.worldWidth - PlinkoConfig.funnelZoneWidth) {
        velocity.x -= PlinkoConfig.funnelForce * dt;
      }
    }

    // Atterrissage
    if (position.y >= PlinkoConfig.slotBaseY - PlinkoConfig.ballRadius) {
      hasLanded = true;
      position.y = PlinkoConfig.slotBaseY - PlinkoConfig.ballRadius;
      landedSlotIndex = _detectSlot();
    }
  }

  int _detectSlot() {
    return (position.x / PlinkoConfig.slotWidth)
        .clamp(0, PlinkoConfig.slotCount - 1)
        .floor();
  }

  // ── Rendu néon ───────────────────────────────────────────────────────────
  // Rayon visuel = rayon physique (1.0) — les rebonds semblent corrects visuellement.
  static const double _visualScale = 1.0;

  @override
  void render(Canvas canvas) {
    final r = PlinkoConfig.ballRadius * _visualScale;

    // Halo externe (bloom) — contenu pour ne pas déborder sur les picots voisins
    final glowPaint = Paint()
      ..color = const Color(0xFF00c8ff).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
    canvas.drawCircle(Offset.zero, r * 2.0, glowPaint);

    // Halo interne
    final innerGlowPaint = Paint()
      ..color = const Color(0xFF00c8ff).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4);
    canvas.drawCircle(Offset.zero, r * 1.4, innerGlowPaint);

    // Corps principal (gradient radial)
    final bodyGradient = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: const [
          Color(0xFFaaf0ff),
          Color(0xFF00c8ff),
          Color(0xFF0080cc),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset.zero, radius: r),
      );
    canvas.drawCircle(Offset.zero, r, bodyGradient);

    // Reflet spéculaire
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(
      Offset(-r * 0.35, -r * 0.35),
      r * 0.28,
      highlightPaint,
    );
  }
}
