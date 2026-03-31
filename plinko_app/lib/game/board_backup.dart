import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, TextStyle, FontWeight, TextSpan, TextPainter, TextDirection, Color;
import '../config/plinko_config.dart';

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
    final paint = Paint()
      ..color = const Color(0xFF7c5cbf)
      ..strokeWidth = 0.12
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(wallX, 0),
      Offset(wallX, PlinkoConfig.slotBaseY - PlinkoConfig.slotWallHeight),
      paint,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Picot (peg) — visuel uniquement, pas de physique au runtime
// ─────────────────────────────────────────────────────────────────────────────

class Peg extends PositionComponent {
  final Color _color;

  Peg(Vector2 pegPosition, {Color? color})
      : _color = color ?? const Color(0xFF00c8ff),
        super(position: pegPosition, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Halo néon
    final haloPaint = Paint()
      ..color = _color.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4);
    canvas.drawCircle(Offset.zero, PlinkoConfig.pegRadius * 2.2, haloPaint);

    // Corps du picot
    final bodyPaint = Paint()..color = _color;
    canvas.drawCircle(Offset.zero, PlinkoConfig.pegRadius, bodyPaint);

    // Reflet
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(
      Offset(-PlinkoConfig.pegRadius * 0.3, -PlinkoConfig.pegRadius * 0.3),
      PlinkoConfig.pegRadius * 0.3,
      highlightPaint,
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

  @override
  void render(Canvas canvas) {
    final label     = PlinkoConfig.slotLabelAt(_index);
    final isJackpot = PlinkoConfig.slotIsJackpot(_index);

    final color  = isJackpot ? const Color(0xFFFFD700) : const Color(0xFF00c8ff);
    final color2 = isJackpot ? const Color(0xFFFFA500) : const Color(0xFF7c5cbf);

    // ── Fond de case — angles droits ──────────────────────────────────────────
    final bgRect = Rect.fromCenter(
      center: Offset.zero,
      width:  _w - 0.10,
      height: _h - 0.06,
    );
    canvas.drawRect(bgRect, Paint()..color = const Color(0xFF0d0d28));
    canvas.drawRect(
      bgRect,
      Paint()
        ..color       = color.withOpacity(isJackpot ? 0.70 : 0.45)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 0.055,
    );
    // Glow intérieur
    canvas.drawRect(
      bgRect,
      Paint()
        ..color      = color.withOpacity(isJackpot ? 0.10 : 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3),
    );

    // ── Label complet centré ("1€", "50€", "1000€") ──────────────────────────
    // fontSize uniforme à 0.40 — valeur confirmée correctement centrée par le jackpot.
    // Taille légèrement réduite pour les labels longs (4+ chars).
    final fontSize = label.length > 3 ? 0.40 : 0.44;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color:      color,
          fontSize:   fontSize,
          fontWeight: FontWeight.w900,
          height:     1.0, // supprime le leading supplémentaire qui décale vers le haut
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Centrage horizontal + vertical
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// BoardBuilder — assemble tous les composants visuels du plateau
// ─────────────────────────────────────────────────────────────────────────────

class BoardBuilder {
  static const _pegColors = [
    Color(0xFF00c8ff),
    Color(0xFF7c5cbf),
    Color(0xFF00ff88),
    Color(0xFFff4488),
    Color(0xFFffaa00),
  ];

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
      final y = PlinkoConfig.pegStartY + row * PlinkoConfig.pegSpacingY;
      final color = _pegColors[row % _pegColors.length];

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
