/// Overlay récompense — affiché à l'atterrissage de la bille.
/// Balleck Team — Dev Session 10 (refonte visuelle end game).
///
/// Version 2 :
///   - Système de feux d'artifice (particules canvas) derrière la carte
///   - Grande icône € en haut de la carte
///   - Valeur gagnée en très grande typo avec glow
///   - Halo lumineux sous la valeur
///   - Mode Jackpot : or spectaculaire, plus de feux, badge "JACKPOT"
///   - Mode normal : cyan sobre, feux discrets
///
/// Interface inchangée pour main.dart :
///   RewardOverlay(prizeName, isJackpot, onDismiss)
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
  final double lifetime; // durée totale en secondes
  double life; // 0.0 = mort, 1.0 = neuve

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
      final opacity = (p.life * p.life).clamp(0.0, 1.0); // décroît en courbe
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
  final VoidCallback onDismiss;

  const RewardOverlay({
    super.key,
    required this.prizeName,
    required this.isJackpot,
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

  // ── Feux d'artifice ───────────────────────────────────
  late final Ticker _ticker;
  final List<_Particle> _particles = [];
  final Random _rand = Random();
  Duration _lastElapsed = Duration.zero;
  double _burstTimer = 0;
  Size _screenSize = Size.zero;

  // Couleurs selon mode
  late final List<Color> _colors;
  late final double _burstInterval; // secondes entre chaque explosion
  late final int _burstCount;       // particules par explosion

  @override
  void initState() {
    super.initState();

    // ── Couleurs ──────────────────────────────────────
    _colors = widget.isJackpot
        ? [
            const Color(0xFFFFD700),
            const Color(0xFFFFA500),
            const Color(0xFFFFEC8B),
            Colors.white,
            const Color(0xFFFF8C00),
          ]
        : [
            const Color(0xFF00c8ff),
            Colors.cyanAccent,
            Colors.white,
            const Color(0xFF7c5cbf),
            const Color(0xFF00e5ff),
          ];

    _burstInterval = widget.isJackpot ? 0.30 : 0.60;
    _burstCount    = widget.isJackpot ? 22 : 12;

    // ── Entrée ────────────────────────────────────────
    _entryCtrl = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack),
    );
    _entryCtrl.forward();

    // ── Ticker feux d'artifice ─────────────────────────
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Tick particules ───────────────────────────────────

  void _onTick(Duration elapsed) {
    if (_screenSize == Size.zero) return;

    final rawDt = _lastElapsed == Duration.zero
        ? 0.016
        : (elapsed - _lastElapsed).inMilliseconds / 1000.0;
    final dt = rawDt.clamp(0.0, 0.05); // cap à 50ms (protection freeze)
    _lastElapsed = elapsed;

    // Spawn burst ?
    _burstTimer += dt;
    if (_burstTimer >= _burstInterval) {
      _spawnBurst();
      _burstTimer = 0;
    }

    // Mise à jour particules
    for (final p in _particles) {
      p.vy += 40 * dt; // gravité légère
      p.pos = Offset(p.pos.dx + p.vx * dt, p.pos.dy + p.vy * dt);
      p.life -= dt / p.lifetime;
    }
    _particles.removeWhere((p) => p.life <= 0);

    if (mounted) setState(() {});
  }

  void _spawnBurst() {
    // Zone : 20–80% en X, 15–65% en Y (évite les bords et le bas)
    final cx = _screenSize.width  * (0.20 + _rand.nextDouble() * 0.60);
    final cy = _screenSize.height * (0.15 + _rand.nextDouble() * 0.50);

    for (int i = 0; i < _burstCount; i++) {
      final angle = 2 * pi * i / _burstCount + _rand.nextDouble() * 0.4;
      final speed = (widget.isJackpot ? 130.0 : 85.0) + _rand.nextDouble() * 90;
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

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    final color = widget.isJackpot
        ? const Color(0xFFFFD700)
        : const Color(0xFF00c8ff);

    final glowColor = widget.isJackpot
        ? const Color(0xFFFFD700)
        : const Color(0xFF00c8ff);

    return GestureDetector(
      onTap: widget.onDismiss,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          color: const Color(0xCC000014),
          child: Stack(
            children: [
              // ── Feux d'artifice ───────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: _FireworksPainter(_particles),
                ),
              ),

              // ── Contenu centré ────────────────────────
              Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge JACKPOT (jackpot uniquement)
                      if (widget.isJackpot) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.6),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Text(
                            '✦  J A C K P O T  ✦',
                            style: TextStyle(
                              color: Color(0xFF1a0800),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],

                      // ── Carte principale ───────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 52,
                          vertical: 36,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: color,
                            width: widget.isJackpot ? 2.5 : 1.5,
                          ),
                          color: const Color(0xFF0d0d28),
                          boxShadow: [
                            BoxShadow(
                              color: glowColor.withOpacity(
                                widget.isJackpot ? 0.50 : 0.28,
                              ),
                              blurRadius: widget.isJackpot ? 80 : 48,
                              spreadRadius: widget.isJackpot ? 10 : 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icône € dans cercle
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withOpacity(0.10),
                                border: Border.all(
                                  color: color.withOpacity(0.45),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.25),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '€',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: color.withOpacity(0.8),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Montant gagné
                            Text(
                              widget.prizeName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: color,
                                fontSize: widget.isJackpot ? 62 : 54,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: glowColor.withOpacity(0.95),
                                    blurRadius: 28,
                                  ),
                                  Shadow(
                                    color: glowColor.withOpacity(0.55),
                                    blurRadius: 60,
                                  ),
                                ],
                              ),
                            ),

                            // Halo bar sous le montant
                            const SizedBox(height: 14),
                            Container(
                              height: 3,
                              width: widget.isJackpot ? 160 : 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    glowColor.withOpacity(0.85),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: glowColor.withOpacity(0.65),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tap pour continuer
                      const SizedBox(height: 44),
                      Text(
                        'Tap pour continuer',
                        style: TextStyle(
                          color: color.withOpacity(0.45),
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
