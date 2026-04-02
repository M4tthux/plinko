/// Script offline — génère les trajectoires pré-calculées pour Plinko.
/// Balleck Team — à exécuter depuis la racine du projet Flutter :
///
///   dart run scripts/generate_trajectories.dart
///
/// Produit : assets/trajectories.json
/// Structure : 70 trajectoires (7 cases × 5 zones × 2 variantes)
/// Méthode   : brute force — 5000 essais par (zone, case), on garde les 2 meilleures.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

// ─── Constantes physiques (miroir exact de plinko_config.dart) ────────────────
// ⚠ Si tu modifies plinko_config.dart, mets à jour ces valeurs.
// Dernière sync : 2026-03-28 — config plateau validée (Session 3b)
const double worldWidth     = 18.0;
const double worldHeight    = 29.0;
const double gravity        = 18.0;
const double pegRadius      = 0.25;
const double pegSpacingX    = 3.0;   // était 2.0
const double pegSpacingY    = 1.5;   // était 1.0
const double pegStartY      = 5.0;
const int    pegRowCount    = 14;    // était 20
const int    pegColsOdd     = 6;     // était 9  (= worldWidth / pegSpacingX)
const int    pegColsEven    = 5;     // était 8  (= pegColsOdd - 1)
const double ballRadius     = 0.60;  // était 0.30
const double pegRestitution = 0.50;
const double wallRestitution= 0.55;
const double minWallKick    = 1.5;
const double funnelZoneW    = 2.5;
const double funnelForce    = 30.0;
const int    slotCount      = 7;
const double slotWidth      = worldWidth / slotCount;
const double slotBaseY      = worldHeight - 1.0;
const double slotWallHeight = 2.0;
const double ballStartY     = 1.5;
const int    zoneCount      = 5;
const double zoneWidth      = worldWidth / zoneCount;
const double dt             = 1 / 60;

// Restitution dans la zone des cases — plus faible que wallRestitution.
// Miroir du fix bug bocal dans plinko_game.dart (_resolveSlotDividerCollisions).
const double slotDividerRestitution = 0.15;

// Vitesse minimum de sortie après rebond picot — miroir du fix bug orbite.
const double minExitSpeed = 2.5;

// Zone de lancer clampée (même logique que plinko_game.dart)
const double launchMin = pegSpacingX / 2;               // 1.5
const double launchMax = worldWidth - pegSpacingX / 2;  // 16.5

// ─── Positions des picots ─────────────────────────────────────────────────────
List<List<double>> buildPegPositions() {
  final pegs = <List<double>>[];
  for (int row = 0; row < pegRowCount; row++) {
    final isOdd   = row % 2 == 0;
    final colCount = isOdd ? pegColsOdd : pegColsEven;
    final offsetX  = isOdd ? pegSpacingX / 2 : pegSpacingX;
    final y        = pegStartY + row * pegSpacingY;
    for (int col = 0; col < colCount; col++) {
      pegs.add([offsetX + col * pegSpacingX, y]);
    }
  }
  return pegs;
}

// ─── Simulation d'une trajectoire ─────────────────────────────────────────────
/// Simule et retourne la liste de frames [(x,y), ...] + case d'atterrissage.
/// Retourne null si la bille sort du monde sans atterrir.
({List<List<double>> frames, int slot})? simulate(
  double launchX,
  double initVx,
  List<List<double>> pegs,
  Random rng,
) {
  double px = launchX;
  double py = ballStartY;
  double vx = initVx;
  double vy = 0.0;

  final frames = <List<double>>[];
  const int stride = 1;  // toutes les frames — nécessaire pour l'interpolation linéaire (stride=2 faisait sauter la frame de rebond → bille traversait visuellement les picots)
  int frameCount = 0;

  const collisionDist   = ballRadius + pegRadius;
  const collisionDistSq = collisionDist * collisionDist;

  // Cooldown par picot — miroir de plinko_game.dart
  final pegCooldowns = <int, int>{};

  for (int i = 0; i < 4000; i++) {
    // Gravité
    vy += gravity * dt;
    px += vx * dt;
    py += vy * dt;

    // Rebond murs
    if (px < ballRadius) {
      px = ballRadius;
      vx = max(vx.abs() * wallRestitution, minWallKick);
    } else if (px > worldWidth - ballRadius) {
      px = worldWidth - ballRadius;
      vx = -max(vx.abs() * wallRestitution, minWallKick);
    }

    // Entonnoir
    if (py > pegStartY) {
      if (px < funnelZoneW) {
        vx += funnelForce * dt;
      } else if (px > worldWidth - funnelZoneW) {
        vx -= funnelForce * dt;
      }
    }

    // Collision picots — fix orbite v3 (miroir de plinko_game.dart)
    // Décomposition normale/tangentielle + cooldown par index de picot
    for (int pi = 0; pi < pegs.length; pi++) {
      final coolUntil = pegCooldowns[pi];
      if (coolUntil != null && frameCount < coolUntil) continue;

      final peg    = pegs[pi];
      final dx     = px - peg[0];
      final dy     = py - peg[1];
      final distSq = dx * dx + dy * dy;
      if (distSq < collisionDistSq && distSq > 0.0001) {
        final dist = sqrt(distSq);
        final nx   = dx / dist;
        final ny   = dy / dist;

        // Séparer avec gap généreux
        px = peg[0] + nx * (collisionDist + 0.1);
        py = peg[1] + ny * (collisionDist + 0.1);

        // Décomposition normale/tangentielle
        final dot  = vx * nx + vy * ny;
        final vtx  = vx - nx * dot; // tangente X
        final vty  = vy - ny * dot; // tangente Y

        // Réflexion normale + amortissement tangentiel
        vx = nx * (-dot.abs() * pegRestitution) + vtx * 0.5;
        vy = ny * (-dot.abs() * pegRestitution) + vty * 0.5;

        // Kick latéral contrôlé
        vx += (rng.nextDouble() - 0.5) * 0.6;

        // Vitesse sortante minimum
        final exitSpeed = vx * nx + vy * ny;
        if (exitSpeed < minExitSpeed) {
          final delta = minExitSpeed - exitSpeed;
          vx += nx * delta;
          vy += ny * delta;
        }

        // Cooldown — ignorer ce picot pendant 12 frames
        pegCooldowns[pi] = frameCount + 12;
      }
    }

    // Collision séparateurs de cases
    // Restitution faible (slotDividerRestitution) — fix bug bocal, miroir de plinko_game.dart
    if (py >= slotBaseY - slotWallHeight) {
      for (int s = 0; s <= slotCount; s++) {
        final divX = s * slotWidth;
        final dx   = px - divX;
        if (dx.abs() < ballRadius) {
          final sign = dx >= 0 ? 1.0 : -1.0;
          px = divX + sign * ballRadius;
          vx = -vx * slotDividerRestitution;
        }
      }
    }

    // Enregistrement (stride)
    if (frameCount % stride == 0) {
      frames.add([
        double.parse(px.toStringAsFixed(4)),
        double.parse(py.toStringAsFixed(4)),
      ]);
    }
    frameCount++;

    // Atterrissage
    if (py >= slotBaseY - ballRadius) {
      final slot = (px / slotWidth).clamp(0, slotCount - 1).floor();
      // Ajouter le frame final exact
      frames.add([double.parse(px.toStringAsFixed(4)), slotBaseY - ballRadius]);
      return (frames: frames, slot: slot);
    }
  }
  return null; // timeout
}

// ─── Main ─────────────────────────────────────────────────────────────────────
void main() async {
  print('🎯 Génération des trajectoires Plinko — Balleck Team');
  print('   $slotCount cases × $zoneCount zones × 2 variantes = ${slotCount * zoneCount * 2} trajectoires cibles\n');

  final pegs   = buildPegPositions();
  final rng    = Random(12345); // seed fixe pour reproductibilité
  final result = <Map<String, dynamic>>[];

  // Statistiques
  int found    = 0;
  int missing  = 0;

  for (int zoneIdx = 0; zoneIdx < zoneCount; zoneIdx++) {
    final zoneStart = (zoneIdx * zoneWidth).clamp(launchMin, launchMax);
    final zoneEnd   = ((zoneIdx + 1) * zoneWidth).clamp(launchMin, launchMax);

    for (int slotIdx = 0; slotIdx < slotCount; slotIdx++) {
      final candidates = <List<List<double>>>[];

      // Brute force : 5000 essais
      for (int trial = 0; trial < 5000 && candidates.length < 2; trial++) {
        final launchX = zoneStart + rng.nextDouble() * (zoneEnd - zoneStart);
        final initVx  = (rng.nextDouble() - 0.5) * 1.0; // légère impulsion initiale

        // Seed différent par essai pour varier l'aléa des picots
        final trialRng = Random(rng.nextInt(1 << 31));
        final sim = simulate(launchX, initVx, pegs, trialRng);

        if (sim != null && sim.slot == slotIdx) {
          candidates.add(sim.frames);
        }
      }

      if (candidates.isEmpty) {
        print('  ⚠ zone=$zoneIdx slot=$slotIdx → AUCUNE trajectoire trouvée');
        missing++;
        continue;
      }

      // On garde 1 ou 2 variantes
      for (int v = 0; v < candidates.length && v < 2; v++) {
        // Calcul du launch_x réel depuis le premier frame
        final lx = candidates[v].first[0];
        result.add({
          'slotIndex': slotIdx,
          'zoneIndex': zoneIdx,
          'launchX':   double.parse(lx.toStringAsFixed(4)),
          'frames':    candidates[v].map((f) => {'x': f[0], 'y': f[1]}).toList(),
        });
        found++;
      }

      final varCount = candidates.length.clamp(0, 2);
      print('  zone=$zoneIdx slot=$slotIdx → $varCount variante(s) '
            '(${candidates[0].length} frames)');
    }
  }

  // Écriture du JSON
  final output    = File('assets/trajectories.json');
  final jsonStr   = const JsonEncoder.withIndent('  ').convert(result);
  await output.writeAsString(jsonStr);

  print('\n✅ Terminé — $found trajectoires écrites, $missing manquantes');
  print('   → assets/trajectories.json (${(jsonStr.length / 1024).toStringAsFixed(1)} Ko)');
}
