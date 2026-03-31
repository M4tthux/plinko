/// Modèle d'un lot (récompense) de la table de prix Plinko.
/// Balleck Team — Dev Session 5.
///
/// Un lot a :
///   - un nom affiché à l'utilisateur
///   - une probabilité (0–100), somme de tous les lots = 100
///   - un flag isJackpot : si true, le lot est toujours placé en case centrale
///   - un flag isLoss : si true, le lot est une perte (overlay neutre, pas de particules)
class PrizeLot {
  String name;
  double probability; // 0–100
  bool isJackpot;
  bool isLoss;

  PrizeLot({
    required this.name,
    required this.probability,
    this.isJackpot = false,
    this.isLoss = false,
  });

  PrizeLot copyWith({String? name, double? probability, bool? isJackpot, bool? isLoss}) {
    return PrizeLot(
      name: name ?? this.name,
      probability: probability ?? this.probability,
      isJackpot: isJackpot ?? this.isJackpot,
      isLoss: isLoss ?? this.isLoss,
    );
  }
}

/// Résultat d'un atterrissage — transmis via ValueNotifier à l'overlay.
class LandedResult {
  final String prizeName;
  final bool isJackpot;
  final bool isLoss;

  const LandedResult({
    required this.prizeName,
    required this.isJackpot,
    this.isLoss = false,
  });
}
