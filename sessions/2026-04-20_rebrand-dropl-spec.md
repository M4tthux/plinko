# Session Rebrand DROPL (spec) — 2026-04-20

Sync du handoff Claude Design v2 (`plinko design (2).zip`). Le handoff introduit un **rebrand wordmark PLINKO → DROPL** + une nouvelle section "Wordmark" complète. Périmètre tranché : docs et assets uniquement, refonte code différée à une session dev dédiée.

## Ce qui a été fait

- **Assets handoff mis à jour** dans `design_handoff/design_handoff_plinko_onboarding_hifi/` :
  - `README.md` remplacé (v1 EN onboarding seul → v2 EN onboarding + section "Wordmark — DROPL" complète : construction, SVG refs 52px/40px, règles d'usage, app-icon).
  - `DROPL Wordmark In-Context.html` ajouté (lockup wordmark final, isolé + in-context).
- **`design-ui-spec.md`** :
  - Titre + intro mention rebrand DROPL + scope (DROPL = nom affiché, Plinko = ID tech).
  - Nouvelle **§2bis Wordmark — DROPL (final)** : concept, construction, deux SVG de référence (52px / 40px), règles d'usage, app-icon, note implémentation Flutter prévue.
  - §2 Typo : ligne Wordmark MAJ (DROPL specs, mention ancien wordmark abandonné).
  - §4 step 02 : "PLINKO" → "DROPL", "Comment fonctionne Plinko" → "Comment fonctionne DROPL".
  - §7 Décalages : 2 nouvelles lignes (Wordmark DROPL pas encore en code + Identifiants tech décision DROPL/Plinko).
  - §8 Sources : ajout `DROPL Wordmark In-Context.html`, README marqué v2026-04-20.
- **Page Notion 🎨 Design UI** synchronisée (mêmes blocs que `design-ui-spec.md` : intro + §2 typo + §2bis nouvelle + §4 step 02 + §7 + §8).
- **`project-context.md`** : nouvelle décision tracée dans §Process/Docs (rebrand + scope tech vs marque). Nouvelle question ouverte 🔥 prioritaire en §Design/Dev (implémenter `<DroplWordmark>`). Pied de page MAJ.
- **`decisions-log.md`** : 2 entrées 2026-04-20 (rebrand wordmark + refonte code différée).
- **`CLAUDE.md`** : nouveau bloc "Naming — DROPL vs Plinko" sous §Specs Notion.

## Décisions prises

- **DROPL = nom de marque/produit affiché** (wordmark, écrans, callouts onboarding). **"Plinko" = identifiant tech interne** : repo `M4tthux/plinko`, dossier `plinko_app/`, classe `PlinkoGame`, clé prefs `plinko_has_seen_tour`, URL `m4tthux.github.io/plinko`, équipe `Balleck Team`. **Pas de rename code/repo au MVP** — séparation propre marque ↔ tech, à reconsidérer Post-MVP si DROPL se consolide.
- **Refonte code wordmark différée à une session dev dédiée** (un problème = une session). Build 59 reste intact, décalage tracé en §7 du spec.
- **Format wordmark DROPL** : 3 `<text>` SVG distincts (DR / O / PL), Space Grotesk 700, baseline offset O = +10 unités SVG (≈ 19 % cap-height), ls = `size × −0.046`, blanc pur. Lockup splash 52px (canvas `#050510`), header 40px. Taille mini 28px (sous → DROPL plat). Animation O entrée uniquement sur splash.

## Problèmes rencontrés

- Aucun blocage — tâche purement documentaire. Diff zip vs handoff existant : 2 fichiers touchés (README + 1 nouveau), reste inchangé.

## Décalages spec vs code identifiés

- **Wordmark "PLINKO" en dur** dans `landing_screen.dart` (Text standard, ls 8px, halo cyan) + cible `wordmarkKey` du step 02 du tour pointe le widget actuel. Texte callout step 02 dit encore "Comment fonctionne Plinko". À refaire en session dédiée. Tracé en §7 du `design-ui-spec.md`.

## Prochaine étape prioritaire

**Session dev "Implémenter wordmark DROPL"** — créer composant Flutter réutilisable `<DroplWordmark size={40|52}>` (3 `<text>` SVG via `flutter_svg` ou `CustomPainter`), remplacer le `Text("PLINKO")` dans `landing_screen.dart`, MAJ texte callout step 02 du tour (`coachmark` / `tour_overlay.dart`), MAJ cible spotlight si la nouvelle box du wordmark change de dimensions. Spec complète : §2bis de `design-ui-spec.md`. Pas de rename de fichiers/clés tech.
