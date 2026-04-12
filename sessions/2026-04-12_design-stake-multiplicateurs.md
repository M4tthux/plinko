# Session 2026-04-12 — Design Stake + Mode multiplicateur

**Builds publiés :** 37 → 41
**Branche :** `claude/plinko-design-update-pez1e` (merged → `master` → gh-pages)
**URL live :** https://m4tthux.github.io/plinko

---

## Objectifs de session

1. Itérer le design du plateau à partir de références visuelles (BGaming puis Stake)
2. Passer d'un jeu de tirage pré-déterminé à un jeu de physique pure multi-ball
3. Remplacer les récompenses en € par un système de multiplicateurs positionnels
4. Ajouter une économie simple avec balance + feedback visuel

---

## Itérations

### Build 37 — Premier layout BGaming (8 rangées / 9 cases / bille dominante)

- `rows=10, startRow=2` → 8 rangées visibles, dernière = 10 picots → 9 cases
- `pegRadius=0.20, ballRadius=0.35` → bille ~1.75× picot (dominante)
- `pegGX=1.35, pegGY=1.40`
- **Nouveau composant `LaunchHole`** : trou sombre en haut du plateau (plaque métallique
  violette, ombre interne radiale, cœur noir). La bille émerge du centre.
- Label slot symétrique : Perdu·1€·5€·25€·500€·25€·5€·1€·Perdu

### Build 38 — Compactage vertical

- `pegGY 1.90 → 1.40` (resserrement vertical)
- Gap vertical surface-à-surface = 1.43× diamètre bille ✓
- Gap diagonal = 0.45 ✓
- Plateau remonte de 3.5 unités monde

### Build 39 — Proportions Stake (16 rangées / 17 cases)

- **Layout complètement revu sur référence Stake** :
  - `rows=18, startRow=2` → 16 rangées visibles, 17 cases
  - `pegRadius=0.12, ballRadius=0.16` (ratio ~1.33× — subtil)
  - `pegGX=0.80, pegGY=0.70` (quasi-équilatéral)
  - `slotWallHeight 2.5 → 1.2` (scaled pour grille serrée)
  - `worldHeight 24 → 18` (recentrage caméra)
- Font size des labels slots rendu **proportionnel à slotWidth** (évite débord)
- Pièces dorées du jackpot scalées par `slotWidth/1.35`

### Build 40 — Mode multiplicateur casino

Refonte gameplay majeure :

**Cases (17) : multiplicateurs positionnels fixes**
```
x100  x25  x10  x5  x2  x0.5  x0.2  x0.1  x0.1  x0.1  x0.2  x0.5  x2  x5  x10  x25  x100
```
Extrémités = "jackpot" (x100), centre = le moins rentable (x0.1 × 3).
Gradient couleur aligné sur le multiplicateur.

**Économie**
- Balance initiale : **50€** (`ValueNotifier<double>` exposé au widget)
- Tap = **-1€** (mise déduite immédiatement)
- Atterrissage case i = **+1€ × multiplicateur[i]**
- Bille sortie du plateau = pas de crédit (mise perdue)

**Multi-ball**
- `onTapUp` ne bloque plus sur bille en vol
- `List<Ball> _activeBalls` + dispatching physique/collision par bille
- Despawn 0.8s après atterrissage (linger visuel)

**Cleanup**
- Suppression : `RewardOverlay`, `_drawLot`, `_assignSlots`, `_assignSlotsDecor`,
  `currentSlotAssignment`, `landedSlotNotifier`, `debugTargetNotifier`,
  `dismissReward`, `LandedResult` (plus utilisés)
- `PrizeLot` / `lots` conservés (ConfigPanel y référence encore en legacy)

**UI**
- Badge **BALANCE** en coin haut-gauche (or si ≥ 0, rouge si < 0)
- `SlotLabel` lit directement `PlinkoConfig.slotMultiplierLabel(index)`
- Plus d'écran de récompense bloquant

### Build 41 — Animation "+X€" au centre

- `StreamController<double> gainEvents` dans `PlinkoGame`, émis sur crédit
- Widget `_GainPopup` stateful dans `main.dart` (SingleTickerProviderStateMixin)
- Animation : scale 0.4 → 1.3 (bump) → 1.0, fade in/out, montée 40px, 900ms total
- Style adaptatif selon le gain :
  - ≥ 25€ : 76pt, or-rouge (gros jackpot)
  - ≥ 5€ : 64pt, or
  - ≥ 1€ : 52pt, or clair
  - < 1€ : 42pt, bleuté discret
- Multi-popup supporté (plusieurs billes landing simultanément)

---

## Décisions produit validées

- **Plateau type Stake** : 16 rangées, 17 cases, picots petits, bille ~1.33× picot
- **Multiplicateurs positionnels** (pas de tirage probabiliste) — le physique détermine tout
- **Pas d'écran de récompense** → feedback in-situ (balance + popup "+X€")
- **1 tap = 1 bille = 1€ dépensé** (balance initiale 50€)
- **Jackpot aux extrémités**, pas au centre (inversion Stake vs versions précédentes)
- **Promotion casino-flavored** : labels multiplicateurs + balance en € (assumé
  comme contenu promo marque, pas simulation jeu d'argent réel)

---

## Fichiers modifiés

- `plinko_app/lib/config/plinko_config.dart` — géométrie + slotMultipliers
- `plinko_app/lib/game/plinko_game.dart` — refactor complet multi-ball + balance + gainEvents
- `plinko_app/lib/game/board.dart` — LaunchHole, scaling labels/coins
- `plinko_app/lib/main.dart` — balance badge + _GainPopup animation
- `CLAUDE.md` — tables config + section multiplicateurs
- `project-context.md` — config actuelle mise à jour

---

## Backlog ouvert à la prochaine session

- Son sur rebond picot + atterrissage + gain
- Polish popup gain : particules pour gros gains (≥ x25) ?
- `generate_trajectories.py` et `scripts/generate_trajectories.dart` désynchros
  (non bloquant : `forcePhysicsMode=true`)
- Scripts `LaunchZoneOverlay` DEBUG à retirer pour prod (board.dart)
- ConfigPanel : retirer UI PrizeLot (plus utilisé en mode multiplicateur)
- Persistance balance (SharedPreferences) si on veut qu'elle survive au reload
- Palette multiplicateurs à affiner (trouver le bon équilibre visuel bas/haut)

---

## CI / Deploy

Chaque build a été :
1. Committé sur `claude/plinko-design-update-pez1e`
2. Fast-forward mergé sur `master`
3. `git push origin master` → GitHub Action deploy → `gh-pages`
4. Disponible ~2 min après sur https://m4tthux.github.io/plinko

---

**Team : Balleck Team** 🎰
