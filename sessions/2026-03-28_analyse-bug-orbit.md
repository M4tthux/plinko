# Session Analyse — 2026-03-28

## Ce qui a été fait

- Chargement du contexte complet (project-context.md + board Notion)
- Audit complet de la board Notion tâche par tâche (la recherche sémantique ne remontait pas les statuts — fetch individuel nécessaire)
- État réel de la board : "Placement picots" → En cours, "Valider rendu Session 1" → En test, reste en Backlog
- Diagnostic complet du bug "bille qui tourne autour du picot" observé via le ConfigPanel

## Décisions prises

- Bug orbite picot diagnostiqué — 3 causes identifiées :
  1. Gap de séparation trop petit (`+ 0.001`) → bille re-pénètre dans le picot dès la frame suivante sous l'effet de la gravité
  2. Kick aléatoire tangentiel (`(_rng.nextDouble() - 0.5) * 1.2`) → donne une composante tangentielle qui favorise l'orbite
  3. Pas de sub-stepping → avec des frames irrégulières, la bille peut s'enfoncer profondément avant correction
- Fix prévu : augmenter le gap de séparation (0.001 → ~0.05) + forcer une vitesse de séparation minimum le long de la normale après chaque rebond

## Problèmes rencontrés

- Bug touche uniquement le mode physique fallback (quand `TrajectoryLoader` est vidé par `rebuildBoard()` dans le ConfigPanel)
- En mode replay (trajectoires JSON), aucune collision n'est calculée → pas de bug

## Prochaine étape (Dev Session 4)

1. **Corriger bug orbite picot** — `_resolvePegCollisions()` dans `plinko_game.dart`
2. **Corriger bug bocal** — bille rebondit dans zone des cases
3. **Overlay récompense** — affichage résultat après atterrissage
4. **Régénérer trajectories.json** — config plateau a changé
