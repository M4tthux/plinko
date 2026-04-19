# Session onboarding + landing — 2026-04-19

Build **56 → 59**. Implémentation du flow d'onboarding à partir du handoff design Claude Design (`design_handoff/design_handoff_plinko_onboarding_hifi/`).

## Ce qui a été fait

- **Écran d'accueil** (`lib/ui/landing_screen.dart`) — wordmark PLINKO glow cyan, headline + sous-titre, CTA "Jouer", ghost link "Comment ça marche ?". Space Grotesk via `google_fonts`.
- **Tour d'onboarding** — 4 steps (wordmark → plateau → mise → billes) :
  - `lib/ui/onboarding/coachmark.dart` : widget réutilisable (spotlight dim + ring cyan 2px + callout glass docké + progress bar + skip button)
  - `lib/ui/onboarding/tour_overlay.dart` : state machine step 1→4, `targetKey` par step, rebuild post-frame pour récupérer les `RenderBox` des `GlobalKey`
  - `lib/services/onboarding_prefs.dart` : persistance `plinko_has_seen_tour` en `SharedPreferences`
- **Routing** — MaterialApp home = Landing, bouton "Jouer" → game sans tour, bouton "Comment ça marche ?" → game avec `startTour: true`. Bouton retour top-left dans le jeu pour revenir au landing.
- **`GlobalKey` sur les targets** — wordmark PLINKO, zone plateau (overlay invisible resserré top:30%/bottom:25%), rangée bet, rangée billes.
- **Deps ajoutées** — `shared_preferences: ^2.2.0`, `google_fonts: ^6.2.0`.

## Décisions prises

- **Tour lancé uniquement via "Comment ça marche ?"** (pas d'auto-launch au 1er open). Le flag `hasSeenTour` est persisté mais ne gate rien pour l'instant — flexibilité future.
- **Zone cible "plateau" = overlay Flutter invisible**, pas le `GameWidget` entier. Raison : le GameWidget plein écran ne laisse aucune place à la callout. Ratios top:30%/bottom:25% du container pour cadrer seulement pyramide + multiplicateurs.
- **Dim overlay = 4 rectangles autour du trou**, pas `Path.combine(difference)` ni `saveLayer + BlendMode.clear`. Ces dernières approches rendent de façon incohérente sur le renderer HTML de Flutter Web (dim absent ou intérieur du trou teinté par artefact).
- **Ring spotlight = bordure 2px cyan sèche, aucun halo** — les `BoxShadow` multiples (blur 32 sur ring, blur 20 sur callout, blur 8 sur progress bar) combinés teintaient l'écran entier en cyan et empêchaient de voir le contenu pointé. Cyan réservé au contour.
- **Typo Space Grotesk + JetBrains Mono** appliquées uniquement sur landing + coachmark cette session. Passe typo globale (balance, popups, boutons, multiplicateurs) reportée session suivante.
- **Libellés FR** validés avec Matthieu avant code : "Tombe. Rebondit. Gagne.", "Comment ça marche ?", "Comment fonctionne Plinko", "Le plateau", "Mise par bille", "Billes par lancer", "Suivant / Terminer / Passer".

## Problèmes rencontrés

- **Page blanche après ajout des deps** — hot reload ne suffit pas quand on ajoute des packages avec code natif/web (`shared_preferences`). Solution : arrêter + relancer `flutter run`.
- **Port 8081 occupé** au relance — le preview MCP tournait en parallèle. Stop du preview → libération du port.
- **Callout off-screen sur step 2 (plateau)** — le spot du `GameWidget` couvrait tout l'écran, la callout se dockait au-dessus ou en dessous hors viewport. Fix en 2 temps : (1) resserrer la zone cible à la pyramide uniquement, (2) clamp de la position de la callout avec `calloutEstH=150` + `safeEdge=20`.
- **Écran tinté cyan** au 1er rendu — combinaison des multiples halos cyan. Résolu en supprimant la majorité des `BoxShadow` cyan (seul le bouton Suivant garde un léger glow).
- **Grille du design ≠ grille réelle** — le handoff décrit 11 rangs / 3–13 picots, on est en 12 rangs / 9 cases. Décision Matthieu : il relancera un nouveau prompt côté Claude Design pour aligner le design sur notre grille réelle.

## Prochaine étape

1. **Passe typo globale** — propager Space Grotesk + JetBrains Mono sur tout le jeu (balance, popups "+X€", boutons bet/billes, labels multiplicateurs, build stamp)
2. **Adapter le design hi-fi Claude à la grille 12/9** (nouveau prompt Claude Design côté Matthieu)
3. **Demo ball magenta step 3** — bille qui tombe avec trail dashed pendant le coachmark plateau, comme le design ref
4. **Alignement layout callout avec design ref** — dots de progression en bas-gauche, eyebrow "HOW TO PLAY"/"COMMENT JOUER"
5. **VFX Phase 2** (hors onboarding) — flash case, screen shake, scale pulse à l'atterrissage
6. **Cleanup LaunchZoneOverlay DEBUG**
