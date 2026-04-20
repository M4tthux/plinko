import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/trajectory_loader.dart';
import 'game/plinko_game.dart';
import 'ui/config_panel.dart';
import 'ui/landing_screen.dart';
import 'ui/onboarding/coachmark.dart';
import 'ui/onboarding/tour_overlay.dart';
import 'ui/widgets/dropl_wordmark.dart';

/// Timestamp de build — mis à jour à chaque hot reload.
/// Permet de vérifier que Flutter a bien pris les dernières modifs.
const String kBuildTime = '2026-04-20 · build 61';

/// Breakpoint unique entre mode mobile (plein cadre centré) et desktop (3 colonnes).
const double kDesktopBreakpoint = 1024.0;

/// Largeur maximale du plateau de jeu (mobile et desktop).
const double kBoardMaxWidth = 500.0;

/// Colonnes latérales desktop (placeholder en attendant le contenu réel).
const double kSidePanelWidth = 240.0;

/// Gap entre les 3 colonnes en mode desktop.
const double kDesktopGap = 20.0;

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
      home: Builder(
        builder: (ctx) => LandingScreen(
          onPlay: () => _openGame(ctx, startTour: false),
          onHowItWorks: () => _openGame(ctx, startTour: true),
        ),
      ),
    );
  }

  void _openGame(BuildContext context, {required bool startTour}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlinkoScreen(startTour: startTour),
      ),
    );
  }
}

class PlinkoScreen extends StatefulWidget {
  final bool startTour;
  const PlinkoScreen({super.key, this.startTour = false});

  @override
  State<PlinkoScreen> createState() => _PlinkoScreenState();
}

class _PlinkoScreenState extends State<PlinkoScreen> {
  late final PlinkoGame _game;
  StreamSubscription<double>? _gainSub;

  /// Popups "+X€" actifs à l'écran (multi-ball → plusieurs simultanés possibles).
  final List<_GainPopupData> _popups = [];

  /// Clés pour cibler les éléments UI depuis le tour d'onboarding.
  final GlobalKey _wordmarkKey = GlobalKey();
  final GlobalKey _boardKey = GlobalKey();
  final GlobalKey _betRowKey = GlobalKey();
  final GlobalKey _ballsRowKey = GlobalKey();

  bool _tourActive = false;

  @override
  void initState() {
    super.initState();
    _game = PlinkoGame();
    if (widget.startTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _tourActive = true);
      });
    }
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
      body: Stack(
        children: [
          Positioned.fill(child: _buildResponsiveGame()),

          // Overlay tour — plein viewport (couvre tout, y compris les panels
          // desktop) pour que le spotlight dim soit homogène.
          if (_tourActive)
            Positioned.fill(child: _buildTourOverlay()),
        ],
      ),
    );
  }

  Widget _buildTourOverlay() {
    return TourOverlay(
      onFinished: () {
        if (!mounted) return;
        setState(() => _tourActive = false);
      },
      targets: [
        TourTarget(
          key: _wordmarkKey,
          title: 'Comment fonctionne DROPL',
          body:
              'Lâche des billes depuis le haut. Chaque bille atterrit dans une case à multiplicateur.',
        ),
        TourTarget(
          key: _boardKey,
          title: 'Le plateau',
          body:
              'Les picots aléatoirisent la trajectoire. Cases extérieures = gros gains. Cases centrales = petits gains.',
          holePadding: CoachmarkTokens.holePaddingBoard,
        ),
        TourTarget(
          key: _betRowKey,
          title: 'Mise par bille',
          body: 'Choisis combien coûte chaque bille. Déduit de ton solde.',
        ),
        TourTarget(
          key: _ballsRowKey,
          title: 'Billes par lancer',
          body: 'De 1 à 10 billes. Coût total = mise × billes.',
        ),
      ],
    );
  }

  Widget _buildResponsiveGame() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;

        final gameContainer = _buildGameContainer();

        if (isDesktop) {
            // Layout desktop : 3 colonnes 240 / 500 / 240 avec gap 20, total 1020, centré.
            return Center(
              child: SizedBox(
                width: kSidePanelWidth * 2 + kBoardMaxWidth + kDesktopGap * 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      width: kSidePanelWidth,
                      child: _SidePanelPlaceholder(label: 'panel left'),
                    ),
                    const SizedBox(width: kDesktopGap),
                    SizedBox(width: kBoardMaxWidth, child: gameContainer),
                    const SizedBox(width: kDesktopGap),
                    const SizedBox(
                      width: kSidePanelWidth,
                      child: _SidePanelPlaceholder(label: 'panel right'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Mode mobile : 92% du viewport, plafonné à 500px, centré horizontalement.
          final boardWidth =
              (constraints.maxWidth * 0.92).clamp(0.0, kBoardMaxWidth);
          return Center(
            child: SizedBox(
              width: boardWidth,
              height: constraints.maxHeight,
              child: gameContainer,
            ),
          );
      },
    );
  }

  /// Top du titre : plancher à 56px pour ne jamais empiéter sur la balance
  /// (card top-left ~16→52px). Plafond 80px pour ne pas descendre dans le plateau.
  double _titleTop(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return (h * 0.05).clamp(72.0, 96.0);
  }

  /// Taille du titre : même logique, borne basse sur petits écrans.
  double _titleFontSize(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return (h * 0.05).clamp(28.0, 42.0);
  }

  /// Stack contenant le jeu + tous les overlays HUD (balance, build badge,
  /// instructions, popups, config panel). Utilisé à l'identique en mobile
  /// et dans la colonne centrale desktop — les Positioned sont donc relatifs
  /// au conteneur du plateau, pas au viewport.
  Widget _buildGameContainer() {
    return Stack(
      children: [
              // Jeu Flame — fond noir Deep Arcade
              GameWidget(
                game: _game,
                backgroundBuilder: (_) => Container(color: const Color(0xFF08080F)),
              ),

              // Zone cible du tour pour le step "Plateau" — overlay invisible
              // resserré sur la pyramide + rangée multiplicateurs. Le
              // GameWidget entier serait trop grand et ne laisserait pas de
              // place pour la callout. On utilise LayoutBuilder pour se
              // baser sur la hauteur du container (pas du viewport) : ça
              // colle proprement en mobile comme en desktop.
              Positioned.fill(
                child: IgnorePointer(
                  child: LayoutBuilder(
                    builder: (_, c) => Padding(
                      padding: EdgeInsets.only(
                        top: c.maxHeight * 0.30,
                        bottom: c.maxHeight * 0.25,
                      ),
                      child: KeyedSubtree(
                        key: _boardKey,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),

              // Titre PLINKO — overlay Flutter, top + taille responsives
              // pour éviter le chevauchement avec le plateau sur petits écrans.
              Positioned(
                left: 0,
                right: 0,
                top: _titleTop(context),
                child: Center(
                  child: _PlinkoTitleOverlay(
                    key: _wordmarkKey,
                    fontSize: _titleFontSize(context),
                  ),
                ),
              ),

              // Rangées de boutons : mise + nombre de billes
              Positioned(
                bottom: 26,
                left: 12,
                right: 12,
                child: _BottomControls(
                  game: _game,
                  betRowKey: _betRowKey,
                  ballsRowKey: _ballsRowKey,
                ),
              ),

              // Badge version — DEBUG (discret, tout en bas)
              const Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Text(
                  kBuildTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0x55FFFFFF),
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.6,
                  ),
                ),
              ),

              // Balance — coin haut-gauche (aligné sur bottom controls)
              Positioned(
                top: 16,
                left: 12,
                child: ValueListenableBuilder<double>(
                  valueListenable: _game.balanceNotifier,
                  builder: (context, balance, _) {
                    final positive = balance >= 0;
                    final accent = positive
                        ? const Color(0xFF00D9FF)         // cyan Deep Arcade
                        : const Color(0xFFFF4466);        // rouge si négatif
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A14).withOpacity(0.75),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accent.withOpacity(0.85), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '€',
                            style: TextStyle(
                              color: accent,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            balance.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
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
        );
  }
}

/// Placeholder vide pour les colonnes latérales en mode desktop (≥1024px).
/// Bordure en pointillé + label central — le contenu réel sera défini
/// dans une étape ultérieure (stats, historique, branding marque…).
class _SidePanelPlaceholder extends StatelessWidget {
  final String label;
  const _SidePanelPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: DottedBorderBox(
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0x88e8d0ff),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Container avec bordure dashed simulée (Flutter n'a pas de BorderStyle.dashed
/// natif sur Border — on utilise un CustomPainter léger).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0x883a2060),
        strokeWidth: 1.5,
        dashLength: 6,
        gapLength: 4,
        radius: 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, next),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength ||
      old.radius != radius;
}

// ─────────────────────────────────────────────────────────────────────────────
// _PlinkoTitleOverlay — wordmark DROPL en header in-screen (voir §2bis spec)
// ─────────────────────────────────────────────────────────────────────────────

class _PlinkoTitleOverlay extends StatelessWidget {
  final double fontSize;
  const _PlinkoTitleOverlay({super.key, this.fontSize = 40});

  @override
  Widget build(BuildContext context) {
    return DroplWordmark(size: fontSize);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomControls — deux rangées : mise (1/2/5/10€) + nombre de billes (1/2/5/10)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final PlinkoGame game;
  final Key? betRowKey;
  final Key? ballsRowKey;
  const _BottomControls({
    required this.game,
    this.betRowKey,
    this.ballsRowKey,
  });

  static const _betOptions = <double>[1, 2, 5, 10];
  static const _countOptions = <int>[1, 2, 5, 10];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rangée 1 : sélection mise (radio-button style)
        ValueListenableBuilder<double>(
          valueListenable: game.betAmountNotifier,
          builder: (_, bet, __) {
            return Row(
              key: betRowKey,
              children: [
                for (int i = 0; i < _betOptions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _BetButton(
                      label: '${_betOptions[i].toInt()}€',
                      selected: bet == _betOptions[i],
                      onTap: () => game.betAmountNotifier.value = _betOptions[i],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        // Rangée 2 : lancer N billes
        ValueListenableBuilder<int>(
          valueListenable: game.ballsInFlightNotifier,
          builder: (_, inFlight, __) {
            final disabled = inFlight > 0;
            return Row(
              key: ballsRowKey,
              children: [
                for (int i = 0; i < _countOptions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _LaunchButton(
                      label: _countOptions[i] == 1
                          ? '1 bille'
                          : '${_countOptions[i]} billes',
                      disabled: disabled,
                      onTap: disabled
                          ? null
                          : () => game.launchBalls(_countOptions[i]),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _BetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00D9FF);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? cyan.withOpacity(0.18)
              : const Color(0xFF0A0A14).withOpacity(0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? cyan : Colors.white.withOpacity(0.18),
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: cyan.withOpacity(0.35), blurRadius: 10)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xCCFFFFFF),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _LaunchButton extends StatelessWidget {
  final String label;
  final bool disabled;
  final VoidCallback? onTap;
  const _LaunchButton({
    required this.label,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const magenta = Color(0xFFFF2EB4);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: disabled ? 0.35 : 1.0,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: disabled
                ? const Color(0xFF0A0A14).withOpacity(0.5)
                : magenta.withOpacity(0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: disabled
                  ? Colors.white.withOpacity(0.10)
                  : magenta,
              width: disabled ? 1 : 1.4,
            ),
            boxShadow: disabled
                ? null
                : [BoxShadow(color: magenta.withOpacity(0.40), blurRadius: 12)],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: disabled ? const Color(0x77FFFFFF) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
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
