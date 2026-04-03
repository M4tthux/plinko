import 'dart:ui' show Color;
import '../models/prize_lot.dart';

/// Configuration centrale du plateau Plinko — grille triangulaire.
///
/// Mécanique Plinko (validée game designer) :
///   - Grille triangulaire : rangée R a R+1 picots
///   - 9 cases, rows=10 → rangée 9 a 10 picots alignés sur les 9 séparateurs
///   - pegGX = worldWidth / slotCount → alignement parfait garanti
///   - 8 rangées affichées (startRow=2), plateau dense
///   - Bille lancée depuis le centre, rebondit sur le picot central
class PlinkoConfig {
  // ─── Monde physique ────────────────────────────────────────────────────────
  static const double worldWidth  = 18.0;
  static const double worldHeight = 24.0;
  static const double zoom        = 24.0;

  // ─── Grille triangulaire ───────────────────────────────────────────────────
  static const int    rows       = 10;    // rangs logiques 0–9 (row 9 = 10 picots)
  static const int    startRow   = 2;     // première rangée affichée (3 picots)
  static const double pegGY     = 2.0;   // espacement vertical centre à centre
  static const double pegStartY = 4.5;   // Y du rang startRow

  /// Espacement horizontal = largeur d'une case.
  /// Garantit que les picots du bas sont alignés sur les séparateurs.
  static double get pegGX => worldWidth / slotCount;

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
  static double ballRadius      = 0.40;
  static double ballRestitution = 0.25;

  // ─── Gravité ───────────────────────────────────────────────────────────────
  static double gravity = 15.0;

  // ─── Picots ────────────────────────────────────────────────────────────────
  static double pegRadius      = 0.25;
  static double pegRestitution = 0.55;

  // ─── Cases de récompense (pleine largeur) ──────────────────────────────────
  static const int    slotCount         = 9;
  static const int    jackpotSlotIndex  = 4; // centre (0-indexed)
  static const double slotWallHeight    = 2.5;
  static const double slotWallThickness = 0.08;

  /// Largeur d'une case = largeur totale / nombre de cases.
  static double get slotWidth => worldWidth / slotCount;

  /// X du bord gauche de la case 0.
  static double get slotStartX => 0.0;

  /// Y du bas des cases — collées à la dernière rangée de picots.
  static double get slotBaseY =>
      pegY(rows - 1) + pegGY + slotWallHeight;

  // ─── Labels et couleurs des 9 cases (symétrique, jackpot central) ─────────
  static const List<String> slotLabels = [
    '1€', '2€', '5€', '50€',
    '500€', // jackpot central
    '50€', '5€', '2€', '1€',
  ];

  // Gradient chaud symétrique : rouge → orange → vert → or (jackpot)
  static const List<int> _slotColorValues = [
    0xFFff4444, // rouge
    0xFFff6633, // rouge-orange
    0xFFff8c00, // orange
    0xFF44cc44, // vert
    0xFFf0c040, // or (jackpot)
    0xFF44cc44, // vert
    0xFFff8c00, // orange
    0xFFff6633, // rouge-orange
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
