import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/trajectory_loader.dart';
import 'game/plinko_game.dart';
import 'ui/config_panel.dart';

/// Timestamp de build — mis à jour à chaque hot reload.
/// Permet de vérifier que Flutter a bien pris les dernières modifs.
const String kBuildTime = '2026-04-12 · build 40';

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

              // Panneau de config DEBUG (icône ⚙ en haut à droite)
              ConfigPanel(game: _game),
            ],
          ),
        ),
      ),
    );
  }
}
