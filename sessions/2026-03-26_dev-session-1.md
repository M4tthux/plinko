# Session — 2026-03-26 — Dev Session 1 — Socle physique

## Ce qui a été fait
- Création du projet Flutter `plinko_app/` avec structure conforme à la spec
- `pubspec.yaml` avec Flame ^1.18.0, flame_forge2d ^0.18.0, audioplayers, haptic_feedback
- `plinko_config.dart` — toute la configuration du plateau en un seul endroit
- `board.dart` — Wall, Peg, SlotDivider, SlotLabel + BoardBuilder
- `ball.dart` — bille dynamique Forge2D avec rendu néon (halo + gradient + reflet)
- `plinko_game.dart` — Forge2DGame, caméra follow avec lerp, tap pour lancer
- `main.dart` — app Flutter, portrait forcé, plein écran
- `models/trajectory.dart` — modèle placeholder pour Dev Session 2
- `data/trajectory_loader.dart` — loader placeholder pour Dev Session 2

## Prochaine étape immédiate
**Matthieu teste sur son device :**
```
cd plinko_app
flutter pub get
flutter run
```
Feedback attendu : les rebonds sont-ils réalistes ? Trop rapide ? Trop lent ? Picots trop petits ?

## Paramètres à ajuster après test
Tout est dans `plinko_config.dart` :
- `gravity` (18.0) — plus haut = plus rapide
- `pegRestitution` (0.40) — plus haut = rebonds plus vifs
- `ballRadius` / `pegRadius` — taille des éléments
- `pegSpacingX` / `pegSpacingY` — densité de la grille
- `zoom` (20.0) — taille à l'écran

## Questions ouvertes post-test
- La bille passe-t-elle parfois à travers les picots (tunneling) ? Si oui, activer `bullet: true` est déjà en place.
- Les cases sont-elles visibles au lancer ? Ajuster `worldHeight` si besoin.
- La caméra est-elle fluide ? Ajuster `cameraLerp`.

## Dev Session 2 (suivante)
- Script offline `generate_trajectories.dart`
- Génération de `assets/trajectories.json` (90 trajectoires)
- Remplacement de la physique libre par le replay des trajectoires
