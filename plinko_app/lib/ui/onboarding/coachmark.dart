import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens alignés sur le handoff design (README hi-fi).
class CoachmarkTokens {
  static const accent = Color(0xFF22E4D9);
  static const bgBase = Color(0xFF050510);
  static const cardTop = Color(0xEB141424);
  static const cardBottom = Color(0xEB0C0C18);
  static const textPrimary = Colors.white;
  static const textMuted = Color(0xBFFFFFFF); // white 75%
  static const dim = Color(0x9E000000); // 0.62
  static const calloutMargin = 18.0;
  static const holePadding = 6.0;
  static const holePaddingBoard = 10.0;
  static const animCurve = Cubic(0.2, 0.8, 0.2, 1.0);
  static const animMs = 420;
}

/// Callout docké au-dessus ou en dessous du spot selon la moitié de l'écran.
class Coachmark extends StatelessWidget {
  final Rect? targetRect;
  final int step;
  final int totalSteps;
  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final bool showSkip;

  /// Padding autour du target (plus grand sur le plateau).
  final double holePadding;

  const Coachmark({
    super.key,
    required this.targetRect,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.onNext,
    this.onSkip,
    this.showSkip = true,
    this.holePadding = CoachmarkTokens.holePadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = Size(constraints.maxWidth, constraints.maxHeight);
        final rawHole = targetRect ??
            Rect.fromCenter(
              center: Offset(screen.width / 2, screen.height / 2),
              width: 0,
              height: 0,
            );
        final hole = rawHole.inflate(holePadding);

        return Stack(
          children: [
            // Dim overlay composé de 4 rectangles autour du trou. Évite
            // Path.combine / BlendMode.clear qui rendent de façon incohérente
            // sur le renderer HTML de Flutter Web (le trou n'était pas clean,
            // l'intérieur apparaissait assombri par artefact).
            IgnorePointer(
              child: Stack(
                children: [
                  // Bande supérieure
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: hole.top.clamp(0.0, screen.height),
                    child: Container(color: CoachmarkTokens.dim),
                  ),
                  // Bande inférieure
                  Positioned(
                    left: 0,
                    right: 0,
                    top: hole.bottom.clamp(0.0, screen.height),
                    bottom: 0,
                    child: Container(color: CoachmarkTokens.dim),
                  ),
                  // Bande gauche (au niveau du trou)
                  Positioned(
                    left: 0,
                    top: hole.top.clamp(0.0, screen.height),
                    width: hole.left.clamp(0.0, screen.width),
                    height: hole.height.clamp(0.0, screen.height),
                    child: Container(color: CoachmarkTokens.dim),
                  ),
                  // Bande droite (au niveau du trou)
                  Positioned(
                    left: hole.right.clamp(0.0, screen.width),
                    top: hole.top.clamp(0.0, screen.height),
                    right: 0,
                    height: hole.height.clamp(0.0, screen.height),
                    child: Container(color: CoachmarkTokens.dim),
                  ),
                ],
              ),
            ),

            // Ring animé autour du trou
            AnimatedPositioned(
              duration: const Duration(milliseconds: CoachmarkTokens.animMs),
              curve: CoachmarkTokens.animCurve,
              left: hole.left,
              top: hole.top,
              width: hole.width,
              height: hole.height,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: CoachmarkTokens.accent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Callout docké
            _DockedCallout(
              hole: hole,
              screen: screen,
              step: step,
              totalSteps: totalSteps,
              title: title,
              body: body,
              ctaLabel: ctaLabel,
              onNext: onNext,
              onSkip: onSkip,
              showSkip: showSkip,
            ),
          ],
        );
      },
    );
  }
}

class _SkipLink extends StatelessWidget {
  final VoidCallback onTap;
  const _SkipLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Passer',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white.withOpacity(0.60),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _DockedCallout extends StatelessWidget {
  final Rect hole;
  final Size screen;
  final int step;
  final int totalSteps;
  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final bool showSkip;

  const _DockedCallout({
    required this.hole,
    required this.screen,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.onNext,
    this.onSkip,
    this.showSkip = true,
  });

  @override
  Widget build(BuildContext context) {
    final margin = CoachmarkTokens.calloutMargin;
    // Cap largeur : phone-width - 36 en mobile, plafonné à 440 en desktop.
    final maxWidth = (screen.width - margin * 2).clamp(0.0, 440.0);

    // Hauteur estimée de la callout — utilisée pour clamper la position et
    // garantir qu'elle reste toujours dans le viewport, même quand le spot
    // est très grand (ex. step plateau, presque plein écran).
    const calloutEstH = 150.0;
    const gap = 16.0;
    const safeEdge = 20.0;

    // Espace dispo au-dessus et en dessous du spot
    final spaceBelow = screen.height - hole.bottom - gap - safeEdge;
    final spaceAbove = hole.top - gap - safeEdge;

    double topPos;
    if (spaceBelow >= calloutEstH) {
      // Dock en dessous
      topPos = hole.bottom + gap;
    } else if (spaceAbove >= calloutEstH) {
      // Dock au-dessus
      topPos = hole.top - gap - calloutEstH;
    } else {
      // Pas assez de place : on colle en bas (le spot est quasi plein écran)
      topPos = screen.height - calloutEstH - safeEdge;
    }
    topPos = topPos.clamp(safeEdge, screen.height - calloutEstH - safeEdge);

    // Centre la callout horizontalement quand le viewport dépasse 440 (desktop).
    final sideMargin = ((screen.width - maxWidth) / 2).clamp(margin.toDouble(), double.infinity);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: CoachmarkTokens.animMs),
      curve: CoachmarkTokens.animCurve,
      left: sideMargin,
      right: sideMargin,
      top: topPos,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(step),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: CoachmarkTokens.animMs),
        curve: CoachmarkTokens.animCurve,
        builder: (_, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - v)),
            child: child,
          ),
        ),
        child: _CalloutCard(
          maxWidth: maxWidth,
          step: step,
          totalSteps: totalSteps,
          title: title,
          body: body,
          ctaLabel: ctaLabel,
          onNext: onNext,
          onSkip: onSkip,
          showSkip: showSkip,
        ),
      ),
    );
  }
}

class _CalloutCard extends StatelessWidget {
  final double maxWidth;
  final int step;
  final int totalSteps;
  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final bool showSkip;

  const _CalloutCard({
    required this.maxWidth,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.onNext,
    this.onSkip,
    this.showSkip = true,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [CoachmarkTokens.cardTop, CoachmarkTokens.cardBottom],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CoachmarkTokens.accent.withOpacity(0.40),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StepPill(step: step, total: totalSteps),
                    const Spacer(),
                    _Dots(step: step, total: totalSteps),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    color: CoachmarkTokens.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: GoogleFonts.spaceGrotesk(
                    color: CoachmarkTokens.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showSkip && onSkip != null) ...[
                      _SkipLink(onTap: onSkip!),
                      const SizedBox(width: 8),
                    ],
                    _NextButton(label: ctaLabel, onTap: onNext),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final int step;
  final int total;
  const _StepPill({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CoachmarkTokens.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CoachmarkTokens.accent.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        '$step / $total',
        style: GoogleFonts.jetBrainsMono(
          color: CoachmarkTokens.accent,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int step;
  final int total;
  const _Dots({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= total; i++) ...[
          if (i > 1) const SizedBox(width: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == step ? 16 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: i == step
                  ? CoachmarkTokens.accent
                  : Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CoachmarkTokens.accent,
                CoachmarkTokens.accent.withOpacity(0.80),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: CoachmarkTokens.accent.withOpacity(0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF0A0A18),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
