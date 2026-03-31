# Session Design Assets — 2026-04-01

## Objectif
Refonte visuelle complète du plateau — intégration d'assets Gemini et amélioration du contraste.

## Travail réalisé

### Assets intégrés
- `assets/images/background.png` — fond galaxie (letterbox autour du jeu)
- `assets/images/plateau.png` — cadre néon violet PNG avec transparence intérieure
- `assets/images/rond.png` — picot sphère cyan avec alpha
- `pubspec.yaml` → `- assets/images/` ajouté

### Refonte board.dart
- **Peg** : PositionComponent canvas-drawn → `SpriteComponent` avec `Sprite.load('rond.png')`
- **BoardFrame** : supprimé — remplacé par `plateau.png` en overlay Flutter
- **SlotLabel** : redesign coupe trapézoïdale verre (rim, shrink, shine, glow jackpot)
- **Pièces jackpot** : 5 sphères dorées flottantes au-dessus de la coupe centrale
- **Background** : simplifié — fond noir `#06040e` + très légère lueur violette subtile

### Refonte ball.dart
- Bille dorée `#f0c040` (halo or + sphère gradient or + reflet spéculaire)

### Refonte plinko_game.dart
- Caméra fixe (`_followBall()` = no-op) — viewport centré sur tout le plateau
- `buildBackground()` restauré (requis pour opacité canvas Chrome Web)
- `backgroundColor()` → `Color(0xFF08040f)`

### main.dart — Stack Flutter
1. `background.png` (BoxFit.cover) — letterbox
2. `GameWidget` (Flame)
3. `plateau.png` (BoxFit.contain) — cadre overlay
4. UI (instructions, badge, overlay, config)

## Problème bloquant — Canvas transparent

**Symptôme** : canvas Flame = damier gris (transparent) sur Chrome Web
**Visible depuis** : build 20, persistant jusqu'au build 23
**Cause identifiée** : `backgroundColor()` dans Flame est non fiable sur Flutter Web. Seul `canvas.drawRect()` dans un `PositionComponent` opacifie réellement le canvas.
**Fix tenté** : `buildBackground()` restauré dans `plinko_game.dart` + Background simplifié à un `drawRect` noir.
**Résultat** : Toujours transparent au build 23. Non résolu.

**Hypothèse non vérifiée** : le Background PositionComponent se charge correctement mais son `render()` ne s'exécute pas (problème de priorité, de world vs camera layer, ou de timing `onLoad`). À investiguer.

## Builds
- Build 20–22 : tentatives précédentes (nébuleuses vivaces → trop coloré)
- Build 23 : Background minimaliste (noir + lueur violette subtile) — transparent encore

## Prochaine session
- Diagnostiquer le canvas transparent : vérifier si Background.render() s'exécute (ajout log)
- Alternative : `RectangleComponent` Flame (peut-être mieux supporté que PositionComponent custom)
- Une fois fond opaque → valider contraste bille/picots/cases
