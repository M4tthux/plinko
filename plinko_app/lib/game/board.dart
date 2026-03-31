import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, TextStyle, FontWeight, TextSpan, TextPainter, TextDirection, Color, RadialGradient, LinearGradient, Alignment, Shadow;
import '../config/plinko_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background — fond du plateau (dégradé radial + scanlines)
// Priorité -100 : rendu avant tous les autres composants.
// ─────────────────────────────────────────────────────────────────────────────

class Background extends PositionComponent {
  Background() : super(position: Vector2.zero(), priority: -100);

  // Étoiles : [x, y, radius, opacity, colorIndex]  (0=blanc, 1=cyan, 2=bleu pâle)
  final List<List<double>> bgStars   = [];
  // Nébuleuses : [x, y, radius, opacity, colorIndex] (0=violet, 1=cyan, 2=violet sombre, 3=bleu nuit)
  final List<List<double>> bgNebulae = [];

  static const List<Color> _starColors   = [Colors.white, Color(0xFF00c8ff), Color(0xFFb0b8ff)];
  static const List<Color> _nebulaColors = [Color(0xFF7c5cbf), Color(0xFF00c8ff), Color(0xFF3a1060), Color(0xFF003355)];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final rng = Random(42);
    final w   = PlinkoConfig.worldWidth;
    final h   = PlinkoConfig.worldHeight;

    // Nébuleuses
    for (int i = 0; i < 4; i++) {
      bgNebulae.add([
        rng.nextDouble() * w,
        rng.nextDouble() * h * 0.75,
        2.5 + rng.nextDouble() * 3.5,
        0.05 + rng.nextDouble() * 0.05,
        i.toDouble(),
      ]);
    }

    // Étoiles
    for (int i = 0; i < 120; i++) {
      final bright = rng.nextDouble() > 0.85;
      final ci = rng.nextDouble() > 0.65 ? 1.0 : rng.nextDouble() > 0.5 ? 2.0 : 0.0;
      bgStars.add([
        rng.nextDouble() * w,
        rng.nextDouble() * h,
        bright ? 0.07 + rng.nextDouble() * 0.06 : 0.03 + rng.nextDouble() * 0.04,
        bright ? 0.7  + rng.nextDouble() * 0.3  : 0.2  + rng.nextDouble() * 0.4,
        ci,
      ]);
    }
  }

  @override
  void render(Canvas canvas) {
    final w    = PlinkoConfig.worldWidth;
    final h    = PlinkoConfig.worldHeight;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // ── Base noir profond ─────────────────────────────────────────────────────
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0a0812));

    // ── Dégradé radial — halo violet centré en haut ───────────────────────────
    final gradient = RadialGradient(
      center: const Alignment(0.0, -0.35),
      radius: 0.75,
      colors: const [Color(0xFF1e0d40), Color(0xFF0a0812)],
      stops:  const [0.0, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // ── Glow pyramidal derrière les picots ────────────────────────────────────
    // Triangle : apex centré en haut des picots, base = largeur totale en bas des picots.
    final apexX  = w / 2;
    final apexY  = PlinkoConfig.pegStartY - 1.0;
    final baseY  = PlinkoConfig.slotBaseY - PlinkoConfig.slotWallHeight - 0.5;
    final baseHW = w * 0.52; // demi-largeur de la base

    final pyramid = Path()
      ..moveTo(apexX, apexY)
      ..lineTo(apexX - baseHW, baseY)
      ..lineTo(apexX + baseHW, baseY)
      ..close();

    // Couche glow large (flou important)
    canvas.drawPath(pyramid, Paint()
      ..color      = const Color(0xFF7c5cbf).withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5));

    // Couche glow serrée (plus intense au centre)
    final innerPyramid = Path()
      ..moveTo(apexX, apexY)
      ..lineTo(apexX - baseHW * 0.55, baseY)
      ..lineTo(apexX + baseHW * 0.55, baseY)
      ..close();
    canvas.drawPath(innerPyramid, Paint()
      ..color      = const Color(0xFF9d7de8).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2));

    // ── Étoiles ───────────────────────────────────────────────────────────────
    for (final s in bgStars) {
      final color = _starColors[s[4].toInt()];
      if (s[2] > 0.06) {
        canvas.drawCircle(Offset(s[0], s[1]), s[2] * 2.5,
          Paint()
            ..color      = color.withOpacity(s[3] * 0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.12),
        );
      }
      canvas.drawCircle(Offset(s[0], s[1]), s[2],
        Paint()..color = color.withOpacity(s[3] * 0.6),
      );
    }

    // ── Scanlines ultra-légères ───────────────────────────────────────────────
    final scanPaint = Paint()
      ..color       = const Color(0xFF7c5cbf).withOpacity(0.008)
      ..strokeWidth = 0.03
      ..style       = PaintingStyle.stroke;
    for (double y = 0; y < h; y += 0.22) {
      canvas.drawLine(Offset(0, y), Offset(w, y), scanPaint);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mur plat (haut, bas) — visuel uniquement
// ─────────────────────────────────────────────────────────────────────────────

class Wall extends PositionComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end) : super(position: Vector2.zero());

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF3a2060)
      ..strokeWidth = 0.15
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(_start.x, _start.y),
      Offset(_end.x, _end.y),
      paint,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paroi latérale droite (gauche / droite)
// ─────────────────────────────────────────────────────────────────────────────

class SideWall extends PositionComponent {
  final bool isLeft;

  SideWall({required this.isLeft}) : super(position: Vector2.zero());

  @override
  void render(Canvas canvas) {
    final wallX = isLeft ? 0.0 : PlinkoConfig.worldWidth;
    final top    = Offset(wallX, 0);
    final bottom = Offset(wallX, PlinkoConfig.slotBaseY - PlinkoConfig.slotWallHeight);

    // Glow derrière
    canvas.drawLine(top, bottom, Paint()
      ..color       = const Color(0xFF7c5cbf).withOpacity(0.45)
      ..strokeWidth = 0.55
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.35)
      ..style       = PaintingStyle.stroke);

    // Trait net
    canvas.drawLine(top, bottom, Paint()
      ..color       = const Color(0xFF9d7de8)
      ..strokeWidth = 0.10
      ..style       = PaintingStyle.stroke);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Picot (peg) — visuel uniquement, pas de physique au runtime
// ─────────────────────────────────────────────────────────────────────────────

class Peg extends PositionComponent {
  final Color _color;

  Peg(Vector2 pegPosition, {Color? color})
      : _color = color ?? const Color(0xFF9d7de8),
        super(position: pegPosition, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final r = PlinkoConfig.pegRadius;

    // Halo atmosphérique — resserré, ne dépasse pas le rayon physique utile
    canvas.drawCircle(
      Offset.zero,
      r * 1.7,
      Paint()
        ..color      = _color.withOpacity(0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.7),
    );

    // Corps du picot — rayon physique exact
    canvas.drawCircle(Offset.zero, r, Paint()..color = _color);

    // Reflet (petit point blanc en haut à gauche)
    canvas.drawCircle(
      Offset(-r * 0.28, -r * 0.28),
      r * 0.28,
      Paint()..color = Colors.white.withOpacity(0.65),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Séparateur de case — mur vertical visuel
// ─────────────────────────────────────────────────────────────────────────────

class SlotDivider extends PositionComponent {
  final double _x;

  SlotDivider(this._x) : super(position: Vector2.zero());

  @override
  void render(Canvas canvas) {
    final top = Offset(_x, PlinkoConfig.slotBaseY - PlinkoConfig.slotWallHeight);
    final bottom = Offset(_x, PlinkoConfig.slotBaseY);
    final paint = Paint()
      ..color = const Color(0xFF7c5cbf)
      ..strokeWidth = PlinkoConfig.slotWallThickness
      ..style = PaintingStyle.stroke;
    canvas.drawLine(top, bottom, paint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Label de case — refonte visuelle Session 10
//
// Chaque case affiche :
//   - Un fond semi-transparent coloré (cyan ou or)
//   - L'icône "€" en petit en haut
//   - La valeur numérique en grand en dessous
//   - Jackpot : couleur or + étoile "✦" au lieu de "€"
// ─────────────────────────────────────────────────────────────────────────────

class SlotLabel extends PositionComponent {
  final int _index;

  // Dimensions de la case (en unités monde)
  static double get _w => PlinkoConfig.slotWidth;
  static double get _h => PlinkoConfig.slotWallHeight;

  SlotLabel(this._index)
      : super(
          position: Vector2(
            _index * PlinkoConfig.slotWidth + PlinkoConfig.slotWidth / 2,
            PlinkoConfig.slotBaseY - PlinkoConfig.slotWallHeight / 2,
          ),
          anchor: Anchor.center,
        );

  // Deux couleurs : or pour jackpot, cyan pour tout le reste.
  static Color _tierColor(String label, bool isJackpot) {
    if (isJackpot) return const Color(0xFFf0c040); // or — DESIGN.md
    return const Color(0xFF00c8ff);                 // cyan électrique
  }

  static Color _tierGlow(String label, bool isJackpot) {
    if (isJackpot) return const Color(0xFFf0c040);
    return const Color(0xFF00c8ff);
  }

  @override
  void render(Canvas canvas) {
    final label     = PlinkoConfig.slotLabelAt(_index);
    final isJackpot = PlinkoConfig.slotIsJackpot(_index);
    final color     = _tierColor(label, isJackpot);

    final w = _w - 0.08;
    final h = _h - 0.08;
    final radius = Radius.circular(h * 0.32); // coins arrondis "pill"

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      radius,
    );

    // ── Glow externe (halo coloré derrière la case) ───────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w + 0.15, height: h + 0.15),
        Radius.circular(h * 0.36),
      ),
      Paint()
        ..color      = color.withOpacity(isJackpot ? 0.45 : 0.20)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isJackpot ? 0.35 : 0.20),
    );

    // ── Fond dégradé vertical ─────────────────────────────────────────────────
    final gradRect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            color.withOpacity(isJackpot ? 0.28 : 0.16),
            const Color(0xFF08081a),
          ],
        ).createShader(gradRect),
    );

    // ── Bordure néon ──────────────────────────────────────────────────────────
    canvas.drawRRect(
      rrect,
      Paint()
        ..color       = color.withOpacity(isJackpot ? 0.90 : 0.60)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = isJackpot ? 0.07 : 0.045,
    );

    // ── Dim si une autre case est en surbrillance (jackpot) ───────────────────
    final highlighted = PlinkoConfig.highlightedSlotIndex;
    if (highlighted != null && _index != highlighted) {
      canvas.drawRRect(rrect, Paint()..color = const Color(0xCC000000));
    }

    // ── Label centré ──────────────────────────────────────────────────────────
    final fontSize = label.length > 4 ? 0.36 : (label.length > 3 ? 0.40 : 0.46);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color:      color,
          fontSize:   fontSize,
          fontWeight: FontWeight.w900,
          height:     1.0,
          shadows: [
            Shadow(color: color.withOpacity(0.9), blurRadius: 0.12),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// BoardBuilder — assemble tous les composants visuels du plateau
// ─────────────────────────────────────────────────────────────────────────────

class BoardBuilder {
  /// Couleur d'un picot selon sa rangée — dégradé cyan (haut) → violet (bas).
  static Color _rowColor(int row) {
    final total = PlinkoConfig.pegRowCount; // 14
    if (row < total ~/ 4)     return const Color(0xFF00e5ff); // cyan vif   — top
    if (row < total ~/ 2)     return const Color(0xFF9d7de8); // violet clair
    if (row < total * 3 ~/ 4) return const Color(0xFF7c5cbf); // violet moyen
    return const Color(0xFF5a3d9a);                            // violet sombre — bottom
  }


  static Background buildBackground() => Background();

  static List<PositionComponent> buildWalls() {
    return [
      // Mur du bas (plat)
      Wall(
        Vector2(0, PlinkoConfig.worldHeight),
        Vector2(PlinkoConfig.worldWidth, PlinkoConfig.worldHeight),
      ),
      // Parois gauche et droite droites
      SideWall(isLeft: true),
      SideWall(isLeft: false),
    ];
  }

  static List<Peg> buildPegs() {
    final pegs = <Peg>[];
    for (int row = 0; row < PlinkoConfig.pegRowCount; row++) {
      final isOdd = row % 2 == 0;
      final colCount =
          isOdd ? PlinkoConfig.pegColsOdd : PlinkoConfig.pegColsEven;
      // offsetX centré : garantit la symétrie quelle que soit la valeur de pegSpacingX
      final offsetX =
          isOdd ? PlinkoConfig.pegOffsetOdd : PlinkoConfig.pegOffsetEven;
      final y     = PlinkoConfig.pegStartY + row * PlinkoConfig.pegSpacingY;
      final color = _rowColor(row);

      for (int col = 0; col < colCount; col++) {
        final x = offsetX + col * PlinkoConfig.pegEffectiveSpacingX;
        pegs.add(Peg(Vector2(x, y), color: color));
      }
    }
    return pegs;
  }

  static List<SlotDivider> buildSlotDividers() {
    return List.generate(
      PlinkoConfig.slotCount + 1,
      (i) => SlotDivider(i * PlinkoConfig.slotWidth),
    );
  }

  static List<SlotLabel> buildSlotLabels() {
    return List.generate(PlinkoConfig.slotCount, (i) => SlotLabel(i));
  }

}
