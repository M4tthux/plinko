import 'dart:math' show Random, atan2, cos, max, min, sin, sqrt;
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

  // ── Glow dynamique (brille plus quand accélère) ────────────────────────
  Vector2 _prevPosition = Vector2.zero();
  double _speedFactor = 0.0; // 0.0=immobile → 1.0=vitesse max

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
        _prevPosition = startPosition.clone(),
        super(position: startPosition, anchor: Anchor.center);

  /// Mode replay — la bille suit exactement la trajectoire pré-calculée.
  Ball.replay(Vector2 startPosition, List<TrajectoryFrame> frames)
      : _replayFrames = frames,
        _prevPosition = startPosition.clone(),
        super(position: startPosition, anchor: Anchor.center);

  // ── Update ────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    if (hasLanded) return;

    if (_replayFrames != null) {
      _updateReplay();
    }
    // Mode physique : stepPhysics() est appelé par PlinkoGame.update() via sub-stepping

    // Enregistrer la position pour le trail (1 frame sur 2)
    _trailSkip++;
    if (_trailSkip >= 2) {
      _trailSkip = 0;
      _trailPositions.add(position.clone());
      if (_trailPositions.length > _trailLength) {
        _trailPositions.removeAt(0);
      }
    }

    // Glow dynamique — estimer la vitesse depuis le déplacement
    final dx = position.x - _prevPosition.x;
    final dy = position.y - _prevPosition.y;
    final speed = sqrt(dx * dx + dy * dy);
    // Normaliser : ~0.3 unités/frame = vitesse haute typique
    _speedFactor = min(1.0, speed / 0.3);
    _prevPosition.setFrom(position);

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

  /// Un seul pas de physique (gravité + déplacement + murs + atterrissage).
  /// Appelé N fois par frame par le sub-stepping dans PlinkoGame.
  void stepPhysics(double subDt) {
    if (hasLanded) return;

    // Gravité
    velocity.y += PlinkoConfig.gravity * subDt;

    // Déplacement
    position += velocity * subDt;

    // Pas de murs — sortie du périmètre des picots de la dernière rangée = perdu
    final r = PlinkoConfig.ballRadius;
    if (position.x < PlinkoConfig.slotStartX - r ||
        position.x > PlinkoConfig.slotEndX + r) {
      hasLanded = true;
      landedSlotIndex = -1;
      return;
    }

    // Atterrissage
    if (position.y >= PlinkoConfig.slotBaseY - r) {
      hasLanded = true;
      position.y = PlinkoConfig.slotBaseY - r;
      landedSlotIndex = _detectSlot();
    }
  }

  // Legacy — appelé si pas de sub-stepping
  void _updatePhysics(double dt) {
    stepPhysics(dt);
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

    const magenta = Color(0xFFFF2EB4);

    // ── Trail magenta (10 positions précédentes, fade opacity) ─────────────
    for (int i = 0; i < _trailPositions.length; i++) {
      final t = (i + 1) / _trailPositions.length;
      final trailPos = _trailPositions[i];
      final offset = Offset(
        trailPos.x - position.x,
        trailPos.y - position.y,
      );
      final trailRadius = r * (0.3 + 0.5 * t);
      final opacity = 0.40 * t;

      // Glow flou magenta
      canvas.drawCircle(offset, trailRadius * 1.6, Paint()
        ..color      = magenta.withOpacity(opacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5));

      // Point solide
      canvas.drawCircle(offset, trailRadius, Paint()
        ..color = magenta.withOpacity(opacity));
    }

    // ── Squash & stretch (déformation au rebond) ──────────────────────────
    canvas.save();
    canvas.rotate(_squashAngle);
    canvas.scale(_squashScaleX, _squashScaleY);
    canvas.rotate(-_squashAngle);

    // ── Halo externe magenta (glow dynamique — brille plus quand accélère)
    final glowBoost = _speedFactor * 0.25;
    canvas.drawCircle(Offset.zero, r * (2.2 + _speedFactor * 0.8), Paint()
      ..color      = magenta.withOpacity(0.20 + glowBoost)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.9 + _speedFactor * 0.5));

    // Halo interne
    canvas.drawCircle(Offset.zero, r * (1.45 + _speedFactor * 0.3), Paint()
      ..color      = magenta.withOpacity(0.45 + glowBoost * 0.6)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.45 + _speedFactor * 0.3));

    // Corps principal — sphère magenta
    canvas.drawCircle(Offset.zero, r, Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: [
          Color(0xFFFFD6EE),
          Color(0xFFFF2EB4),
          Color(0xFF7A0E55),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)));

    // Reflet spéculaire
    canvas.drawCircle(
      Offset(-r * 0.3, -r * 0.35),
      r * 0.26,
      Paint()..color = Colors.white.withOpacity(0.80));

    canvas.restore(); // fin squash & stretch
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ImpactParticles — explosion de particules or à l'atterrissage
// ─────────────────────────────────────────────────────────────────────────────

class _Particle {
  double x, y, vx, vy;
  double life;     // 1.0→0.0
  double radius;
  _Particle(this.x, this.y, this.vx, this.vy, this.life, this.radius);
}

class ImpactParticles extends PositionComponent {
  static const int _count = 12;
  static const double _duration = 0.6; // 600ms
  final List<_Particle> _particles = [];
  double _elapsed = 0.0;
  final bool isJackpot;

  ImpactParticles(Vector2 impactPos, {this.isJackpot = false})
      : super(position: impactPos, anchor: Anchor.center, priority: 90) {
    final rng = Random();
    for (int i = 0; i < _count; i++) {
      // Direction : éventail vers le haut (±120°)
      final angle = -1.57 + (rng.nextDouble() - 0.5) * 2.1; // -π/2 ± ~60°
      final speed = 2.0 + rng.nextDouble() * 4.0;
      _particles.add(_Particle(
        0, 0,
        cos(angle) * speed,
        sin(angle) * speed,
        1.0,
        0.08 + rng.nextDouble() * 0.12,
      ));
    }
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    if (_elapsed >= _duration) {
      removeFromParent();
      return;
    }
    for (final p in _particles) {
      p.vy += 8.0 * dt; // mini gravité sur les particules
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life = max(0.0, 1.0 - _elapsed / _duration);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      final color = const Color(0xFFFF2EB4);
      final opacity = p.life * 0.8;

      // Glow
      canvas.drawCircle(Offset(p.x, p.y), p.radius * 2.5, Paint()
        ..color      = color.withOpacity(opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.15));

      // Corps
      canvas.drawCircle(Offset(p.x, p.y), p.radius * p.life, Paint()
        ..color = color.withOpacity(opacity));
    }
  }
}

