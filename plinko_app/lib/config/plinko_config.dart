import 'dart:ui' show Color;
import '../models/prize_lot.dart';

/// Configuration centrale du plateau Plinko — grille triangulaire.
///
/// Mécanique Plinko (standard industrie) :
///   - Grille triangulaire : rangée R a R+1 picots
///   - rows=8 → rangée 7 = 8 picots → 7 gaps = 7 cases naturellement alignées
///   - pegGX fixé (ratio gap/diamètre bille ~2×)
///   - worldWidth = largeur exacte de la dernière rangée de picots
///   - Cases entre les picots de la dernière rangée
///   - Pas de parois latérales — sortie = perdu
class PlinkoConfig {
  // ─── Grille triangulaire ───────────────────────────────────────────────────
  static const int    rows       = 8;     // rangs logiques 0–7 (last row = 8 picots)
  static const int    startRow   = 2;     // commence à 3 picots (standard Plinko)
  static const double pegGX     = 1.70;   // espacement horizontal = 2× diamètre bille
  static const double pegGY     = 2.0;    // espacement vertical centre à centre
  static const double pegStartY = 4.5;    // Y du rang startRow

  // ─── Picots ────────────────────────────────────────────────────────────────
  static double pegRadius      = 0.25;
  static double pegRestitution = 0.35;  // dévie légèrement, pas de gros rebond

  // ─── Monde physique ────────────────────────────────────────────────────────
  /// Largeur = exactement la largeur de la dernière rangée de picots.
  /// (rows-1) espacements entre picots + 2 rayons de picot aux extrémités.
  static double get worldWidth => (rows - 1) * pegGX + 2 * pegRadius;
  static const double worldHeight = 24.0;
  static const double zoom        = 24.0;

  static double get boardCenterX => worldWidth / 2;

  /// Nombre de rangées affichées.
  static int get displayedRows => rows - startRow;

  /// Position X du picot [row][col] dans la grille triangulaire.
  static double pegX(int row, int col) =>
      boardCenterX - (row * pegGX / 2) + col * pegGX;

  /// Position Y du picot à la rangée [row] (ajusté par startRow).
  static double pegY(int row) => pegStartY + (row - startRow) * pegGY;

  /// Nombre de picots dans la rangée [row] = row + 1.
  static int pegCount(int row) => row + 1;

  /// Nombre total de picots affichés (de startRow à rows-1).
  static int get totalPegs {
    int count = 0;
    for (int r = startRow; r < rows; r++) count += r + 1;
    return count;
  }

  // ─── Bille ─────────────────────────────────────────────────────────────────
  static const double ballStartY = 1.5;  // au-dessus de la première rangée
  static double ballRadius      = 0.30;  // ratio ~1:1 avec pegRadius
  static double ballRestitution = 0.35;  // rebond amorti — la gravité domine

  // ─── Gravité ───────────────────────────────────────────────────────────────
  static double gravity = 12.0;

  // ─── Cases de récompense (alignées sur les picots de la dernière rangée) ──
  static const int    slotCount         = 7;   // 7 gaps entre 8 picots
  static const int    jackpotSlotIndex  = 3;   // centre (0-indexed sur 7)
  static const double slotWallHeight    = 2.5;
  static const double slotWallThickness = 0.08;

  /// Largeur d'une case = espacement entre deux picots de la dernière rangée.
  static double get slotWidth => pegGX;

  /// X du bord gauche de la case 0 = position du 1er picot de la dernière rangée.
  static double get slotStartX => pegX(rows - 1, 0);

  /// X du bord droit de la dernière case = position du dernier picot de la dernière rangée.
  static double get slotEndX => pegX(rows - 1, rows - 1);

  /// Y du bas des cases — collées à la dernière rangée de picots.
  static double get slotBaseY =>
      pegY(rows - 1) + pegGY + slotWallHeight;

  // ─── Labels et couleurs des 7 cases (symétrique, jackpot central) ─────────
  static const List<String> slotLabels = [
    '1€', '10€', '25€',
    '500€', // jackpot central
    '25€', '10€', 'Perdu',
  ];

  // Gradient chaud symétrique : rouge → orange → vert → or (jackpot)
  static const List<int> _slotColorValues = [
    0xFFff4444, // rouge
    0xFFff8c00, // orange
    0xFF44cc44, // vert
    0xFFf0c040, // or (jackpot)
    0xFF44cc44, // vert
    0xFFff8c00, // orange
    0xFFff4444, // rouge
  ];

  static String slotLabelAt(int i) => slotLabels[i];
  static bool   slotIsJackpot(int i) => i == jackpotSlotIndex;
  static Color  slotColorAt(int i) => Color(_slotColorValues[i]);

  // ─── Zones de lancement ─────────────────────────────────────────────────────
  /// Détermine la zone de lancement (0–4) pour une position X donnée.
  static int zoneForX(double x) =>
      (x / worldWidth * 5).clamp(0, 4).floor();

  // ─── Entonnoir anti-couloir latéral ────────────────────────────────────────
  static const double funnelZoneWidth = 2.5;
  static const double funnelForce     = 30.0;

  // ─── Replay ────────────────────────────────────────────────────────────────
  static int replayStride = 3; // 4 = trop lent, 3 = bon rythme

  // ─── Parois ────────────────────────────────────────────────────────────────
  static const double wallRestitution = 0.55;
  static const double minWallKick     = 1.5;

  // ─── Caméra ────────────────────────────────────────────────────────────────
  static const double cameraLeadY = 3.0;
  static const double cameraLerp  = 0.08;

  // ─── [DEBUG] ───────────────────────────────────────────────────────────────
  static bool forcePhysicsMode = true;  // TEST — physique pure sans trajectoires
  static int? highlightedSlotIndex;

  // ─── Table de lots ────────────────────────────────────────────────────────
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

  static List<PrizeLot?> currentSlotAssignment = List.filled(slotCount, null);

  // ─── Validation ────────────────────────────────────────────────────────────

  /// Assert : la bille passe entre deux picots adjacents.
  static bool get ballFitsThrough =>
      pegGX > 2 * pegRadius + 2 * ballRadius;

  static double get totalLotProbability =>
      lots.fold(0.0, (sum, l) => sum + l.probability);

  static bool get lotsAreValid =>
      (totalLotProbability - 100.0).abs() < 0.01 && lots.isNotEmpty;
}
