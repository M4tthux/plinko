import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/trajectory_loader.dart';
import 'game/plinko_game.dart';
import 'ui/config_panel.dart';
import 'ui/reward_overlay.dart';

/// Timestamp de build — mis à jour à chaque hot reload.
/// Permet de vérifier que Flutter a bien pris les dernières modifs.
const String kBuildTime = '2026-04-09 · build 35';

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

  @override
  void initState() {
    super.initState();
    _game = PlinkoGame();
    // Charger les trajectoires pré-calculées au démarrage
    TrajectoryLoader.load().then((_) {
      debugPrint('[Plinko] Trajectoires chargées');
    }).catchError((e) {
      debugPrint('[Plinko] Trajectoires non trouvées — mode physique fallback');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
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
                  'Tap pour lancer',
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

              // Overlay récompense — apparaît à l'atterrissage de la bille
              ValueListenableBuilder(
                valueListenable: _game.landedSlotNotifier,
                builder: (context, result, _) {
                  if (result == null) return const SizedBox.shrink();
                  return RewardOverlay(
                    prizeName: result.prizeName,
                    isJackpot: result.isJackpot,
                    isLoss: result.isLoss,
                    onDismiss: _game.dismissReward,
                  );
                },
              ),

              // Badge DEBUG — lot tiré + case cible (visible pendant le lancer)
              ValueListenableBuilder(
                valueListenable: _game.debugTargetNotifier,
                builder: (context, target, _) {
                  if (target == null) return const SizedBox.shrink();
                  return Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xEE0a0a18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF7c5cbf)),
                      ),
                      child: Text(
                        '🎯 $target',
                        style: const TextStyle(
                          color: Color(0xFFccaaff),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Panneau de config DEBUG (icône ⚙ en haut à droite)
              ConfigPanel(game: _game),
            ],
          ),
        ),
      ),
    );
  }
}
