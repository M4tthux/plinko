import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/trajectory.dart';
import '../config/plinko_config.dart';

/// Charge les trajectoires pré-calculées depuis assets/trajectories.json.
/// Implémenté en Dev Session 2.
///
/// Structure : 70 trajectoires (7 cases × 5 zones × 2 options)
class TrajectoryLoader {
  static List<Trajectory>? _trajectories;

  /// Charge toutes les trajectoires depuis le fichier JSON.
  /// À appeler au démarrage de l'app (une seule fois).
  static Future<void> load() async {
    final raw = await rootBundle.loadString('assets/trajectories.json');
    final data = jsonDecode(raw) as List;
    _trajectories = data
        .map((t) => Trajectory.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Sélectionne une trajectoire pour une case cible et une position X du doigt.
  ///
  /// Logique :
  /// 1. Détecter la zone (0–4) depuis la position X
  /// 2. Filtrer les trajectoires correspondant à (slotIndex, zoneIndex)
  /// 3. Choisir aléatoirement parmi les options disponibles (max 2)
  static Trajectory? select({
    required int slotIndex,
    required double fingerX,
  }) {
    if (_trajectories == null) return null;
    final zone = PlinkoConfig.zoneForX(fingerX);
    final candidates = _trajectories!
        .where((t) => t.slotIndex == slotIndex && t.zoneIndex == zone)
        .toList();
    if (candidates.isEmpty) return null;
    candidates.shuffle();
    return candidates.first;
  }

  static bool get isLoaded => _trajectories != null;

  /// Vide le cache — à appeler quand la config du plateau change.
  static void clear() => _trajectories = null;
}
