# Session Design Refonte — 2026-04-02

## Objectif
Refonte visuelle complète du plateau Plinko + alignement mécanique picots/cases.

## Travail réalisé

### 1. Refonte visuelle (board.dart)
- **Fond** : gradient radial (centre `#1a1a3a` → bords `#060610`), lueurs violet/cyan renforcées
- **Picots** : blancs/gris uniformes (`#d0d0e0`), halo 2.2x, dégradé radial, reflet spéculaire agrandi
- **Cases** : fond plus opaque (0.28/0.45 jackpot), bordures épaisses (0.07/0.12), glow sur TOUTES les cases, texte blanc (doré jackpot), taille augmentée
- **Cadre** : BoardFrame rectangulaire supprimé, remplacé par rien (bords ouverts)
- **Titre** : label "PLINKO" ajouté en haut du plateau (y=0.8, violet clair, glow néon)

### 2. Alignement mécanique Plinko (plinko_config.dart)
- **Problème identifié** : les picots du bas n'étaient pas alignés sur les séparateurs de cases → pas de vrai 50/50 sur le dernier rebond
- **Game designer consulté** : analyse 4 options (A=7 cases découplées, B=9 cases alignées, C=rangée bonus, D=11 cases)
- **Décision** : Option B — 9 cases, rows=10, pegGX=worldWidth/slotCount=2.0
- **Résultat** : 8 rangées affichées (3→10 picots), dernière rangée parfaitement alignée sur les 10 séparateurs

### 3. Configuration finale
| Paramètre | Ancienne valeur | Nouvelle valeur |
|---|---|---|
| `rows` | 10 (rect) | 10 (triangulaire) |
| `startRow` | - | 2 |
| `pegGX` | 1.6 (const) | 2.0 (calculé = worldWidth/slotCount) |
| `pegGY` | 1.85 | 2.0 |
| `pegStartY` | 3.5 | 4.5 |
| `slotCount` | 7 | 9 |
| `jackpotSlotIndex` | 3 | 4 |
| `worldHeight` | 26.0 | 24.0 |
| `slotLabels` | ×1..×500 | 1€..500€ (lots réels) |

### 4. Architecture multi-agents
- 5 agents créés : orchestrator, game-designer, designer, developer, benchmark
- Section ajoutée dans CLAUDE.md
- **Feedback process** : le game designer doit valider AVANT le développement. Itération actuelle trop rapide (code→bug→fix) au lieu de (design→validation→code).

## Bugs rencontrés et corrigés
- **Cases débordent du cadre** : pegGX=2.57 (7 cases) trop large → corrigé par passage à 9 cases (pegGX=2.0)
- **Plateau aplati** : rows=8 ne donnait que 6 rangées → restauré à rows=10 (8 rangées)
- **Labels pas à jour** : `_assignSlotsDecor()` pas appelé au démarrage → ajouté dans onLoad()

## Décisions prises
- **9 cases** au lieu de 7 — alignement mécanique Plinko standard
- **Labels en €** (lots réels) au lieu de multiplicateurs (×1, ×5...)
- **Picots blancs uniformes** — standard marché (benchmark)
- **Pas de cadre rectangulaire** — bords ouverts, plus moderne

## Fichiers modifiés
- `plinko_app/lib/config/plinko_config.dart` — grille triangulaire + 9 cases
- `plinko_app/lib/game/board.dart` — refonte visuelle complète
- `plinko_app/lib/game/plinko_game.dart` — ajout titre + assignSlotsDecor au démarrage
- `plinko_app/lib/main.dart` — AspectRatio 9/16 pour simulation mobile
- `agents/*.md` — 5 fichiers agents créés
- `CLAUDE.md` — section multi-agents ajoutée
- `project-context.md` — config plateau mise à jour

## TODO prochaine session
- Valider visuellement le rendu 9 cases sur Chrome
- Régénérer les trajectoires (adapt à 9 cases)
- Tester le lancer de bille (step 2)
- Améliorer le process game designer → validation avant dev
