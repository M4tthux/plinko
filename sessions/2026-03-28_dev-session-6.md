# Session Dev — 2026-03-28 (Session 6)

## Ce qui a été fait

- **Fix bug orbite picot v4** — deux fichiers modifiés :
  - `plinko_game.dart` : refonte de `_resolvePegCollisions()` — la vitesse tangentielle vers le bas (Y > 0) est désormais PRÉSERVÉE intégralement après rebond (l'ancienne v3 l'amortissait à 50%, ce qui bloquait la descente). Seule la composante X tangentielle est amortie (factor 0.5). Cooldown augmenté 5→8 frames. Kick anti-orbite : `minDownwardVelocity=1.0` forcé après chaque rebond.
  - `ball.dart` : ajout d'un détecteur de blocage en dernier recours — si `velocity.y < 1.5` pendant 90 frames consécutives (≈1.5s), impulsion forcée vers le bas (8.0 u/s) + amortissement X (0.2)

- **Notion mis à jour** :
  - Créé tâche "Système de table de lots" (En test)
  - Mis à jour "Fix bug orbite picot" : critères v4, En test

## Décisions prises

- Ne jamais amortir la composante tangentielle vers le bas lors d'un rebond picot — c'est le principal mécanisme qui permettait l'orbite
- Double protection : fix immédiat dans la collision (v4) + safety net dans l'update physique (90 frames)

## Problèmes rencontrés

- **Serveur Flutter crashé** (localhost:60555 inaccessible) — probablement causé par le hot reload qui a tenté de compiler les nouvelles dépendances (`prize_lot.dart`) et a échoué
- Aucun test possible en session autonome — tous les validations reportées

## Prochaine étape

1. Relancer le serveur : `cd plinko_app && flutter run -d chrome` dans terminal Windows
2. Valider fix orbite v4 (10 lancers mode physique, aucun blocage)
3. Valider système de table de lots (overlay nom lot, jackpot or, ConfigPanel Table de lots)
4. Marquer Done sur Notion : overlay récompense, bug bocal, sauvegarde configs, table de lots, fix orbite
