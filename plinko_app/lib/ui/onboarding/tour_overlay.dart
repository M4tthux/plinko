import 'package:flutter/material.dart';
import '../../services/onboarding_prefs.dart';
import 'coachmark.dart';

/// Cible d'un step : clé du widget à spotlighter + padding de trou.
class TourTarget {
  final GlobalKey key;
  final String title;
  final String body;
  final double holePadding;

  const TourTarget({
    required this.key,
    required this.title,
    required this.body,
    this.holePadding = CoachmarkTokens.holePadding,
  });
}

/// Orchestrateur du tour (4 steps) — overlay plein écran.
///
/// Utilisation : monter au-dessus du jeu quand le tour est actif.
/// Appelle `onFinished` à la fin (Skip ou Terminer) pour démonter l'overlay
/// et persister `hasSeenTour`.
class TourOverlay extends StatefulWidget {
  final List<TourTarget> targets;
  final VoidCallback onFinished;

  const TourOverlay({
    super.key,
    required this.targets,
    required this.onFinished,
  });

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<TourOverlay> {
  int _step = 1;

  @override
  void initState() {
    super.initState();
    // Force un rebuild une frame après le mount : lors du 1er build, les
    // GlobalKeys sur les widgets cibles n'ont pas encore de RenderBox, donc
    // `_rectFor` renvoie null. Le rebuild post-frame les capte.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Rect? _rectFor(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }

  void _next() {
    if (_step >= widget.targets.length) {
      _finish();
      return;
    }
    setState(() => _step++);
  }

  Future<void> _finish() async {
    await OnboardingPrefs.markTourSeen();
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.targets.length;
    final target = widget.targets[_step - 1];
    final rect = _rectFor(target.key);
    final isLast = _step == total;

    return Material(
      type: MaterialType.transparency,
      child: Coachmark(
        targetRect: rect,
        step: _step,
        totalSteps: total,
        title: target.title,
        body: target.body,
        ctaLabel: isLast ? 'Terminer' : 'Suivant',
        onNext: _next,
        onSkip: _finish,
        showSkip: !isLast,
        holePadding: target.holePadding,
      ),
    );
  }
}
