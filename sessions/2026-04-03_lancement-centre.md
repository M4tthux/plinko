# Session Lancement Centre — 2026-04-03

## Ce qui a été fait
- **Benchmark Plinko industrie** : analyse de Stake, BGaming, Spribe et clones open-source. Conclusion : lancement centre + micro-jitter = standard universel. Vélocité initiale = 0. Anti-blocage via grille quinconce + filtre rejet.
- **Lancement centre avec micro-jitter** : bille lancée depuis `boardCenterX` avec jitter aléatoire ±0.2. Suppression du lancement libre (position tap ignorée). Implémenté dans Dart + Python.
- **Suppression parois latérales** : walls physiques retirées dans `ball.dart` et `generate_trajectories.py`. Plus de rebond invisible sur les bords.
- **Sortie hors plateau = Perdu** : détection X hors limites dans `ball.dart`, traité comme `LandedResult(isLoss: true)` dans `plinko_game.dart`.
- **Trajectoires régénérées** : 180/180 (20/case, 9 cases) avec lancement centre, sans parois.
- **État des lieux projet** complet en début de session.

## Tentative revertée
- **Rangée de 2 picots + lancement sommet pyramide** : testé (`startRow=1`, `pegStartY=2.5`, `ballStartY=0.5`) — la bille se bloquait car elle tombait pile entre les 2 picots. Revert à `startRow=2` (3 picots).
- **Lancement aléatoire gauche/droite** : testé — ne correspond pas au standard industrie. Revert au lancement centre.

## Décisions prises
- Lancement depuis le centre = standard industrie validé par benchmark
- Parois latérales supprimées — bille sortie = Perdu
- Physique pure validée par Matthieu (mouvement naturel satisfaisant)

## Problèmes rencontrés
- Bille bloquée avec rangée 2 picots → le centre tombe pile entre les 2 picots sans les toucher → revert
- Bille bloquée en boucle verticale sur picot central → résolu par micro-jitter
- Bille sortie du plateau comptée comme gain → résolu par détection hors limites
- `ballStartX` référencé après suppression → erreur compilation, corrigé
- `ballRadius` sans préfixe `PlinkoConfig.` → erreur compilation, corrigé
- Flutter ne lance pas depuis Claude Code (PATH Git CMD uniquement)

## Prochaine étape
- Tester visuellement le lancement centre + comportement sortie = Perdu
- Tester overlay win (confettis) et jackpot (feux d'artifice) — jamais validés visuellement
- Retirer LaunchZoneOverlay DEBUG avant prod
