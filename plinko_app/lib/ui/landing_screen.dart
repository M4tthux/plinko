import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/dropl_wordmark.dart';

/// Écran d'accueil — wordmark DROPL, CTA Jouer, ghost link "Comment ça marche ?".
///
/// `onPlay` = démarre la partie sans tour.
/// `onHowItWorks` = démarre la partie avec le tour actif.
class LandingScreen extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onHowItWorks;

  const LandingScreen({
    super.key,
    required this.onPlay,
    required this.onHowItWorks,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF22E4D9);
    const magenta = Color(0xFFFF3EA5);

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Stack(
        children: [
          // Fond : dégradés radiaux cyan (haut) + magenta (bas)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1),
                  radius: 1.1,
                  colors: [
                    accent.withOpacity(0.09),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 1.1),
                  radius: 1.3,
                  colors: [
                    magenta.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0A18),
                    const Color(0xFF07070F),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Wordmark — DROPL (splash size 52, voir §2bis design-ui-spec.md)
                const DroplWordmark(size: 52),

                const Spacer(flex: 1),

                // Bloc texte + CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Tombe. Rebondit. Gagne.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Mini-jeu physique. Chaque chute est différente.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _PrimaryCta(label: 'Jouer', onTap: onPlay),
                      const SizedBox(height: 16),
                      _GhostLink(
                        label: 'Comment ça marche ?',
                        onTap: onHowItWorks,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryCta({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF22E4D9);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, accent.withOpacity(0.78)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: accent.withOpacity(0.50), blurRadius: 24),
              BoxShadow(color: accent.withOpacity(0.30), blurRadius: 48),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: const Color(0xFF0A0A18),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white.withOpacity(0.55),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withOpacity(0.30),
            ),
          ),
        ),
      ),
    );
  }
}
