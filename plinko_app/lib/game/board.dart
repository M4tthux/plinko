import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, TextStyle, FontWeight, TextSpan, TextPainter, TextDirection, Color, RadialGradient, Alignment;
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

    // Base quasi-noire
    canvas.drawRect(rect, Paint()..color = const Color(0xFF06060f));

    // Dégradé radial — cœur violet profond
    final gradient = RadialGradient(
      center: const Alignment(0.0, -0.2),
      radius: 0.80,
      colors: const [Color(0xFF180d38), Color(0xFF06060f)],
      stops:  const [0.0, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Nébuleuses
    for (final n in bgNebulae) {
      final color = _nebulaColors[n[4].toInt()];
      canvas.drawCircle(
        Offset(n[0], n[1]), n[2],
        Paint()
          ..color      = color.withOpacity(n[3])
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, n[2] * 0.6),
      );
    }

    // Étoiles
    for (final s in bgStars) {
      final color = _starColors[s[4].toInt()];
      if (s[2] > 0.06) {
        canvas.drawCircle(Offset(s[0], s[1]), s[2] * 2.5,
          Paint()
            ..color      = color.withOpacity(s[3] * 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.12),
        );
      }
      canvas.drawCircle(Offset(s[0], s[1]), s[2],
        Paint()..color = color.withOpacity(s[3]),
      );
    }

    // Scanlines ultra-légères
    final scanPaint = Paint()
      ..color       = const Color(0xFF00c8ff).withOpacity(0.012)
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
      : _color = color ?? const Color(0xFF00c8ff),
        super(position: pegPosition, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final r    = PlinkoConfig.pegRadius;
    final capW = r * 1.3;
    final capH = r * 2.8;

    final capsule = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: capW, height: capH),
      Radius.circular(capW / 2),
    );

    // Halo néon (capsule plus large)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: capW * 3.0, height: capH * 2.2),
        Radius.circular(capW),
      ),
      Paint()
        ..color      = _color.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5),
    );

    // Corps capsule
    canvas.drawRRect(capsule, Paint()..color = _color);

    // Reflet interne
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-capW * 0.12, -capH * 0.22),
        width:  capW * 0.42,
        height: capH * 0.30,
      ),
      Paint()..color = Colors.white.withOpacity(0.55),
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

  // Couleur par palier de gain — purement visuel
  static Color _tierColor(String label, bool isJackpot) {
    if (isJackpot) return const Color(0xFFFFD700);
    final val = double.tryParse(label.replaceAll('€', '').trim()) ?? 0;
    if (val <= 2)  return const Color(0xFF00e676); // vert   — petits lots
    if (val <= 10) return const Color(0xFFc6ff00); // lime   — lots moyens
    if (val <= 50) return const Color(0xFFffa726); // orange — grands lots
    return const Color(0xFFff4488);                // rose   — très grands lots
  }

  static Color _tierGlow(String label, bool isJackpot) {
    if (isJackpot) return const Color(0xFFFFA500);
    final val = double.tryParse(label.replaceAll('€', '').trim()) ?? 0;
    if (val <= 2)  return const Color(0xFF00c853);
    if (val <= 10) return const Color(0xFF76ff03);
    if (val <= 50) return const Color(0xFFff6d00);
    return const Color(0xFFe91e63);
  }

  @override
  void render(Canvas canvas) {
    final label     = PlinkoConfig.slotLabelAt(_index);
    final isJackpot = PlinkoConfig.slotIsJackpot(_index);

    final color  = _tierColor(label, isJackpot);
    final color2 = _tierGlow(label, isJackpot);

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
