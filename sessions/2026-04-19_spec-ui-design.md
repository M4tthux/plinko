# Session Spec UI Design — 2026-04-19

Création d'une spec UI Design consolidée (Notion + miroir Git) à partir du handoff Claude Design reçu sur l'onboarding. Commit `f1efdb8` sur `claude/plinko-design-assets-wymf7`.

## Ce qui a été fait

- **Audit** — les 3 specs Notion existantes (🎮 Game Design / 🔧 Archi / 🎱 Benchmark) ne couvraient pas la DA ni l'UI. Le handoff Claude Design (`design_handoff/design_handoff_plinko_onboarding_hifi/`) vivait seulement sur GitHub.
- **Nouvelle page Notion 🎨 Design UI** créée par Matthieu (`https://www.notion.so/Design-UI-347d826db45980498628dfd5b720a15c`).
- **`design-ui-spec.md`** créé à la racine — miroir versionné Git, 10 sections FR : DA Deep Arcade, tokens couleurs/typo/background, composants (board/ball/chips/multipliers/callout/spotlight/progress/skip), onboarding 5 steps, state machine, motion spec, §7 décalages spec vs code, sources & assets, questions ouvertes, règle source de vérité.
- **§7 "Décalages connus"** — table explicite des écarts spec vs code actuel (grille 11→12, dim SVG mask → 4 rects, ring halo → bordure sèche 2px, demo ball step 3 absente, dots haut-droite vs bas-gauche, eyebrow absent, auto-launch tour non-gating, typo partielle).
- **`CLAUDE.md` §"Specs Notion"** — ajout de la 4e entrée 🎨 Design UI avec lien Notion + renvoi vers `design-ui-spec.md`.
- **`project-context.md` §"Process / Docs"** — décision tracée : règle source de vérité (intention sur Notion, valeurs exactes dans `plinko_config.dart`, assets binaires dans `design_handoff/`).

## Décisions prises

- **Scope = DA complète + onboarding**, pas onboarding seul — un seul doc = une seule source, évite de recréer un silo "Design UI onboarding" séparé du "Deep Arcade".
- **Langue = FR**, sauf noms de tokens/variables en EN pour cohérence avec le code et le handoff d'origine.
- **Règle source de vérité** : Notion = intention et tokens évolutifs, code Dart (`plinko_config.dart`) = valeurs exactes en prod, `design_handoff/` = assets binaires et prototypes. En cas de conflit page Notion vs code : le code gagne pour les valeurs, la page gagne pour l'intention.
- **§7 vivant** — toute divergence future spec vs code doit être tracée dans §7, pas silencieusement implémentée.

## Problèmes rencontrés

- Aucun blocage — tâche purement documentaire.

## Prochaine étape

1. **Côté Matthieu (PC)** — `git fetch origin && git checkout claude/plinko-design-assets-wymf7 && git pull origin claude/plinko-design-assets-wymf7`, puis copier-coller `design-ui-spec.md` dans la page Notion 🎨 Design UI.
2. **Consolider les versions de design historiques** (parqué pendant la session, à traiter en session dédiée) — assets Gemini (01/04) → refonte (02/04) → benchmark (03/04) → Deep Arcade (18/04) → handoff onboarding (19/04). Identifier la version canonique, archiver les périmées, nettoyer les références mortes (ex. `agents/designer.md` référence un `DESIGN.md` qui n'existe plus).
3. **Refaire le handoff Claude Design avec la grille 12/9** (toujours en attente côté Matthieu) — ce qui permettra de supprimer une bonne partie des décalages du §7.
