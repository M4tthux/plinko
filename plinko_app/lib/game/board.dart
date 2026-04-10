import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, TextStyle, FontWeight, TextSpan, TextPainter, TextDirection, Color, RadialGradient, LinearGradient, Alignment, Shadow;
import '../config/plinko_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background — fond radial gradient (centre éclairci → bords sombres)
// Priorité -100 : rendu avant tous les autres composants.
// ─────────────────────────────────────────────────────────────────────────────

class Background extends PositionComponent {
  Background() : super(position: Vector2.zero(), priority: -100);

  @override
  void render(Canvas canvas) {
    final w = PlinkoConfig.worldWidth;
    final h = PlinkoConfig.worldHeight;

    // Fond noir profond — couvre tout le viewport
    const mx = 14.0;
    const my = 10.0;
    final full = Rect.fromLTWH(-mx, -my, w + mx * 2, h + my * 2);
    canvas.drawRect(full, Paint()..color = const Color(0xFF060610));

    // Radial gradient central — profondeur
    final center = Offset(w / 2, h * 0.45);
    final gradientRect = Rect.fromCircle(center: center, radius: h * 0.7);
    canvas.drawOval(gradientRect, Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: const [
          Color(0xFF1a1a3a), // centre plus clair
          Color(0xFF0f0f2a), // mi-distance
          Color(0xFF060610), // bords sombres
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(gradientRect));

    // Lueur violette haute (zone de lancer) — plus intense
    canvas.drawCircle(
      Offset(w / 2, PlinkoConfig.pegStartY - 2.5),
      w * 0.6,
      Paint()
        ..color      = const Color(0xFF2a1050).withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
    );

    // Lueur cyan basse (zone des cases) — plus intense
    canvas.drawCircle(
      Offset(w / 2, PlinkoConfig.slotBaseY),
      w * 0.45,
      Paint()
        ..color      = const Color(0xFF003050).withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SideEdge — bordures latérales subtiles (remplace le cadre rectangulaire)
// ─────────────────────────────────────────────────────────────────────────────

class SideEdge extends PositionComponent {
  SideEdge() : super(position: Vector2.zero(), priority: -90);

  @override
  void render(Canvas canvas) {
    final w = PlinkoConfig.worldWidth;
    final topY = PlinkoConfig.pegStartY - 1.5;
    final bottomY = PlinkoConfig.slotBaseY + 0.3;

    final edgePaint = Paint()
      ..color       = const Color(0xFF7c5cbf).withOpacity(0.30)
      ..strokeWidth = 0.06
      ..style       = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color       = const Color(0xFF7c5cbf).withOpacity(0.12)
      ..strokeWidth = 0.30
      ..style       = PaintingStyle.stroke
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.25);

    // Bord gauche
    canvas.drawLine(Offset(0.08, topY), Offset(0.08, bottomY), glowPaint);
    canvas.drawLine(Offset(0.08, topY), Offset(0.08, bottomY), edgePaint);

    // Bord droit
    canvas.drawLine(Offset(w - 0.08, topY), Offset(w - 0.08, bottomY), glowPaint);
    canvas.drawLine(Offset(w - 0.08, topY), Offset(w - 0.08, bottomY), edgePaint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LaunchHole — trou sombre en haut du plateau d'où émerge la bille
//
// Rendu visuel uniquement (aucune physique). Donne l'illusion que la bille
// vient d'un conduit caché derrière le plateau. Centré sur ballStartY.
// ─────────────────────────────────────────────────────────────────────────────

class LaunchHole extends PositionComponent {
  LaunchHole()
      : super(
          position: Vector2(
            PlinkoConfig.worldWidth / 2,
            PlinkoConfig.ballStartY,
          ),
          anchor: Anchor.center,
          priority: -50, // derrière les picots, devant le fond
        );

  @override
  void render(Canvas canvas) {
    // Rayon calqué sur la bille (légèrement plus grand pour la marge visuelle)
    final rBall = PlinkoConfig.ballRadius;
    final rOuter = rBall * 1.75; // ouverture visible
    final rInner = rBall * 1.25; // bord intérieur sombre
    final rCore  = rBall * 1.05; // cœur noir

    // ── Anneau extérieur : liseré violet glow (bordure du conduit) ──────────
    canvas.drawCircle(
      Offset.zero,
      rOuter + 0.05,
      Paint()
        ..color       = const Color(0xFF9d7cdf).withOpacity(0.28)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 0.10
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.22),
    );

    // ── Plaque métallique extérieure (dégradé radial gris-violet) ──────────
    final plateRect = Rect.fromCircle(center: Offset.zero, radius: rOuter);
    canvas.drawCircle(Offset.zero, rOuter, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 1.0,
        colors: const [
          Color(0xFF3a2a5c),
          Color(0xFF1e1433),
          Color(0xFF0a0616),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(plateRect));

    // ── Liseré intérieur net (bord de l'ouverture) ─────────────────────────
    canvas.drawCircle(
      Offset.zero,
      rInner,
      Paint()
        ..color       = const Color(0xFF7c5cbf).withOpacity(0.55)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 0.045,
    );

    // ── Ombre interne (profondeur du trou) ─────────────────────────────────
    final holeRect = Rect.fromCircle(center: Offset.zero, radius: rInner);
    canvas.drawCircle(Offset.zero, rInner, Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.35),
        radius: 1.0,
        colors: const [
          Color(0xFF1a0f2e),
          Color(0xFF050208),
          Color(0xFF000000),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(holeRect));

    // ── Cœur noir profond ──────────────────────────────────────────────────
    canvas.drawCircle(
      Offset.zero,
      rCore,
      Paint()..color = const Color(0xFF000000),
    );

    // ── Reflet spéculaire subtil sur la plaque (haut-gauche) ───────────────
    canvas.drawCircle(
      Offset(-rOuter * 0.35, -rOuter * 0.55),
      rOuter * 0.22,
      Paint()
        ..color       = Colors.white.withOpacity(0.18)
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.08),
    );
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
// Picot (peg) — blanc/gris uniforme, gros halo, dégradé radial, spéculaire
// ─────────────────────────────────────────────────────────────────────────────

class Peg extends PositionComponent {
  final Color _color;

  // ── Glow flash au passage de la bille ──────────────────────────────────
  double _hitTimer = 0.0;
  static const double _hitDuration = 0.20; // 200ms

  void triggerHit() {
    _hitTimer = _hitDuration;
  }

  Peg(Vector2 pegPosition, {Color? color})
      : _color = color ?? const Color(0xFFd0d0e0),
        super(position: pegPosition, anchor: Anchor.center);

  @override
  void update(double dt) {
    if (_hitTimer > 0) _hitTimer -= dt;
  }

  @override
  void render(Canvas canvas) {
    final r = PlinkoConfig.pegRadius;
    final hitProgress = (_hitTimer > 0) ? (_hitTimer / _hitDuration) : 0.0;

    // Halo atmosphérique — 2.2× rayon, plus intense si hit
    final haloOpacity = 0.30 + hitProgress * 0.50;
    final haloRadius  = r * (2.2 + hitProgress * 1.0);
    canvas.drawCircle(
      Offset.zero,
      haloRadius,
      Paint()
        ..color      = Color.lerp(_color, Colors.white, hitProgress * 0.7)!.withOpacity(haloOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * (1.0 + hitProgress * 0.6)),
    );

    // Corps — dégradé radial blanc→gris, plus blanc si hit
    final bodyRect = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(Offset.zero, r, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.35),
        radius: 0.85,
        colors: [
          Color.lerp(const Color(0xFFf0f0ff), Colors.white, hitProgress)!,
          Color.lerp(const Color(0xFFd0d0e0), Colors.white, hitProgress * 0.8)!,
          Color.lerp(const Color(0xFF9898b0), const Color(0xFFd0d0e0), hitProgress)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bodyRect));

    // Reflet spéculaire — plus gros et lumineux
    canvas.drawCircle(
      Offset(-r * 0.25, -r * 0.28),
      r * 0.35,
      Paint()..color = Colors.white.withOpacity(0.80 + hitProgress * 0.20),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Séparateur de case — mur vertical avec glow subtil
// ─────────────────────────────────────────────────────────────────────────────

class SlotDivider extends PositionComponent {
  final double _x;

  SlotDivider(this._x) : super(position: Vector2.zero());

  @override
  void render(Canvas canvas) {
    final topY    = PlinkoConfig.slotBaseY - PlinkoConfig.slotWallHeight;
    final bottomY = PlinkoConfig.slotBaseY;

    // Glow subtil
    canvas.drawLine(Offset(_x, topY), Offset(_x, bottomY), Paint()
      ..color       = const Color(0xFF7c5cbf).withOpacity(0.18)
      ..strokeWidth = 0.20
      ..style       = PaintingStyle.stroke
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.12));

    // Ligne principale
    canvas.drawLine(Offset(_x, topY), Offset(_x, bottomY), Paint()
      ..color       = const Color(0xFF9080c0).withOpacity(0.55)
      ..strokeWidth = PlinkoConfig.slotWallThickness * 1.5
      ..style       = PaintingStyle.stroke);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SlotLabel — coupe en verre stylisée (trapézoïdale, effet cristal)
//
// Refonte visuelle : fond plus opaque, bordures plus épaisses, glow sur
// TOUTES les cases, texte plus gros.
// ─────────────────────────────────────────────────────────────────────────────

class SlotLabel extends PositionComponent {
  final int _index;

  static double get _w => PlinkoConfig.slotWidth;
  static double get _h => PlinkoConfig.slotWallHeight;

  SlotLabel(this._index)
      : super(
          position: Vector2(
            PlinkoConfig.slotStartX + _index * PlinkoConfig.slotWidth + PlinkoConfig.slotWidth / 2,
            PlinkoConfig.slotBaseY - PlinkoConfig.slotWallHeight / 2,
          ),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    // Lire l'assignation dynamique
    final lot = (PlinkoConfig.currentSlotAssignment.length > _index)
        ? PlinkoConfig.currentSlotAssignment[_index]
        : null;
    final label     = lot?.name ?? PlinkoConfig.slotLabelAt(_index);
    final isJackpot = lot?.isJackpot ?? PlinkoConfig.slotIsJackpot(_index);
    final color     = PlinkoConfig.slotColorAt(_index);

    // ── Dimensions de la coupe ────────────────────────────────────────────────
    final cw  = _w - 0.08;   // largeur utile (réduit la marge)
    final ch  = _h - 0.04;
    final hw  = cw / 2;
    final hh  = ch / 2;

    final widthBonus = isJackpot ? hw * 0.08 : 0.0;
    final topY  = -hh;
    final botY  = hh;
    final rimAdd   = (hw + widthBonus) * 0.07;
    final shrink   = (hw + widthBonus) * 0.04;
    final hwEff    = hw + widthBonus;

    // Chemin trapézoïdal coupe
    final cupPath = Path()
      ..moveTo(-(hwEff + rimAdd), topY)
      ..lineTo( (hwEff + rimAdd), topY)
      ..lineTo( (hwEff - shrink), botY)
      ..lineTo(-(hwEff - shrink), botY)
      ..close();

    final cupRect = Rect.fromLTRB(-(hwEff + rimAdd), topY, (hwEff + rimAdd), botY);

    // ── Glow sur TOUTES les cases ─────────────────────────────────────────────
    canvas.drawPath(cupPath, Paint()
      ..color      = color.withOpacity(isJackpot ? 0.60 : 0.30)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isJackpot ? 0.55 : 0.30));

    // ── Corps — dégradé vertical, plus opaque ─────────────────────────────────
    canvas.drawPath(cupPath, Paint()
      ..shader = LinearGradient(
        begin:  Alignment.topCenter,
        end:    Alignment.bottomCenter,
        colors: [
          color.withOpacity(isJackpot ? 0.45 : 0.28),
          const Color(0xFF06060f).withOpacity(0.85),
        ],
      ).createShader(cupRect));

    // ── Shine verre — reflet diagonal gauche ──────────────────────────────────
    canvas.save();
    canvas.clipPath(cupPath);
    canvas.drawLine(
      Offset(-(hwEff + rimAdd) + 0.10, topY + 0.07),
      Offset(-(hwEff + rimAdd) + 0.17, botY - 0.09),
      Paint()
        ..color       = Colors.white.withOpacity(0.28)
        ..strokeWidth = 0.22
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.07));
    canvas.restore();

    // ── Bordure néon — toutes les cases, plus épaisse ─────────────────────────
    if (isJackpot) {
      // Glow externe doré intense
      canvas.drawPath(cupPath, Paint()
        ..color       = color.withOpacity(0.65)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 0.28
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.22));
    } else {
      // Glow subtil sur les cases normales
      canvas.drawPath(cupPath, Paint()
        ..color       = color.withOpacity(0.30)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 0.16
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.12));
    }
    canvas.drawPath(cupPath, Paint()
      ..color       = color.withOpacity(isJackpot ? 0.95 : 0.75)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = isJackpot ? 0.12 : 0.07);

    // ── Rim highlight — liseré brillant en haut ───────────────────────────────
    canvas.drawLine(
      Offset(-(hwEff + rimAdd) + 0.09, topY + 0.028),
      Offset( (hwEff + rimAdd) - 0.09, topY + 0.028),
      Paint()
        ..color       = Colors.white.withOpacity(0.55)
        ..strokeWidth = 0.035);

    // ── Dim si une autre case est en surbrillance ─────────────────────────────
    final highlighted = PlinkoConfig.highlightedSlotIndex;
    if (highlighted != null && _index != highlighted) {
      canvas.drawPath(cupPath, Paint()..color = const Color(0xCC000000));
    }

    // ── Pièces flottantes (jackpot uniquement) ────────────────────────────────
    if (isJackpot) {
      _drawCoins(canvas, topY);
    }

    // ── Texte centré — plus gros ──────────────────────────────────────────────
    const textY = 0.0;
    final baseSize = label.length > 4 ? 0.40
                   : label.length > 3 ? 0.46
                   : 0.52;
    final fontSize = isJackpot ? baseSize * 1.15 : baseSize;

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color:      isJackpot ? const Color(0xFFffe680) : Colors.white,
          fontSize:   fontSize,
          fontWeight: FontWeight.w900,
          height:     1.0,
          shadows: [
            Shadow(color: const Color(0xFF000000).withOpacity(0.80),
                   blurRadius: 0.05, offset: const Offset(0.02, 0.025)),
            Shadow(color: color.withOpacity(0.95), blurRadius: 0.18),
            Shadow(color: color.withOpacity(0.60), blurRadius: 0.40),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(-tp.width / 2, textY - tp.height / 2));
  }

  // ── Pièces dorées flottant au-dessus de la coupe jackpot ──────────────────
  void _drawCoins(Canvas canvas, double topY) {
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

      // Corps sphère pièce
      canvas.drawCircle(Offset(cx, cy), cr, Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.30, -0.38),
          radius: 0.92,
          colors: [Color(0xFFffe78a), Color(0xFFf0c040), Color(0xFFb87800)],
          stops:  [0.0, 0.44, 1.0],
        ).createShader(coinRect));

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
// PlinkoTitle — label "PLINKO" en haut du plateau
// ─────────────────────────────────────────────────────────────────────────────

class PlinkoTitle extends PositionComponent {
  PlinkoTitle() : super(
    position: Vector2(PlinkoConfig.worldWidth / 2, 0.8),
    anchor: Anchor.center,
    priority: 10,
  );

  @override
  void render(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'PLINKO',
        style: TextStyle(
          color:      const Color(0xFFe8d0ff),
          fontSize:   1.1,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.25,
          height:     1.0,
          shadows: [
            Shadow(color: const Color(0xFF7c5cbf).withOpacity(0.90), blurRadius: 0.40),
            Shadow(color: const Color(0xFF7c5cbf).withOpacity(0.50), blurRadius: 0.80),
            Shadow(color: const Color(0xFF000000).withOpacity(0.60), blurRadius: 0.06,
                   offset: const Offset(0.03, 0.03)),
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
  static Background buildBackground() => Background();

  static LaunchHole buildLaunchHole() => LaunchHole();

  static List<PositionComponent> buildWalls() {
    return []; // pas de contour — bords ouverts
  }

  /// Grille triangulaire : rang R contient R+1 picots (à partir de startRow).
  /// Picots blancs/gris uniformes.
  static List<Peg> buildPegs() {
    final pegs = <Peg>[];
    for (int row = PlinkoConfig.startRow; row < PlinkoConfig.rows; row++) {
      final colCount = PlinkoConfig.pegCount(row);
      final y = PlinkoConfig.pegY(row);
      for (int col = 0; col < colCount; col++) {
        final x = PlinkoConfig.pegX(row, col);
        pegs.add(Peg(Vector2(x, y)));
      }
    }
    return pegs;
  }

  /// Séparateurs entre les cases.
  static List<SlotDivider> buildSlotDividers() {
    return List.generate(
      PlinkoConfig.slotCount + 1,
      (i) => SlotDivider(PlinkoConfig.slotStartX + i * PlinkoConfig.slotWidth),
    );
  }

  static List<SlotLabel> buildSlotLabels() {
    return List.generate(PlinkoConfig.slotCount, (i) => SlotLabel(i));
  }

  static PlinkoTitle buildTitle() => PlinkoTitle();
}
