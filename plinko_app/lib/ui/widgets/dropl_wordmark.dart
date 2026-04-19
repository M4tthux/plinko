import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Wordmark DROPL — rendu en 3 groupes (DR | O | PL) pour que le "O abaissé"
/// puisse se décaler en Y sans affecter le reste du mot.
///
/// Spec : §2bis `design-ui-spec.md`.
/// Tailles canoniques : 40 (header in-screen) et 52 (splash).
/// Taille minimum : 28 — sous ce seuil, le O abaissé se lit comme une erreur.
class DroplWordmark extends StatelessWidget {
  final double size;
  final Color color;

  const DroplWordmark({
    super.key,
    this.size = 40,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // ViewBox de référence : 220×72 à fontSize=52.
    final scale = size / 52.0;
    return CustomPaint(
      size: Size(220 * scale, 72 * scale),
      painter: _DroplPainter(size: size, color: color),
    );
  }
}

class _DroplPainter extends CustomPainter {
  final double size;
  final Color color;
  _DroplPainter({required this.size, required this.color});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final scale = size / 52.0;

    // letter-spacing = size × −0.046 (−2.4 à 52px, −1.85 à 40px).
    final letterSpacing = size * -0.046;

    // Baseline DR/PL à y=50 (référence 52px) ; O à y=50 + 10 (≈19 % cap-height).
    final baselineY = 50.0 * scale;
    final oBaselineY = 60.0 * scale;

    // Centres optiques (text-anchor="middle") du lockup de référence.
    final drCenterX = 58.0 * scale;
    final oCenterX = 110.0 * scale;
    final plCenterX = 160.0 * scale;

    _drawCentered(canvas, 'DR', drCenterX, baselineY, letterSpacing);
    _drawCentered(canvas, 'O', oCenterX, oBaselineY, letterSpacing);
    _drawCentered(canvas, 'PL', plCenterX, baselineY, letterSpacing);
  }

  void _drawCentered(Canvas canvas, String text, double centerX,
      double baselineY, double letterSpacing) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.spaceGrotesk(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
          letterSpacing: letterSpacing,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final distanceToBaseline =
        painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    final dx = centerX - painter.width / 2;
    final dy = baselineY - distanceToBaseline;
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _DroplPainter old) =>
      old.size != size || old.color != color;
}
