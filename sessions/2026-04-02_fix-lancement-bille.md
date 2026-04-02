# Session Fix Lancement Bille — 2026-04-02

## Ce qui a été fait
- Diagnostic du bug : mécanisme de lancement entièrement désactivé lors de la session "Design Refonte" (commit 4da26d2) — onTapDown/onTapUp vidés, _launchBall() supprimé, Ball.replay() supprimé, trajectory_loader.dart supprimé, trajectory.dart supprimé
- Restauration complète du pipeline de lancement (6 fichiers) :
  - `models/trajectory.dart` — recréé (modèle TrajectoryFrame + Trajectory)
  - `data/trajectory_loader.dart` — recréé (chargeur JSON + sélection par zone)
  - `game/ball.dart` — Ball.replay() restauré + mode replay avec interpolation
  - `config/plinko_config.dart` — ajout zoneForX, replayStride, funnelZoneWidth, funnelForce
  - `game/plinko_game.dart` — import + onTapDown/onTapUp + _launchBall() restaurés
  - `main.dart` — TrajectoryLoader.load() au démarrage restauré
- Flutter analyze : 0 erreurs dans le code principal

## Problèmes rencontrés
- Les 70 trajectoires pré-calculées sont pour 7 cases (ancien slotCount) mais la config actuelle a 9 cases → aucune trajectoire ne matche → mode physique fallback systématique
- En mode physique fallback, la trajectoire de la bille n'est pas naturelle (feedback Matthieu)

## Décisions prises
- Aucune nouvelle décision — session de correction technique uniquement

## Prochaine étape
- **Régénérer les trajectoires pour la grille 9 cases** : adapter generate_trajectories.py (slotCount 7→9, grille triangulaire)
- **Travailler le naturel du mouvement** : revoir les paramètres physiques (gravity, restitution, damping) pour que la bille ait un comportement réaliste et satisfaisant
