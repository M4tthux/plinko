import 'dart:ui' show Color;
import '../models/prize_lot.dart';

/// Configuration centrale du plateau Plinko — grille triangulaire.
///
/// Mécanique Plinko (standard industrie) :
///   - Grille triangulaire : rangée R a R+1 picots
///   - rows=12, startRow=2 → 10 rangées affichées, last row = 12 picots → 9 cases
///   - Proportions style Stake : picots petits, bille ~1.33× picot, quasi-équilatéral
///   - worldWidth = largeur exacte de la dernière rangée de picots
///   - Cases entre les picots de la dernière rangée
///   - Pas de parois latérales — sortie = perdu
class PlinkoConfig {
  // ─── Grille triangulaire ───────────────────────────────────────────────────
  static const int    rows       = 12;    // rangs logiques 0–11 (last row = 12 picots)
  static const int    startRow   = 2;     // commence à 3 picots → 10 rangées affichées
  static const double pegGX     = 0.80;   // espacement horizontal (11 cases)
  static const double pegGY     = 0.70;   // espacement vertical (quasi-équilatéral 0.866×)
  static const double pegStartY = 3.0;    // Y du rang startRow (laisse place au trou)

  // ─── Picots ────────────────────────────────────────────────────────────────
  static double pegRadius      = 0.14;  // +20% pour lisibilité mobile (build 44)
  static double pegRestitution = 0.35;  // dévie légèrement, pas de gros rebond

  // ─── Monde physique ────────────────────────────────────────────────────────
  /// Largeur = exactement la largeur de la dernière rangée de picots.
  /// (rows-1) espacements entre picots + 2 rayons de picot aux extrémités.
  static double get worldWidth => (rows - 1) * pegGX + 2 * pegRadius;
  static const double worldHeight = 18.0;  // ajusté pour plateau compact (y=1.8 à ~15.4)
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
  static const double ballStartY = 1.8;  // émerge du trou (sous le titre PLINKO)
  static double ballRadius      = 0.19;  // ratio ~1.36× avec pegRadius (build 44)
  static double ballRestitution = 0.35;  // rebond amorti — la gravité domine

  // ─── Gravité ───────────────────────────────────────────────────────────────
  static double gravity = 12.0;

  // ─── Cases de récompense (alignées sur les picots de la dernière rangée) ──
  static const int    slotCount         = 9;   // découplé des picots (build 45)
  static const int    jackpotSlotIndex  = 4;   // centre (0-indexed sur 9)
  static const double slotWallHeight    = 1.2; // scaled pour grille compacte
  static const double slotWallThickness = 0.06;

  /// Largeur d'une case — découplée des picots : la zone des cases (du 1er
  /// au dernier picot du bas) est divisée équitablement en `slotCount` cases.
  static double get slotWidth => (slotEndX - slotStartX) / slotCount;

  /// X du bord gauche de la case 0 = position du 1er picot de la dernière rangée.
  static double get slotStartX => pegX(rows - 1, 0);

  /// X du bord droit de la dernière case = position du dernier picot de la dernière rangée.
  static double get slotEndX => pegX(rows - 1, rows - 1);

  /// Y du bas des cases — collées à la dernière rangée de picots.
  static double get slotBaseY =>
      pegY(rows - 1) + pegGY + slotWallHeight;

  // ─── Multiplicateurs des 9 cases (symétrique) ─────────────────────────────
  // Extrémités = x10, puis x2, x0.5, et 3 cases centrales = x0.1.
  static const List<double> slotMultipliers = [
    10.0, 2.0, 0.5, 0.1,
    0.1,  // centre (index 4)
    0.1, 0.5, 2.0, 10.0,
  ];

  /// Palette Deep Arcade (Build 48) : magenta aux extrémités → dégradé froid au centre.
  /// Principe : chaleur code la désirabilité, neutre au centre (x0.1 ≠ punition).
  static const List<int> _slotColorValues = [
    0xFFFF2EB4, // x10  magenta vif
    0xFFB847FF, // x2   violet
    0xFF6B4FFF, // x0.5 indigo
    0xFF4A5A8A, // x0.1 bleu gris
    0xFF3A3A4A, // x0.1 gris neutre (centre)
    0xFF4A5A8A, // x0.1 bleu gris
    0xFF6B4FFF, // x0.5 indigo
    0xFFB847FF, // x2   violet
    0xFFFF2EB4, // x10  magenta vif
  ];

  /// Formate un multiplicateur en label affiché ("x10", "x.1"…).
  /// Pour m < 1, on affiche ".1" / ".5" (le "." signifie "moins que 1 ×").
  static String formatMultiplier(double m) {
    if (m == m.roundToDouble()) return 'x${m.toStringAsFixed(0)}';
    if (m < 1) return 'x${m.toString().substring(1)}'; // "0.1" → ".1"
    return 'x$m';
  }

  static String slotMultiplierLabel(int i) => formatMultiplier(slotMultipliers[i]);

  static double slotMultiplierAt(int i) => slotMultipliers[i];
  static String slotLabelAt(int i) => slotMultiplierLabel(i);
  /// Une case est "majeure" (glow fort) si x10 ou plus — les extrémités dans
  /// la config actuelle (post échelle réduite x0.1→x10).
  static bool   slotIsMajor(int i) => slotMultipliers[i] >= 10.0;
  /// Backward-compat — traité comme slotIsMajor pour le rendu existant.
  static bool   slotIsJackpot(int i) => slotIsMajor(i);
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

  // ─── Table de lots (legacy, non utilisée en mode multiplicateur) ──────────
  // Conservée pour rétro-compat de config_panel.dart (affichage/édition lots).
  static List<PrizeLot> lots = [];

  // ─── Validation ────────────────────────────────────────────────────────────

  /// Assert : la bille passe entre deux picots adjacents.
  static bool get ballFitsThrough =>
      pegGX > 2 * pegRadius + 2 * ballRadius;

  static double get totalLotProbability =>
      lots.fold(0.0, (sum, l) => sum + l.probability);

  static bool get lotsAreValid => true; // mode multiplicateur — toujours valide
}
