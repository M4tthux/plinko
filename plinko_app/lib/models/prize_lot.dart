/// Modèle d'un lot (récompense) de la table de prix Plinko.
/// Balleck Team — Dev Session 5.
///
/// Un lot a :
///   - un nom affiché à l'utilisateur
///   - une probabilité (0–100), somme de tous les lots = 100
///   - un flag isJackpot : si true, le lot est toujours placé en case centrale
class PrizeLot {
  String name;
  double probability; // 0–100
  bool isJackpot;

  PrizeLot({
    required this.name,
    required this.probability,
    this.isJackpot = false,
  });

  PrizeLot copyWith({String? name, double? probability, bool? isJackpot}) {
    return PrizeLot(
      name: name ?? this.name,
      probability: probability ?? this.probability,
      isJackpot: isJackpot ?? this.isJackpot,
    );
  }
}

/// Résultat d'un atterrissage — transmis via ValueNotifier à l'overlay.
class LandedResult {
  final String prizeName;
  final bool isJackpot;

  const LandedResult({required this.prizeName, required this.isJackpot});
}
