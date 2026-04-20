# Session typo globale + bouton (?) onboarding — 2026-04-21

## Ce qui a été fait

- **Build 63 — Passe typo globale**
  - Space Grotesk appliqué via `google_fonts` sur : balance (`main.dart` L343-362), boutons bet (`_BetButton` L622), boutons lancer (`_LaunchButton` L672), popup gain "+X€" (`_GainPopup` L812), labels multiplicateurs cases (`board.dart` L274).
  - JetBrains Mono appliqué sur le build stamp (`kBuildTime` L306, microcopy per spec §2).
  - Labels cases : weight `w800` → `w700` pour matcher spec §3 ("11 / 700 Space Grotesk").
  - Décalage §7 "Typo globale" résolu.
  - Aucune valeur (size/color/letterSpacing/shadow) changée — swap police uniquement.
  - `_SidePanelPlaceholder` desktop laissé en police système (placeholder temporaire, hors critères).

- **Build 64 — Bouton (?) réafficher onboarding + alignement HUD top 40px**
  - Nouveau widget `_HelpButton` (40×40, mêmes tokens que burger ⚙ : cyan outline, bg `0xFF0A0A14@75`, radius 10, shadow cyan blur 10, icône `Icons.help_outline` 20px).
  - Positionné `top:16 right:62` (à gauche du burger, `right:12`).
  - Tap → `setState(_tourActive = true)` : relance le tour au step 1/4 (wordmark DROPL).
  - `hasSeenTour` inchangé (le bouton est un déclencheur, pas un reset).
  - Balance passe de padding libre à `height:40` fixe + `alignment: Alignment.center` → HUD top parfaitement aligné (balance + ? + ⚙ sur une ligne, même hauteur 40px).

- **Tâche Notion créée** — Cleanup `PlinkoTitle` dead code (`board.dart` L300-393 + `buildTitle()` factory, plus instanciée depuis Build 60). Backlog Session 3 Basse pour visibilité.

## Décisions prises

- **Labels cases w800 → w700** — match strict spec §3, seule exception au garde-fou "swap police uniquement".
- **Balance `height:40` fixe** — source de vérité HUD top = burger actuel. Alignement visuel prime sur le padding libre.
- **Bouton (?) non-destructif** — `hasSeenTour` reste `true` après tap, le bouton remonte juste l'overlay. Simple et prévisible.
- **Coexistence temporaire (?) + burger ⚙** — le burger reste en prod pour debug, cleanup prévu en session séparée.

## Problèmes rencontrés

- Aucun. `flutter analyze` 0 erreur / 0 warning nouveau (28 issues `withOpacity` deprecated préexistantes, hors scope). `flutter build web --release` clean les 2 fois.

## Décalages spec vs code identifiés

- **§7 Design UI** — "Typo globale" marqué résolu (Build 63). Side panel placeholder desktop explicitement laissé en police système (placeholder temporaire, pas dans critères).
- **§3 + §5 Design UI** — nouveau composant Help button documenté + entry point tour `in-game (?)` ajouté.

## Prochaine étape prioritaire

Reste 3 tâches Moyenne / Session 3 sur la board :
1. **Optimisation wording (claude.ai)** — Doc, aller-retour externe claude.ai requis.
2. **(étude) supprimer bouton "passer" onboarding + CTA text "passer" dans tooltips** — Dev, étude préalable.
3. **Background texture plus travaillé (Claude Design)** — Design, handoff externe.

Toutes dépendent d'un travail amont. À trier avec Matthieu en prochaine session.
