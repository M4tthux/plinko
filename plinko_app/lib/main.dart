import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/trajectory_loader.dart';
import 'game/plinko_game.dart';
import 'ui/config_panel.dart';

/// Timestamp de build — mis à jour à chaque hot reload.
/// Permet de vérifier que Flutter a bien pris les dernières modifs.
const String kBuildTime = '2026-04-17 · build 45';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Forcer le portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Plein écran immersif
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const PlinkoApp());
}

class PlinkoApp extends StatelessWidget {
  const PlinkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plinko',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PlinkoScreen(),
    );
  }
}

class PlinkoScreen extends StatefulWidget {
  const PlinkoScreen({super.key});

  @override
  State<PlinkoScreen> createState() => _PlinkoScreenState();
}

class _PlinkoScreenState extends State<PlinkoScreen> {
  late final PlinkoGame _game;
  StreamSubscription<double>? _gainSub;

  /// Popups "+X€" actifs à l'écran (multi-ball → plusieurs simultanés possibles).
  final List<_GainPopupData> _popups = [];

  @override
  void initState() {
    super.initState();
    _game = PlinkoGame();
    TrajectoryLoader.load().then((_) {
      debugPrint('[Plinko] Trajectoires chargées');
    }).catchError((e) {
      debugPrint('[Plinko] Trajectoires non trouvées — mode physique fallback');
    });

    // Abonnement aux events de gain pour déclencher les popups animés
    _gainSub = _game.gainEvents.stream.listen((gain) {
      if (!mounted) return;
      setState(() {
        _popups.add(_GainPopupData(gain: gain, key: UniqueKey()));
      });
    });
  }

  @override
  void dispose() {
    _gainSub?.cancel();
    super.dispose();
  }

  void _removePopup(Key key) {
    if (!mounted) return;
    setState(() {
      _popups.removeWhere((p) => p.key == key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
              // Jeu Flame — fond sombre opaque rendu par Flame
              GameWidget(
                game: _game,
                backgroundBuilder: (_) => Container(color: const Color(0xFF08040f)),
              ),

              // Instructions
              const Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Text(
                  'Tap pour lancer (1€ / bille)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0x8800c8ff),
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              // Badge version — DEBUG
              const Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Text(
                  kBuildTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xCC00c8ff),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              // Balance — coin haut-gauche, au-dessus du plateau
              Positioned(
                top: 40,
                left: 16,
                child: ValueListenableBuilder<double>(
                  valueListenable: _game.balanceNotifier,
                  builder: (context, balance, _) {
                    final positive = balance >= 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1a1033).withOpacity(0.92),
                            const Color(0xFF0a0618).withOpacity(0.92),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: positive
                              ? const Color(0xFFf0c040).withOpacity(0.55)
                              : const Color(0xFFff4444).withOpacity(0.55),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (positive
                                    ? const Color(0xFFf0c040)
                                    : const Color(0xFFff4444))
                                .withOpacity(0.25),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'BALANCE',
                            style: TextStyle(
                              color: Color(0x99e8d0ff),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${balance.toStringAsFixed(2)} €',
                            style: TextStyle(
                              color: positive
                                  ? const Color(0xFFffe680)
                                  : const Color(0xFFff9a9a),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Popups "+X€" animés (multi-ball : plusieurs simultanés possibles)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (final p in _popups)
                          _GainPopup(
                            key: p.key,
                            amount: p.gain,
                            onComplete: () => _removePopup(p.key),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

            // Panneau de config DEBUG (icône ⚙ en haut à droite)
            ConfigPanel(game: _game),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GainPopup — animation flottante "+X€" au centre de l'écran
//
// Scale bump (0.4 → 1.3 → 1.0), fade in/out, montée légère. Durée 900ms.
// Auto-retrait via onComplete à la fin de l'animation.
// ─────────────────────────────────────────────────────────────────────────────

class _GainPopupData {
  final double gain;
  final Key key;
  _GainPopupData({required this.gain, required this.key});
}

class _GainPopup extends StatefulWidget {
  final double amount;
  final VoidCallback onComplete;

  const _GainPopup({
    super.key,
    required this.amount,
    required this.onComplete,
  });

  @override
  State<_GainPopup> createState() => _GainPopupState();
}

class _GainPopupState extends State<_GainPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _dy;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Scale : 0.4 → 1.3 (bump) → 1.0 → 1.0
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 60,
      ),
    ]).animate(_ctrl);

    // Opacity : 0 → 1 (entrée) → 1 (maintien) → 0 (sortie)
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_ctrl);

    // Translation Y : léger flottement vers le haut
    _dy = Tween<double>(begin: 0.0, end: -40.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Choisit la taille et la couleur en fonction du montant gagné.
  ({double fontSize, Color color, Color glow}) _styleForGain(double g) {
    if (g >= 25) {
      return (
        fontSize: 76,
        color: const Color(0xFFffe680),
        glow: const Color(0xFFff8800),
      );
    }
    if (g >= 5) {
      return (
        fontSize: 64,
        color: const Color(0xFFffe680),
        glow: const Color(0xFFf0c040),
      );
    }
    if (g >= 1) {
      return (
        fontSize: 52,
        color: const Color(0xFFfff0a0),
        glow: const Color(0xFFf0c040),
      );
    }
    // Gain < 1€ (x0.1, x0.2, x0.5) : plus discret
    return (
      fontSize: 42,
      color: const Color(0xFFc8d8ff),
      glow: const Color(0xFF7c9ccf),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleForGain(widget.amount);
    final text = '+${widget.amount.toStringAsFixed(2)}€';

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        return Transform.translate(
          offset: Offset(0, _dy.value),
          child: Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scale.value,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: style.fontSize,
                  fontWeight: FontWeight.w900,
                  color: style.color,
                  letterSpacing: 1.0,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.75),
                      blurRadius: 3,
                      offset: const Offset(1.5, 2),
                    ),
                    Shadow(
                      color: style.glow.withOpacity(0.95),
                      blurRadius: 18,
                    ),
                    Shadow(
                      color: style.glow.withOpacity(0.55),
                      blurRadius: 36,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
