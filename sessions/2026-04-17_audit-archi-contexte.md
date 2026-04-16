# Session 2026-04-17 — Audit archi contexte + Phase 1 dedup

> Deuxième session du jour après `2026-04-17_cleanup-archi-repo.md`.

## Contexte

Matthieu demande un diagnostic complet du système de chargement de contexte avant de reprendre le projet. Trois mécanismes suspectés de se chevaucher : hook SessionStart (commit d4f9511 de la veille), CLAUDE.md natif, skill `plinko-context-loader`. Vérifier aussi si le decisions-log.md refondu dans ab7f839 est bien branché.

## Diagnostic

**3 mécanismes, doublon confirmé :**
- Hook `.claude/settings.json` : `git pull` + `cat project-context.md` + dernier log `sessions/`
- CLAUDE.md : chargé nativement par Claude Code
- Skill `plinko-context-loader` (phrases trigger) : refait `git pull`, relit les 3 .md + dernier log + Notion

Quand le skill se déclenche après le hook → `git pull` x2, project-context.md lu x2, dernier log x2. Seules vraies additions du skill = Notion + decisions-log.md.

**decisions-log.md orphelin au boot** : le hook ne le lit pas. Lu uniquement par le skill. L'index ajouté dans ab7f839 ne sert que si le skill se déclenche.

**Redondances concrètes identifiées** :
- Vision : project-context §Vision ≈ CLAUDE.md §Projet (quasi mot pour mot)
- Build 41 : project-context §Build actuel ≈ CLAUDE.md §Système de multiplicateurs + §Config plateau
- Process : project-context §Process ≈ CLAUDE.md §Règles de session
- Backlog : project-context §Questions ouvertes ≈ CLAUDE.md §Backlog actif
- Notion URLs : dupliquées dans CLAUDE.md + skill

Auto-injecté au démarrage : ~6 100 tokens. Avec skill : ~7 900.

## Décisions

**Refacto par phases** (validé par Matthieu) :
- **Phase 1** (cette session) — dedup des .md uniquement
- **Phase 2** (différée après 2 sessions de test) — refonte hook + skill : hook étendu à `head decisions-log.md` (index), skill réduit à Notion seul (`plinko-notion-sync`)

**Arbitrage vision** : après hésitation sur quoi supprimer, décision = vision dans `project-context.md` uniquement (c'est son rôle de source de vérité produit), §Projet retiré de CLAUDE.md.

## Actions

- Commit `b481b51` — snapshot marker (tree était clean, `--allow-empty`)
- Commit `55a2c6a` — **Refacto — dedup project-context vs CLAUDE (Phase 1)** :
  - CLAUDE.md : retrait §Projet (−9 lignes) — 273 → 264 lignes
  - project-context.md : retrait §Build actuel + §Process (−21 lignes) — 106 → 85 lignes
  - Total : −30 lignes, aucune info unique perdue
- Push master

## Vérifications faites avant édition

- §Vision vs §Projet : quasi identiques → flaggé à Matthieu avant de toucher
- §Build actuel → couvert par CLAUDE.md §Système de multiplicateurs + §Config plateau
- §Process → 3 des 4 bullets couverts par CLAUDE.md §Règles de session, hiérarchie docs préservée dans l'en-tête l.3 de project-context.md

## Prochaine session

- **Test** de la Phase 1 : vérifier que le briefing de boot reste correct sans les sections supprimées (le hook continue de cat project-context.md, mais raccourci)
- Après **2 sessions de test OK** → Phase 2 : étendre le hook (cat head decisions-log.md), réduire le skill à Notion
- Backlog produit inchangé : visuel end game jackpot x100, retirer LaunchZoneOverlay DEBUG, VFX Phase 2
