import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, TextStyle, FontWeight, TextSpan, TextPainter, TextDirection, Color, RadialGradient, LinearGradient, Alignment, Shadow;
import '../config/plinko_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background — fond sombre opaque (requis pour opacifier le canvas Flame sur Chrome)
// Priorité -100 : rendu avant tous les autres composants.
// ─────────────────────────────────────────────────────────────────────────────

class Background extends PositionComponent {
  Background() : super(position: Vector2.zero(), priority: -100);

  @override
  void render(Canvas canvas) {
    final w = PlinkoConfig.worldWidth;
    final h = PlinkoConfig.worldHeight;

    // Fond étendu pour couvrir tout le viewport (marges généreuses)
    const mx = 14.0;
    const my = 10.0;
    final full = Rect.fromLTWH(-mx, -my, w + mx * 2, h + my * 2);

    // Fond noir profond — tout l'espace visuel
    canvas.drawRect(full, Paint()..color = const Color(0xFF06040e));

    // Légère lueur violette très subtile en haut (derrière la zone de lancer)
    canvas.drawCircle(
      Offset(w / 2, PlinkoConfig.pegStartY - 2.0),
      w * 0.55,
      Paint()
        ..color      = const Color(0xFF3a1a70).withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BoardFrame — cadre néon inséré sur le fond (fond déborde de chaque côté)
// Priorité -90 : rendu juste après le fond, avant les picots.
// ─────────────────────────────────────────────────────────────────────────────

class BoardFrame extends PositionComponent {
  BoardFrame() : super(position: Vector2.zero(), priority: -90);

  @override
  void render(Canvas canvas) {
    final w = PlinkoConfig.worldWidth;
    const insetX   = 0.22;
    const insetTop = 0.55;
    final bottom   = PlinkoConfig.slotBaseY + 0.48;

    final rect   = Rect.fromLTRB(insetX, insetTop, w - insetX, bottom);
    const radius = Radius.circular(0.55);
    final rrect  = RRect.fromRectAndRadius(rect, radius);

    // Glow externe large
    canvas.drawRRect(rrect, Paint()
      ..color       = const Color(0xFF7c5cbf).withOpacity(0.48)
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.65)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 0.55);

    // Bordure principale néon violet/lilas
    canvas.drawRRect(rrect, Paint()
      ..color       = const Color(0xFFb08ae0)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 0.12);

    // Inner border subtil
    final innerRect = Rect.fromLTRB(
      insetX + 0.09, insetTop + 0.09,
      w - insetX - 0.09, bottom - 0.09,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(0.46)),
      Paint()
        ..color       = const Color(0xFF7c5cbf).withOpacity(0.22)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 0.044);

    // Coins accent — petits carrés lumineux aux 4 coins
    final cPaint = Paint()
      ..color = const Color(0xFFc8aaff)
      ..style = PaintingStyle.fill;
    const cs = 0.16;
    for (final pt in [
      Offset(insetX, insetTop),
      Offset(w - insetX, insetTop),
      Offset(insetX, bottom),
      Offset(w - insetX, bottom),
    ]) {
      canvas.drawRect(Rect.fromCenter(center: pt, width: cs, height: cs), cPaint);
    }

    // Accent top — petites barres horizontales de chaque côté du haut
    final barPaint = Paint()
      ..color       = const Color(0xFF7c5cbf).withOpacity(0.65)
      ..strokeWidth = 0.055
      ..style       = PaintingStyle.stroke;
    canvas.drawLine(Offset(insetX + 0.40, insetTop - 0.28),
                    Offset(insetX + 1.30, insetTop - 0.28), barPaint);
    canvas.drawLine(Offset(w - insetX - 0.40, insetTop - 0.28),
                    Offset(w - insetX - 1.30, insetTop - 0.28), barPaint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wall plat (bas) — visuel uniquement
// ─────────────────────────────────────────────────────────────────────────────

class Wall extends PositionComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end) : super(position: Vector2.zero());

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
      Offset(_start.x, _start.y),
      Offset(_end.x, _end.y),
      Paint()
        ..color       = const Color(0xFF3a2060)
        ..strokeWidth = 0.15
        ..style       = PaintingStyle.stroke,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Picot (peg) — sprite PNG (assets/images/rond.png)
// Taille visuelle : pegRadius × 3.2 (world units), physique inchangée (0.25).
// ─────────────────────────────────────────────────────────────────────────────

class Peg extends SpriteComponent {
  Peg(Vector2 pegPosition)
      : super(
          position: pegPosition,
          anchor:   Anchor.center,
          size:     Vector2.all(PlinkoConfig.pegRadius * 3.2),
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('rond.png');
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
    final top    = Offset(_x, PlinkoConfig.slotBaseY - PlinkoConfig.slotWallHeight);
    final bottom = Offset(_x, PlinkoConfig.slotBaseY);
    canvas.drawLine(top, bottom, Paint()
      ..color       = const Color(0xFF7c5cbf)
      ..strokeWidth = PlinkoConfig.slotWallThickness
      ..style       = PaintingStyle.stroke);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SlotLabel — coupe en verre stylisée (trapézoïdale, effet cristal)
//
// - Forme coupe : plus large en haut (rim), légèrement rétréci en bas
// - Jackpot : coupe plus haute (extension vers le haut) + pièces dorées flottantes
// - Shine : reflet diagonal pour l'effet verre
// - Typo : w900 + double ombre colorée
// ─────────────────────────────────────────────────────────────────────────────

class SlotLabel extends PositionComponent {
  final int _index;

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

  static Color _tierColor(String label, bool isJackpot) {
    if (isJackpot) return const Color(0xFFf0c040);
    return const Color(0xFF00c8ff);
  }

  @override
  void render(Canvas canvas) {
    final label     = PlinkoConfig.slotLabelAt(_index);
    final isJackpot = PlinkoConfig.slotIsJackpot(_index);
    final color     = _tierColor(label, isJackpot);

    // ── Dimensions de la coupe ────────────────────────────────────────────────
    final cw  = _w - 0.10;   // largeur utile
    final ch  = _h - 0.06;   // hauteur de base
    final hw  = cw / 2;
    final hh  = ch / 2;

    // Jackpot : légèrement plus large, même hauteur (pas de débordement)
    final widthBonus = isJackpot ? hw * 0.08 : 0.0;
    final topY  = -hh;
    final botY  = hh;
    final rimAdd   = (hw + widthBonus) * 0.07;   // évasement en haut (légère vasque)
    final shrink   = (hw + widthBonus) * 0.04;   // rétrécissement en bas
    final hwEff    = hw + widthBonus;

    // Chemin trapézoïdal coupe
    final cupPath = Path()
      ..moveTo(-(hwEff + rimAdd), topY)
      ..lineTo( (hwEff + rimAdd), topY)
      ..lineTo( (hwEff - shrink), botY)
      ..lineTo(-(hwEff - shrink), botY)
      ..close();

    final cupRect = Rect.fromLTRB(-(hwEff + rimAdd), topY, (hwEff + rimAdd), botY);

    // ── Glow ──────────────────────────────────────────────────────────────────
    canvas.drawPath(cupPath, Paint()
      ..color      = color.withOpacity(isJackpot ? 0.52 : 0.22)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isJackpot ? 0.44 : 0.24));

    // ── Corps — dégradé vertical ──────────────────────────────────────────────
    canvas.drawPath(cupPath, Paint()
      ..shader = LinearGradient(
        begin:  Alignment.topCenter,
        end:    Alignment.bottomCenter,
        colors: [
          color.withOpacity(isJackpot ? 0.36 : 0.19),
          const Color(0xFF06060f),
        ],
      ).createShader(cupRect));

    // ── Shine verre — reflet diagonal gauche ──────────────────────────────────
    canvas.save();
    canvas.clipPath(cupPath);
    canvas.drawLine(
      Offset(-(hwEff + rimAdd) + 0.12, topY + 0.09),
      Offset(-(hwEff + rimAdd) + 0.19, botY - 0.11),
      Paint()
        ..color       = Colors.white.withOpacity(0.23)
        ..strokeWidth = 0.19
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.07));
    canvas.restore();

    // ── Bordure néon (jackpot : double épaisseur + glow externe) ─────────────
    if (isJackpot) {
      // Glow externe doré
      canvas.drawPath(cupPath, Paint()
        ..color       = color.withOpacity(0.55)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 0.22
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.18));
    }
    canvas.drawPath(cupPath, Paint()
      ..color       = color.withOpacity(isJackpot ? 0.95 : 0.66)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = isJackpot ? 0.09 : 0.048);

    // ── Rim highlight — liseré brillant en haut ───────────────────────────────
    canvas.drawLine(
      Offset(-(hwEff + rimAdd) + 0.09, topY + 0.028),
      Offset( (hwEff + rimAdd) - 0.09, topY + 0.028),
      Paint()
        ..color       = Colors.white.withOpacity(0.48)
        ..strokeWidth = 0.030);

    // ── Dim si une autre case est en surbrillance ─────────────────────────────
    final highlighted = PlinkoConfig.highlightedSlotIndex;
    if (highlighted != null && _index != highlighted) {
      canvas.drawPath(cupPath, Paint()..color = const Color(0xCC000000));
    }

    // ── Pièces flottantes (jackpot uniquement) ────────────────────────────────
    if (isJackpot) {
      _drawCoins(canvas, topY);
    }

    // ── Texte centré dans la coupe ────────────────────────────────────────────
    const textY = 0.0; // toutes les coupes ont la même hauteur
    final baseSize = label.length > 4 ? 0.34
                   : label.length > 3 ? 0.38
                   : 0.44;
    final fontSize = isJackpot ? baseSize * 1.10 : baseSize;

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color:      color,
          fontSize:   fontSize,
          fontWeight: FontWeight.w900,
          height:     1.0,
          shadows: [
            Shadow(color: const Color(0xFF000000).withOpacity(0.75),
                   blurRadius: 0.04, offset: const Offset(0.02, 0.025)),
            Shadow(color: color.withOpacity(0.95), blurRadius: 0.14),
            Shadow(color: color.withOpacity(0.55), blurRadius: 0.32),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(-tp.width / 2, textY - tp.height / 2));
  }

  // ── Pièces dorées flottant au-dessus de la coupe jackpot ──────────────────
  void _drawCoins(Canvas canvas, double topY) {
    // [dx, dy relatifs au centre du slot, rayon]
    final coins = [
      [-0.44, topY - 0.16, 0.113],
      [ 0.06, topY - 0.37, 0.124],
      [ 0.48, topY - 0.12, 0.106],
      [-0.16, topY - 0.51, 0.094],
      [ 0.28, topY - 0.43, 0.111],
    ];

    for (final c in coins) {
      final cx = c[0], cy = c[1], cr = c[2];
      final coinRect = Rect.fromCircle(center: Offset(cx, cy), radius: cr);

      // Glow doré
      canvas.drawCircle(Offset(cx, cy), cr * 2.0, Paint()
        ..color      = const Color(0xFFf0c040).withOpacity(0.33)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.09));

      // Corps sphère pièce — dégradé radial
      canvas.drawCircle(Offset(cx, cy), cr, Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.30, -0.38),
          radius: 0.92,
          colors: [Color(0xFFffe78a), Color(0xFFf0c040), Color(0xFFb87800)],
          stops:  [0.0, 0.44, 1.0],
        ).createShader(coinRect));  // NB: Rect.fromCircle via coinRect

      // Liseré
      canvas.drawCircle(Offset(cx, cy), cr, Paint()
        ..color       = const Color(0xFFd4900a).withOpacity(0.82)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 0.014);

      // Reflet spéculaire
      canvas.drawCircle(
        Offset(cx - cr * 0.24, cy - cr * 0.30),
        cr * 0.28,
        Paint()..color = Colors.white.withOpacity(0.74));
    }
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// BoardBuilder — assemble tous les composants visuels du plateau
// ─────────────────────────────────────────────────────────────────────────────

class BoardBuilder {
  /// Couleur d'un picot selon sa rangée — dégradé cyan (haut) → violet (bas).
  static Color _rowColor(int row) {
    final total = PlinkoConfig.pegRowCount;
    if (row < total ~/ 4)     return const Color(0xFF00e5ff); // cyan vif   — top
    if (row < total ~/ 2)     return const Color(0xFF9d7de8); // violet clair
    if (row < total * 3 ~/ 4) return const Color(0xFF7c5cbf); // violet moyen
    return const Color(0xFF5a3d9a);                            // violet sombre — bottom
  }

  static Background buildBackground() => Background();

  static List<PositionComponent> buildWalls() {
    // BoardFrame supprimé — remplacé par assets/images/plateau.png (Flutter overlay)
    return [];
  }

  static List<Peg> buildPegs() {
    final pegs = <Peg>[];
    for (int row = 0; row < PlinkoConfig.pegRowCount; row++) {
      final isOdd    = row % 2 == 0;
      final colCount = isOdd ? PlinkoConfig.pegColsOdd : PlinkoConfig.pegColsEven;
      final offsetX  = isOdd ? PlinkoConfig.pegOffsetOdd : PlinkoConfig.pegOffsetEven;
      final y        = PlinkoConfig.pegStartY + row * PlinkoConfig.pegSpacingY;

      for (int col = 0; col < colCount; col++) {
        final x = offsetX + col * PlinkoConfig.pegEffectiveSpacingX;
        pegs.add(Peg(Vector2(x, y)));
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
