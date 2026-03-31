# Session QA + Dev — 2026-03-29 (Session 9)

## Ce qui a été fait

### QA — Tâches validées (board propre)
- ✅ **Anti-orbite v5** : testé en mode physique forcé — aucun blocage observé
- ✅ **Bille traverse les picots** : testé en mode replay — aucune traversée visuelle
- ✅ **Bug mismatch lot/case** : 5 lancers — badge = overlay = label case à chaque fois
- ✅ **Qualité trajectoires (bille bloquée)** : diagnostiqué comme trajectoire pré-calculée qui boucle (pas de fallback). Fixé par régénération avec filtre anti-stagnation.

### Dev — Nouveau code
- **Toggle mode physique forcé** : `PlinkoConfig.forcePhysicsMode` (bool) + switch orange dans ConfigPanel section 🔧 Debug. Bypasse TrajectoryLoader → toutes les billes en physique pure. Permet de tester l'anti-orbite sans manipuler les fichiers.
- **`_visualScale` 1.0** : revenu à la taille physique complète (0.75 créait un gap visible entre bille et picots au moment du rebond).
- **Badge version** : `kBuildTime` centré en haut, taille 14, bien visible. Build 11 à la clôture. À incrémenter à chaque session.
- **Jackpot unique centré** : jackpot exclu des fillers dans `_assignSlots()` et `_assignSlotsDecor()`. 1000€ en case centrale uniquement, jamais en décor ailleurs.
- **Valeurs par défaut** : 1€(30%), 2€(25%), 5€(20%), 10€(13%), 20€(7%), 50€(3%), 1000€(2% jackpot).
- **Filtre anti-stagnation** : `generate_trajectories.py` recréé + filtre (min 0.5 unités Y sur 120 frames). 70/70 trajectoires régénérées, 326 Ko (vs 1279 Ko avant).

## Décisions prises
- `_visualScale=1.0` définitif — pas de réduction visuelle de la bille
- Jackpot TOUJOURS et UNIQUEMENT en case centrale — règle définitive
- Valeurs par défaut : 1€ à 1000€ (7 lots, somme 100%)
- Filtre stagnation : 120 frames, min_dy=0.5 — paramètres OK, aucune manquante
- Badge version visible dès le début de chaque session pour vérifier le hot reload
- Visuel end game : prix centré, icône €, feux d'artifice, halo. Jackpot = or + spectaculaire

## Problèmes rencontrés
- **Claude in Chrome** : ne peut pas interagir avec localhost (screenshot, JS bloqués). Tests visuels 100% à la charge de Matthieu.
- **Bille bloquée 5-10s** : diagnostiqué trajectoire pré-calculée de mauvaise qualité (pas de fallback). Réglé par filtre stagnation + régénération.
- **Double 1000€** : jackpot apparaissait en décor sur d'autres cases. Réglé par exclusion du jackpot des fillers.

## Prochaine session — Priorités dans l'ordre
1. **Visuel end game** : overlay récompense refonte (feux d'artifice, halo, icône €, jackpot or spectaculaire)
2. **LaunchZoneOverlay DEBUG** : retirer les étiquettes Z0–Z4 avant prod
3. **Valider parcours joueur complet** : QA end-to-end (en dernier, quand tout le reste est stable)
