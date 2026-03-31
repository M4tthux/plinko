# Session Dev 1b — 2026-03-26

## Ce qui a été fait

- **Flutter installé** : SDK v3.41.6, extrait dans `C:\flutter`, PATH configuré sur Windows. Terminal Git CMD opérationnel.
- **Refacto forge2d → FlameGame** : forge2d incompatible Flutter Web (conflit vector_math dart2js). Supprimé du runtime. Remplacement par FlameGame + physique manuelle.
  - `board.dart` : BodyComponent → PositionComponent (picots, murs, séparateurs visuels uniquement)
  - `ball.dart` : gravité manuelle, velocity exposé publiquement
  - `plinko_game.dart` : Forge2DGame → FlameGame, composants ajoutés au `world.add()` pour que la caméra applique le zoom
- **Collision bille-picots** : détection cercle-cercle implémentée dans `plinko_game.dart`. Positions des picots précalculées au chargement. Réflexion de vélocité + légère impulsion aléatoire pour éviter les trajectoires symétriques.
- **pubspec.yaml nettoyé** : suppression de `flame_forge2d`, `audioplayers`, `haptic_feedback`.
- **Jeu tourne dans Chrome** : `flutter run -d chrome` fonctionnel. Fond noir visible, "Tap pour lancer" affiché. Rendu des collisions à valider.
- **Board Notion créée** : 17 tâches structurées avec statuts, types, sessions, critères d'acceptation et de test. 2 vues : Kanban (par statut) + Par session.
- **Skills mis à jour** :
  - `plinko-context-loader` v2 : lit la board Notion au démarrage de session
  - `plinko-session-close` : nouveau skill de clôture automatique

## Décisions prises

- Sons et haptique → Post-MVP (pas dans le scope MVP actuel)
- SDK marque, deeplink, webhook → Post-MVP, hors focus actuel
- Board Notion = source de vérité des tâches (en complément des fichiers)
- MVP redéfini : bille qui tombe dans un Plinko, rebondit de façon réaliste, atterrit dans une case → overlay récompense. C'est tout.

## Problèmes rencontrés

- **Flutter installation** : VS Code + extension Flutter échoue à cloner le SDK via Git. Résolu par téléchargement manuel du ZIP depuis docs.flutter.dev + extraction dans `C:\flutter`.
- **forge2d incompatible Web** : incompatibilité vector_math lors de la compilation dart2js. Résolu par suppression de forge2d du runtime (architecture hybride ne nécessite pas de physique temps réel au runtime).
- **Composants rendus sans zoom** : `add()` sur FlameGame ajoutait au root au lieu du world. Résolu en utilisant `world.add()` explicitement.
- **PATH Flutter** : actif uniquement dans les terminaux ouverts après configuration. Git CMD est le terminal de référence.

## Prochaine étape

**Dev Session 2** — Trajectoires pré-calculées :
1. Valider d'abord le rendu Chrome (collision + caméra) avant de démarrer Session 2
2. Écrire `generate_trajectories.dart` (script offline Dart + forge2d)
3. Générer `assets/trajectories.json` (90 trajectoires : 9 cases × 5 zones × 2)
4. Implémenter `trajectory_loader.dart` dans le runtime
5. Remplacer la physique manuelle par le replay frame par frame
