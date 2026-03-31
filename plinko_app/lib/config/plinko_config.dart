import '../models/prize_lot.dart';

/// Configuration centrale du plateau Plinko.
/// Les paramètres marqués [TUNABLE] sont modifiables en live via ConfigPanel.
/// Les constantes structurelles (worldWidth, zoom, etc.) restent en const.
class PlinkoConfig {
  // ─── Monde physique (constantes fixes) ────────────────────────────────────
  static const double worldWidth  = 18.0;
  static const double worldHeight = 29.0;
  static const double zoom        = 20.0;
  static const double pegStartY   = 5.0;
  static const double ballStartY  = 1.5;
  static const double slotBaseY   = worldHeight - 1.0;

  // ─── [TUNABLE] Gravité ────────────────────────────────────────────────────
  /// Vitesse de chute de la bille (unités/s²)
  static double gravity = 18.0;

  // ─── [TUNABLE] Picots ─────────────────────────────────────────────────────
  static double pegRadius   = 0.25;
  static double pegSpacingX = 3.0;
  static double pegSpacingY = 1.5;
  static int    pegRowCount = 14;

  /// Calculé automatiquement depuis pegSpacingX.
  /// Minimum : slotCount/2 + 1 = 4 (garantit qu'au moins un picot couvre chaque case).
  static int get pegColsOdd  => (worldWidth / pegSpacingX).floor().clamp(slotCount ~/ 2 + 1, 99);
  static int get pegColsEven => (pegColsOdd - 1).clamp(1, 99);

  /// Espacement effectif entre picots — calculé pour couvrir TOUT le plateau.
  /// Quelle que soit la valeur de pegSpacingX (= densité voulue), les picots
  /// se répartissent sur toute la largeur : worldWidth / pegColsOdd.
  /// Compatible défaut : pegSpacingX=3 → pegColsOdd=6 → effectiveX=3.0 (inchangé).
  static double get pegEffectiveSpacingX => worldWidth / pegColsOdd;

  /// Offset de départ centré pour les rangées impaires (row % 2 == 0).
  /// = pegEffectiveSpacingX / 2 : premier picot à mi-espacement du bord gauche.
  static double get pegOffsetOdd => pegEffectiveSpacingX / 2;

  /// Offset pour les rangées paires : décalé d'un demi-espacement effectif.
  static double get pegOffsetEven => pegEffectiveSpacingX;

  // ─── [TUNABLE] Bille ──────────────────────────────────────────────────────
  static double ballRadius      = 0.60;
  static double ballRestitution = 0.35;
  static const double ballDensity = 1.0;
  static const double ballFriction = 0.05;

  // ─── [TUNABLE] Rebond picot ───────────────────────────────────────────────
  static double pegRestitution = 0.50;
  static const double pegFriction = 0.05;

  // ─── Cases de récompense (fixes) ──────────────────────────────────────────
  static const int    slotCount          = 7;
  static const double slotWallHeight     = 2.0;
  static const double slotWallThickness  = 0.08;
  static double get   slotWidth          => worldWidth / slotCount;

  /// Index de la case centrale (jackpot).
  static const int jackpotSlotIndex = slotCount ~/ 2; // = 3

  // ─── [TUNABLE] Table de lots ──────────────────────────────────────────────
  /// Liste des lots configurables. La somme des probabilities doit être 100.
  /// Le lot avec isJackpot = true est toujours placé en case centrale.
  static List<PrizeLot> lots = [
    PrizeLot(name: '500€',  probability: 0.5,  isJackpot: true),
    PrizeLot(name: '50€',   probability: 2.5),
    PrizeLot(name: '25€',   probability: 4.0),
    PrizeLot(name: '10€',   probability: 8.0),
    PrizeLot(name: '5€',    probability: 12.0),
    PrizeLot(name: '2€',    probability: 18.0),
    PrizeLot(name: '1€',    probability: 22.0),
    PrizeLot(name: 'Perdu', probability: 33.0, isLoss: true),
  ];

  /// Assignation actuelle des lots aux cases pour la partie en cours.
  /// Index 0–6, mis à jour par PlinkoGame avant chaque lancer.
  /// null = pas encore assigné (avant le premier lancer).
  static List<PrizeLot?> currentSlotAssignment = List.filled(slotCount, null);

  /// Label affiché dans la case d'index [i] — lu dynamiquement par SlotLabel.
  static String slotLabelAt(int i) =>
      currentSlotAssignment[i]?.name ?? '?';

  /// Vrai si la case d'index [i] est un jackpot — pour la couleur or.
  static bool slotIsJackpot(int i) =>
      currentSlotAssignment[i]?.isJackpot ?? false;

  // ─── Zones de lancement ───────────────────────────────────────────────────
  static const int zoneCount = 5;
  static double get zoneWidth => worldWidth / zoneCount;
  static int zoneForX(double x) =>
      (x / zoneWidth).clamp(0, zoneCount - 1).floor();

  /// Zone de lancer clampée entre les premiers picots (anti-couloir)
  static double get launchMin => pegSpacingX / 2;
  static double get launchMax => worldWidth - pegSpacingX / 2;

  // ─── Parois ───────────────────────────────────────────────────────────────
  static const double wallRestitution = 0.55;
  static const double minWallKick     = 1.5;

  // ─── Entonnoir ────────────────────────────────────────────────────────────
  static const double funnelZoneWidth = 2.5;
  static const double funnelForce     = 30.0;

  // ─── [TUNABLE] Replay ─────────────────────────────────────────────────────
  /// Ticks entre chaque frame de replay. 2=rapide, 4=normal, 6=lent.
  static int replayStride = 3; // 4 = trop lent, 3 = bon rythme

  // ─── Caméra ───────────────────────────────────────────────────────────────
  static const double cameraLeadY = 3.0;
  static const double cameraLerp  = 0.08;

  // ─── [DEBUG] Flags de test ────────────────────────────────────────────────
  /// Si true, bypasse TrajectoryLoader → toutes les billes en mode physique fallback.
  /// Permet de tester l'anti-orbite sans manipuler les fichiers.
  static bool forcePhysicsMode = false;

  // ─── Highlight case gagnante ──────────────────────────────────────────────
  /// Index de la case à mettre en évidence après atterrissage (jackpot).
  /// null = toutes les cases normales. Mis à jour par PlinkoGame, remis à null dans dismissReward.
  static int? highlightedSlotIndex;

  // ─── Validation (utilisée par ConfigPanel) ────────────────────────────────
  /// Vérifie que la bille peut physiquement passer entre les picots.
  static bool get ballFitsThrough =>
      pegSpacingX - 2 * pegRadius >= 2 * ballRadius;

  /// Vérifie que la bille ne se coince pas entre le mur et le premier picot.
  static bool get ballFitsAtWall =>
      pegSpacingX / 2 > ballRadius + (ballRadius + pegRadius);

  /// Vérifie que la somme des probabilités des lots est bien 100.
  static double get totalLotProbability =>
      lots.fold(0.0, (sum, l) => sum + l.probability);

  static bool get lotsAreValid =>
      (totalLotProbability - 100.0).abs() < 0.01 && lots.isNotEmpty;
}
