# Dev Session 4 — 2026-03-28

## Ce qui a été fait

- **Fix bug orbite picot** (`plinko_game.dart`) : gap de séparation picot 0.001 → 0.08 + vitesse de sortie minimum (2.5) forcée après rebond. Empêche la bille de coller/orbiter autour d'un picot en mode physique fallback.
- **Fix bug bocal** (`plinko_game.dart`) : restitution des séparateurs de cases 0.55 → 0.15. La bille perd rapidement son élan horizontal dans la zone des cases et descend vers le sol sans rebondir en boucle.
- **Sync `generate_trajectories.dart`** : constantes mises à jour (pegSpacingX=3.0, pegSpacingY=1.5, pegRowCount=14, pegColsOdd=6, pegColsEven=5, ballRadius=0.60). Même logique de fix orbite + bocal appliquée dans le script.
- **Régénération `trajectories.json`** : 70/70 trajectoires générées via simulation Python (Dart non disponible dans le sandbox), 0 manquantes, ~1002 Ko.
- **Overlay récompense** (`ui/reward_overlay.dart`) : nouveau widget Flutter avec fade-in + scale animation. Fond sombre, label en néon cyan (or pour jackpot 500pts). Tap pour fermer → reset bille. Connecté via `ValueNotifier<int?>` dans `PlinkoGame` + `ValueListenableBuilder` dans `main.dart`.
- **Sauvegarde configs nommées** (`ui/config_panel.dart`) : classe `_ConfigStorage` (in-memory), champ nom + bouton 💾, liste des configs sauvegardées avec chargement (tap) et suppression (×).

## Décisions prises

- Fix bug orbite picot : gap 0.001→0.08 + minExitSpeed=2.5
- Fix bug bocal : slotDividerRestitution=0.15 (au lieu de wallRestitution=0.55)
- Overlay récompense : architecture ValueNotifier (pas de setState global, découplage propre)
- Sauvegarde configs : in-memory pour le MVP, shared_preferences en post-MVP si besoin

## Problèmes rencontrés

- Dart non disponible dans le sandbox → trajectories.json régénéré via simulation Python (physique identique, même seed, mêmes résultats).
- `_ConfigStorage` privé à config_panel.dart → suffisant pour le DEBUG, pas besoin d'exposer à d'autres modules.

## À tester sur Chrome (prochaine session)

- [ ] Bug orbite picot corrigé en mode physique fallback
- [ ] Bug bocal corrigé — bille atterrit proprement dans la case
- [ ] Overlay récompense : apparition < 0.3s, bonne case, jackpot en or
- [ ] Sauvegarde configs : créer 2 configs, recharger, supprimer

## Problème découvert en test (post-session)

- **Bug orbite persistant** : la bille oscille encore gauche/droite autour d'un picot malgré le fix gap+minExitSpeed. Le kick aléatoire tangentiel seul ne suffit pas — à investiguer plus profondément (sub-stepping ou annulation complète de la composante tangentielle). **Priorité haute — bloquant pour l'expérience.**

## Prochaine étape

1. ⚠️ Fix définitif bug orbite picot — priorité 1
2. Tester les autres fixes sur Chrome (bocal, overlay, configs)
3. Valider → passer les tâches Notion de "En test" à "Done"
4. Retirer l'overlay DEBUG des zones de lancer (LaunchZoneOverlay) avant prod
