/// Overlay récompense — affiché à l'atterrissage de la bille.
/// Balleck Team — Dev Session 10 (refonte visuelle end game).
///
/// Version 3 — conforme au brief DESIGN.md (Direction B — L'Explosion Contrôlée) :
///   - Flash blanc court à l'entrée (long pour jackpot)
///   - Confettis depuis le bas de l'écran → haut (win normal)
///   - Feux d'artifice toutes zones (jackpot)
///   - Halo pulse ×3 après l'entrée (jackpot)
///   - Montant tremble 1s puis se stabilise (jackpot)
///   - Mode perte : fade doux, message neutre, pas de particules
///   - Couleurs DESIGN.md : or #f0c040, surface #1a1a2e
///
/// Interface inchangée pour main.dart :
///   RewardOverlay(prizeName, isJackpot, isLoss, onDismiss)
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ─────────────────────────────────────────────────────────
//  Modèle de particule
// ─────────────────────────────────────────────────────────

class _Particle {
  Offset pos;
  double vx, vy;
  final Color color;
  final double size;
  final double lifetime;
  double life; // 1.0 = neuve, 0.0 = morte

  _Particle({
    required this.pos,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.lifetime,
  }) : life = 1.0;
}

// ─────────────────────────────────────────────────────────
//  Painter
// ─────────────────────────────────────────────────────────

class _FireworksPainter extends CustomPainter {
  final List<_Particle> particles;
  _FireworksPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final opacity = (p.life * p.life).clamp(0.0, 1.0);
      paint.color = p.color.withOpacity(opacity * 0.92);
      canvas.drawCircle(p.pos, p.size * p.life.clamp(0.3, 1.0), paint);
    }
  }

  @override
  bool shouldRepaint(_FireworksPainter old) => true;
}

// ─────────────────────────────────────────────────────────
//  Widget principal
// ─────────────────────────────────────────────────────────

class RewardOverlay extends StatefulWidget {
  final String prizeName;
  final bool isJackpot;
  final bool isLoss;
  final VoidCallback onDismiss;

  const RewardOverlay({
    super.key,
    required this.prizeName,
    required this.isJackpot,
    this.isLoss = false,
    required this.onDismiss,
  });

  @override
  State<RewardOverlay> createState() => _RewardOverlayState();
}

class _RewardOverlayState extends State<RewardOverlay>
    with TickerProviderStateMixin {

  // ── Animations d'entrée ───────────────────────────────
  late final AnimationController _entryCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  // ── Flash blanc ────────────────────────────────────────
  late final AnimationController _flashCtrl;
  late final Animation<double> _flashOpacity;

  // ── Jackpot : halo pulse ×3 ───────────────────────────
  AnimationController? _pulseCtrl;
  Animation<double>? _pulseAnim;

  // ── Jackpot : montant tremble 1s ──────────────────────
  AnimationController? _shakeCtrl;

  // ── Particules ────────────────────────────────────────
  late final Ticker _ticker;
  final List<_Particle> _particles = [];
  final Random _rand = Random();
  Duration _lastElapsed = Duration.zero;
  double _burstTimer = 0;
  Size _screenSize = Size.zero;

  late final List<Color> _colors;
  late final double _burstInterval;
  late final int _burstCount;

  // ── Couleurs par mode ─────────────────────────────────
  static const _kOr     = Color(0xFFf0c040); // or chaud — DESIGN.md
  static const _kCyan   = Color(0xFF00c8ff); // cyan électrique
  static const _kNeutre = Color(0xFF8888aa); // gris lavande

  @override
  void initState() {
    super.initState();

    // Couleurs particules
    if (widget.isJackpot) {
      _colors = const [
        _kOr,
        Color(0xFFffd875),
        Color(0xFFffe9a0),
        Colors.white,
        Color(0xFFffb800),
      ];
      _burstInterval = 0.30;
      _burstCount    = 22;
    } else if (!widget.isLoss) {
      _colors = const [
        _kCyan,
        Colors.cyanAccent,
        Colors.white,
        Color(0xFF7c5cbf),
        Color(0xFF00e5ff),
      ];
      _burstInterval = 0.60;
      _burstCount    = 12;
    } else {
      _colors        = [];
      _burstInterval = 9999;
      _burstCount    = 0;
    }

    // Entrée
    _entryCtrl = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: widget.isLoss ? 0.92 : 0.70,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: widget.isLoss ? Curves.easeOut : Curves.easeOutBack,
    ));
    _entryCtrl.forward();

    // Flash blanc
    _flashCtrl = AnimationController(
      duration: Duration(milliseconds: widget.isJackpot ? 500 : 280),
      vsync: this,
    );
    _flashOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut),
    );
    if (!widget.isLoss) _flashCtrl.forward();

    // Jackpot : halo pulse (3 oscillations = 6 demi-cycles de 400ms)
    if (widget.isJackpot) {
      _pulseCtrl = AnimationController(
        duration: const Duration(milliseconds: 2400), // 3 × 800ms
        vsync: this,
      );
      _pulseAnim = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
      ]).animate(_pulseCtrl!);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _pulseCtrl!.forward();
      });

      // Jackpot : shake 1s
      _shakeCtrl = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _shakeCtrl!.forward();
      });
    }

    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _entryCtrl.dispose();
    _flashCtrl.dispose();
    _pulseCtrl?.dispose();
    _shakeCtrl?.dispose();
    super.dispose();
  }

  // ── Tick particules ───────────────────────────────────

  void _onTick(Duration elapsed) {
    if (_screenSize == Size.zero || widget.isLoss) return;

    final rawDt = _lastElapsed == Duration.zero
        ? 0.016
        : (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    final dt = rawDt.clamp(0.0, 0.05);
    _lastElapsed = elapsed;

    _burstTimer += dt;
    if (_burstTimer >= _burstInterval) {
      _spawnBurst();
      _burstTimer = 0;
    }

    for (final p in _particles) {
      p.vy += 40 * dt;
      p.pos = Offset(p.pos.dx + p.vx * dt, p.pos.dy + p.vy * dt);
      p.life -= dt / p.lifetime;
    }
    _particles.removeWhere((p) => p.life <= 0);

    if (mounted) setState(() {});
  }

  void _spawnBurst() {
    final double cx, cy;

    if (widget.isJackpot) {
      // Toutes zones de l'écran
      cx = _screenSize.width  * (0.20 + _rand.nextDouble() * 0.60);
      cy = _screenSize.height * (0.15 + _rand.nextDouble() * 0.50);
    } else {
      // Confettis depuis le bas → haut (simule la case gagnante)
      cx = _screenSize.width  * (0.25 + _rand.nextDouble() * 0.50);
      cy = _screenSize.height * (0.80 + _rand.nextDouble() * 0.15);
    }

    for (int i = 0; i < _burstCount; i++) {
      final double angle;
      if (widget.isJackpot) {
        // Explosion radiale tous azimuts
        angle = 2 * pi * i / _burstCount + _rand.nextDouble() * 0.4;
      } else {
        // Hémisphère supérieur (upward en Flutter = sin négatif)
        angle = -pi + _rand.nextDouble() * pi;
      }
      final speed = (widget.isJackpot ? 130.0 : 95.0) + _rand.nextDouble() * 80;
      _particles.add(_Particle(
        pos: Offset(cx, cy),
        vx: cos(angle) * speed * (0.7 + _rand.nextDouble() * 0.6),
        vy: sin(angle) * speed * (0.7 + _rand.nextDouble() * 0.6),
        color: _colors[_rand.nextInt(_colors.length)],
        size: widget.isJackpot
            ? 3.0 + _rand.nextDouble() * 2.5
            : 2.0 + _rand.nextDouble() * 1.8,
        lifetime: 1.0 + _rand.nextDouble() * 0.8,
      ));
    }
  }

  // ── Shake offset jackpot ──────────────────────────────

  double get _shakeOffset {
    if (_shakeCtrl == null) return 0;
    final t = _shakeCtrl!.value;
    final amplitude = (1.0 - t) * 7.0; // décroît sur 1s
    return amplitude * sin(t * 35);     // oscillation rapide
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    final Color accent = widget.isJackpot
        ? _kOr
        : widget.isLoss
            ? _kNeutre
            : _kCyan;

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Stack(
        children: [
          // ── Fond sombre ───────────────────────────────
          FadeTransition(
            opacity: _fade,
            child: Container(
              color: widget.isLoss
                  ? const Color(0xAA000014)
                  : const Color(0xCC000014),
            ),
          ),

          // ── Particules ────────────────────────────────
          if (!widget.isLoss)
            Positioned.fill(
              child: CustomPaint(
                painter: _FireworksPainter(_particles),
              ),
            ),

          // ── Flash blanc ───────────────────────────────
          if (!widget.isLoss)
            AnimatedBuilder(
              animation: _flashCtrl,
              builder: (_, __) => IgnorePointer(
                child: Opacity(
                  opacity: _flashOpacity.value *
                      (widget.isJackpot ? 0.85 : 0.55),
                  child: Container(color: Colors.white),
                ),
              ),
            ),

          // ── Contenu centré ────────────────────────────
          FadeTransition(
            opacity: _fade,
            child: Center(
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge JACKPOT
                    if (widget.isJackpot) ...[
                      _buildJackpotBadge(accent),
                      const SizedBox(height: 22),
                    ],

                    // Carte principale
                    _buildCard(accent),

                    const SizedBox(height: 44),
                    Text(
                      'Tap pour continuer',
                      style: TextStyle(
                        color: accent.withOpacity(0.45),
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Badge JACKPOT avec pulse ──────────────────────────

  Widget _buildJackpotBadge(Color accent) {
    return AnimatedBuilder(
      animation: _pulseCtrl ?? _entryCtrl,
      builder: (_, child) {
        final pv = _pulseAnim?.value ?? 0.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 7),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.55 + pv * 0.35),
                blurRadius: 24 + pv * 20,
                spreadRadius: 2 + pv * 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: const Text(
        '✦  J A C K P O T  ✦',
        style: TextStyle(
          color: Color(0xFF1a0800),
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.5,
        ),
      ),
    );
  }

  // ── Carte principale ──────────────────────────────────

  Widget _buildCard(Color accent) {
    return AnimatedBuilder(
      animation: _pulseCtrl ?? _entryCtrl,
      builder: (_, child) {
        final pv = _pulseAnim?.value ?? 0.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: accent,
              width: widget.isJackpot ? 2.5 : 1.5,
            ),
            color: const Color(0xFF1a1a2e), // surface — DESIGN.md
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(
                  (widget.isJackpot ? 0.45 : 0.25) + pv * 0.20,
                ),
                blurRadius: (widget.isJackpot ? 80 : 48) + pv * 30,
                spreadRadius: (widget.isJackpot ? 10 : 4) + pv * 6,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconCircle(accent),
          const SizedBox(height: 20),
          _buildPrizeName(accent),
          const SizedBox(height: 14),
          _buildHaloBar(accent),
          if (widget.isLoss) ...[
            const SizedBox(height: 16),
            Text(
              'Pas de chance cette fois…',
              style: TextStyle(
                color: _kNeutre.withOpacity(0.7),
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Icône ─────────────────────────────────────────────

  Widget _buildIconCircle(Color accent) {
    final icon = widget.isLoss
        ? '—'
        : widget.isJackpot
            ? '✦'
            : '€';
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withOpacity(0.10),
        border: Border.all(color: accent.withOpacity(0.45), width: 1.5),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.25), blurRadius: 16),
        ],
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            color: accent,
            fontSize: widget.isJackpot ? 28 : 36,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: accent.withOpacity(0.8), blurRadius: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ── Montant (avec shake jackpot) ──────────────────────

  Widget _buildPrizeName(Color accent) {
    final text = Text(
      widget.prizeName,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: accent,
        fontSize: widget.isJackpot ? 62 : 54,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        height: 1.0,
        shadows: [
          Shadow(color: accent.withOpacity(0.95), blurRadius: 28),
          Shadow(color: accent.withOpacity(0.55), blurRadius: 60),
        ],
      ),
    );

    if (!widget.isJackpot || _shakeCtrl == null) return text;

    return AnimatedBuilder(
      animation: _shakeCtrl!,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeOffset, 0),
        child: child,
      ),
      child: text,
    );
  }

  // ── Halo bar (avec pulse jackpot) ─────────────────────

  Widget _buildHaloBar(Color accent) {
    return AnimatedBuilder(
      animation: _pulseCtrl ?? _entryCtrl,
      builder: (_, __) {
        final pv = _pulseAnim?.value ?? 0.0;
        final w = (widget.isJackpot ? 160.0 : 120.0) * (1.0 + pv * 0.3);
        return Container(
          height: 3,
          width: w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                accent.withOpacity(0.85),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.55 + pv * 0.30),
                blurRadius: 10 + pv * 8,
              ),
            ],
          ),
        );
      },
    );
  }
}
