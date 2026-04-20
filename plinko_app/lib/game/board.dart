import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, TextStyle, FontWeight, TextSpan, TextPainter, TextDirection, Color, RadialGradient, LinearGradient, Alignment, Shadow;
import 'package:google_fonts/google_fonts.dart';
import '../config/plinko_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background — Deep Arcade (Build 48)
// Noir quasi-uniforme + très légère caustique radiale pour éviter le plat mort.
// Aucune étoile, aucun gradient violet. Priorité -100.
// ─────────────────────────────────────────────────────────────────────────────

class Background extends PositionComponent {
  Background() : super(position: Vector2.zero(), priority: -100);

  @override
  void render(Canvas canvas) {
    final w = PlinkoConfig.worldWidth;
    final h = PlinkoConfig.worldHeight;

    // Noir profond uniforme sur toute la zone (avec marge pour couvrir le viewport)
    const mx = 14.0;
    const my = 10.0;
    final full = Rect.fromLTWH(-mx, -my, w + mx * 2, h + my * 2);
    canvas.drawRect(full, Paint()..color = const Color(0xFF08080F));

    // Caustique radiale très diffuse au centre-haut (évite le plat)
    final caustic = Rect.fromCircle(
      center: Offset(w / 2, h * 0.35),
      radius: h * 0.9,
    );
    canvas.drawRect(full, Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [
          const Color(0xFF18142A).withOpacity(0.55), // centre très légèrement plus clair
          const Color(0xFF08080F).withOpacity(0.0),   // fondu vers transparent
        ],
        stops: const [0.0, 1.0],
      ).createShader(caustic));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SideEdge — désactivé (Deep Arcade : pas de bord visuel)
// ─────────────────────────────────────────────────────────────────────────────

class SideEdge extends PositionComponent {
  SideEdge() : super(position: Vector2.zero(), priority: -90);

  @override
  void render(Canvas canvas) {
    // Pas de bords en direction Deep Arcade.
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LaunchHole — bille idle discrète sous le titre (magenta, pas dorée)
// ─────────────────────────────────────────────────────────────────────────────

class LaunchHole extends PositionComponent {
  LaunchHole()
      : super(
          position: Vector2(
            PlinkoConfig.worldWidth / 2,
            PlinkoConfig.ballStartY,
          ),
          anchor: Anchor.center,
          priority: -50,
        );

  @override
  void render(Canvas canvas) {
    final r = PlinkoConfig.ballRadius;
    const magenta = Color(0xFFFF2EB4);

    // Halo magenta diffus
    canvas.drawCircle(Offset.zero, r * 2.0, Paint()
      ..color      = magenta.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8));

    // Halo interne
    canvas.drawCircle(Offset.zero, r * 1.35, Paint()
      ..color      = magenta.withOpacity(0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.35));

    // Corps magenta
    final bodyRect = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(Offset.zero, r, Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: [
          Color(0xFFFFD6EE),
          Color(0xFFFF2EB4),
          Color(0xFF7A0E55),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bodyRect));

    // Reflet spéculaire
    canvas.drawCircle(
      Offset(-r * 0.3, -r * 0.35),
      r * 0.24,
      Paint()..color = Colors.white.withOpacity(0.75));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wall plat — visuel uniquement (désactivé en Deep Arcade)
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
        ..color       = const Color(0xFF1A1A28)
        ..strokeWidth = 0.08
        ..style       = PaintingStyle.stroke,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Picot (peg) — Deep Arcade : point blanc pur net, halo discret
// ─────────────────────────────────────────────────────────────────────────────

class Peg extends PositionComponent {
  // Glow flash au passage de la bille
  double _hitTimer = 0.0;
  static const double _hitDuration = 0.20;

  void triggerHit() {
    _hitTimer = _hitDuration;
  }

  Peg(Vector2 pegPosition)
      : super(position: pegPosition, anchor: Anchor.center);

  @override
  void update(double dt) {
    if (_hitTimer > 0) _hitTimer -= dt;
  }

  @override
  void render(Canvas canvas) {
    final r = PlinkoConfig.pegRadius;
    final hitProgress = (_hitTimer > 0) ? (_hitTimer / _hitDuration) : 0.0;

    // Halo blanc discret au repos, amplifié au hit
    final haloOpacity = 0.12 + hitProgress * 0.55;
    final haloRadius  = r * (1.7 + hitProgress * 1.1);
    canvas.drawCircle(
      Offset.zero,
      haloRadius,
      Paint()
        ..color      = Colors.white.withOpacity(haloOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * (0.8 + hitProgress * 0.6)),
    );

    // Corps — point blanc pur solide, légèrement plus petit (lisibilité écran épuré)
    canvas.drawCircle(
      Offset.zero,
      r * 0.72,
      Paint()..color = Colors.white,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SlotDivider — Deep Arcade : désactivé (les cases parlent via leur contour)
// ─────────────────────────────────────────────────────────────────────────────

class SlotDivider extends PositionComponent {
  final double _x;

  SlotDivider(this._x) : super(position: Vector2.zero());

  @override
  void render(Canvas canvas) {
    // Pas de séparateur visible — remplacé par le contour net des cases.
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SlotLabel — Deep Arcade (Build 48)
// Rectangle vertical à coins arrondis, fill sombre avec léger gradient,
// contour fin néon dans la couleur du multiplicateur. Pas de pièces flottantes,
// pas de reflet verre, hiérarchie via intensité du glow uniquement.
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
    final label     = PlinkoConfig.slotMultiplierLabel(_index);
    final isJackpot = PlinkoConfig.slotIsMajor(_index);
    final color     = PlinkoConfig.slotColorAt(_index);

    // Rectangle vertical (légère marge entre cases)
    final cw = _w - 0.06;
    final ch = _h - 0.04;
    final hw = cw / 2;
    final hh = ch / 2;
    final radius = Radius.circular(cw * 0.10);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTRB(-hw, -hh, hw, hh),
      radius,
    );

    // ── Glow externe — intensité proportionnelle à la désirabilité ─────────
    final glowOpacity = isJackpot ? 0.55 : (_index == 4 ? 0.10 : 0.22);
    final glowBlur    = isJackpot ? 0.45 : 0.25;
    canvas.drawRRect(rrect, Paint()
      ..color      = color.withOpacity(glowOpacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur));

    // ── Fill sombre avec léger dégradé vertical (haut plus clair teinté) ───
    final fillRect = Rect.fromLTRB(-hw, -hh, hw, hh);
    canvas.drawRRect(rrect, Paint()
      ..shader = LinearGradient(
        begin:  Alignment.topCenter,
        end:    Alignment.bottomCenter,
        colors: [
          Color.lerp(const Color(0xFF14101E), color, isJackpot ? 0.22 : 0.12)!.withOpacity(0.95),
          const Color(0xFF08060F).withOpacity(0.95),
        ],
      ).createShader(fillRect));

    // ── Contour fin néon ────────────────────────────────────────────────────
    canvas.drawRRect(rrect, Paint()
      ..color       = color.withOpacity(isJackpot ? 0.95 : 0.80)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = isJackpot ? 0.035 : 0.025);

    // ── Dim si une autre case est en surbrillance (debug config) ──────────
    final highlighted = PlinkoConfig.highlightedSlotIndex;
    if (highlighted != null && _index != highlighted) {
      canvas.drawRRect(rrect, Paint()..color = const Color(0xCC000000));
    }

    // ── Texte — blanc pur, sans-serif bold, pas de glow coloré ─────────────
    final sw = PlinkoConfig.slotWidth;
    final baseSize = label.length > 4 ? sw * 0.30
                   : label.length > 3 ? sw * 0.34
                   : sw * 0.40;
    final fontSize = isJackpot ? baseSize * 1.08 : baseSize;

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.spaceGrotesk(
          color:      Colors.white,
          fontSize:   fontSize,
          fontWeight: FontWeight.w700,
          height:     1.0,
          letterSpacing: -0.02,
          shadows: [
            Shadow(
              color: const Color(0xFF000000).withOpacity(0.60),
              blurRadius: 0.04,
              offset: const Offset(0.015, 0.02),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Centrage vertical : compensation visuelle pour chiffres sans-serif
    // (le line-box inclut du descent inutile → on shift légèrement vers le bas).
    final yOffset = -tp.height / 2 + fontSize * 0.18;
    tp.paint(canvas, Offset(-tp.width / 2, yOffset));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PlinkoTitle — Deep Arcade : blanc pur + soulignement cyan fin
// ─────────────────────────────────────────────────────────────────────────────

class PlinkoTitle extends PositionComponent {
  PlinkoTitle() : super(
    position: Vector2(PlinkoConfig.worldWidth / 2, 0.8),
    anchor: Anchor.center,
    priority: 10,
  );

  @override
  void render(Canvas canvas) {
    const cyan = Color(0xFF00D9FF);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'PLINKO',
        style: TextStyle(
          color:         Colors.white,
          fontSize:      1.1,
          fontWeight:    FontWeight.w900,
          letterSpacing: 0.18,
          height:        1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

    // Soulignement cyan fin sous le mot
    final lineY = tp.height / 2 + 0.12;
    final lineHalfW = tp.width * 0.42;

    // Glow diffus
    canvas.drawLine(
      Offset(-lineHalfW, lineY),
      Offset( lineHalfW, lineY),
      Paint()
        ..color       = cyan.withOpacity(0.55)
        ..strokeWidth = 0.10
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 0.08),
    );

    // Trait net
    canvas.drawLine(
      Offset(-lineHalfW, lineY),
      Offset( lineHalfW, lineY),
      Paint()
        ..color       = cyan
        ..strokeWidth = 0.035,
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// BoardBuilder — assemble tous les composants visuels du plateau
// ─────────────────────────────────────────────────────────────────────────────

class BoardBuilder {
  static Background buildBackground() => Background();

  static LaunchHole buildLaunchHole() => LaunchHole();

  static List<PositionComponent> buildWalls() {
    return [];
  }

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
