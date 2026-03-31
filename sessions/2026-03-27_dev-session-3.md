# Session Dev — 2026-03-27 (Session 3)

## Ce qui a été fait (partie 1 — tuning plateau)

- Supprimé les parois en dents de scie → remplacé par `SideWall` droites dans `board.dart`
- pegRadius 0.15→0.25, pegSpacingX 1.0→2.0, pegColsOdd/Even 17/17→9/8, pegRowCount 24→20
- ballRadius 0.22→0.30
- slotCount 9→7, labels : 10 / 50 / 100 / 500 / 100 / 50 / 10
- Entonnoir latéral : funnelZoneWidth=2.5, funnelForce=30, minWallKick=1.5
- Zone de lancer clampée à [1.0, 17.0] (pegSpacingX/2)

## Ce qui a été fait (partie 2 — bugfix & trajectoires)

- **BUGFIX CRITIQUE — formule rebond picot** : `v -= n × (2 × dot × restitution)` était faux (annulait vn). Corrigé en `v -= n × dot × (1 + restitution)`. Validé par simulation Python (sticks : 100–142 → 0–9 par lancer).
- **Séparateurs de cases solides** : `_resolveSlotDividerCollisions()` dans plinko_game.dart
- **Bug reset bille** : `_resetPending` flag ajouté + `_ballInFlight=false` déplacé dans `_resetBall()`
- **Simulation Python** créée (`simulate_plinko.py`) pour valider la physique hors Flutter
- **generate_trajectories.dart** : script offline brute force (5000 essais / (zone, case), 2 variantes). Sans Forge2D — réutilise la physique interne du jeu.
- **70 trajectoires générées**, 0 manquantes — `assets/trajectories.json` (~1MB)
- **Ball.replay()** : mode replay frame-par-frame depuis JSON. Fallback physique automatique.
- **TrajectoryLoader** intégré dans plinko_game.dart (chargement au démarrage)
- **replayStride=4** dans plinko_config.dart — vitesse visuelle ajustable
- **slotWeights=[6,4,3,1,3,4,6]** pour distribution MVP (Jackpot = plus rare)
- **LaunchZoneOverlay** DEBUG (Z0–Z4) — 5 bandes colorées, à retirer avant prod

## Décisions prises

- Forge2D définitivement abandonné — physique interne suffisante et cohérente
- replayStride dans la config (pas hardcodé) — ajustable sans régénérer les trajectoires
- _ballInFlight ne passe à false qu'une fois la bille retirée du monde (anti-double-launch)
- Formule rebond corrigée → physique enfin correcte après sessions précédentes

## Configuration plateau validée

```
pegRadius=0.25 / pegSpacingX=2.0 / pegSpacingY=1.0
pegColsOdd=9 / pegColsEven=8 / pegRowCount=20
ballRadius=0.30 / wallRestitution=0.55 / pegRestitution=0.50
minWallKick=1.5 / funnelZoneWidth=2.5 / funnelForce=30.0
slotCount=7 (10/50/100/500/100/50/10 pts)
replayStride=4 (en cours d'ajustement visuel)
```

## Problèmes rencontrés

- **Bille collée sur picot** → formule de réflexion fausse depuis le début. Trouvé + corrigé via simulation Python.
- **Couloir latéral** → résolu par clamp zone lancer + minWallKick
- **Bille trop rapide** → replayStride ajusté 2→3→4. En cours de validation visuelle.
- **F5 requis après chaque bille** → bug _ballInFlight prématuré corrigé avec _resetPending

## Prochaine étape (Dev Session 4)

1. Valider visuellement la vitesse de chute (replayStride) — ajuster si besoin
2. **Overlay récompense** : affichage nom de case + animation après atterrissage
3. Retirer `LaunchZoneOverlay` DEBUG avant prod
