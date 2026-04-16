# Session 2026-04-17 — Cleanup archi repo

## Contexte

Matthieu démarre la session en voulant vérifier que le local est aligné avec GitHub master (Build 41). Un ami lui a dit que l'archi du repo n'était pas propre. Objectif : repartir d'une base saine.

## Actions

### Alignement initial
- `git pull` bloqué par 5 fichiers modifiés non committés (résidus VFX Phase 1 pré-refonte Stake)
- Stash + pull → 4 conflits → abandon du merge → `git checkout HEAD -- <5 fichiers>` pour repartir propre sur Build 41 (`e8e41a3`)
- Stash supprimé + dossier local `gh-pages-deploy/` (ancien build web manuel) supprimé
- **Confirmé** : local = `origin/master` = Build 41, 100% sync

### Cleanup en 4 phases (5 commits)

**Phase 1 — hygiene Git** (`eb43961`, -350 lignes)
- `git rm brainstorm.skill` (seul .skill tracké malgré `.gitignore`)
- `git rm scripts/render_docs.py` (générateur HTML orphelin)

**Phase 2 — platforms + assets lourds** (`4d3d673`, -3091 lignes, **-65 Mo**)
- `plinko_app/{linux,macos,windows}/` — 56 fichiers scaffolding Flutter inutiles (projet cible web + iOS/Android)
- `Inspirations/` — 56 Mo d'images HD + vidéo .mov (références visuelles)
- `assets/` racine — 8,9 Mo d'images IA ChatGPT/Gemini non utilisées
- `method.md` — template générique Cowork remplacé par CLAUDE.md
- Nettoyage disque : HTML orphelins dans `Informations générales/` + dossier `specs/` (contenait uniquement des HTML orphelins)

**Phase 3 — docs obsolètes** (`0b70ff5`, -600 lignes)
- `DESIGN.md` (310 lignes) — grille obsolète (ROWS=10, GX=32) pré-refonte Stake
- `Informations générales/` entier (3 fichiers, 290 lignes) :
  - `architecture.md` : décrit structure avec `method.md`/`specs/`/`assets/` déjà supprimés
  - `environnement.md` : redondant avec section "Environnement dev" de CLAUDE.md
  - `outils.md` : daté mars, parle de Notion "post-MVP" alors qu'utilisé quotidiennement
- **Gardé** : `agents/` (5 fichiers routing multi-agents, décision Matthieu)

**Phase 4 — refonte project-context.md** (`3f50cd5`, -74 lignes nettes)
- project-context.md refondu complètement pour Build 41 (413 → 239 lignes)
  - Plus de références Build 36 / 7 cases / mode PrizeLot / "Perdu"
  - Section "Mode multiplicateur casino" cohérente avec Build 41
  - Structure fichiers actualisée, fichiers fantômes supprimés
- plinko_app/README.md : template Flutter générique → README projet Plinko (commandes, structure, liens docs)

### Nouvelles règles ajoutées à CLAUDE.md

**Cohérence docs** (`aef6160`) : en fin de session, vérifier que project-context.md n'a ni doublons ni contradictions avec CLAUDE.md. Règle d'arbitrage : project-context.md = source de vérité, CLAUDE.md = quick ref. Aussi sauvegardé en mémoire durable (`feedback_docs_coherence.md`).

**Convention de commit** (`f9d4de5`) : formalisation du format déjà pratiqué
- Titre préfixé (`Build N —`, `Fix —`, `Cleanup Phase N —`, `Session N —`, `Refacto —`, `Docs —`)
- Corps en bullets (quoi + pourquoi)
- Trailer `Co-Authored-By: Claude Opus 4.6`
- HEREDOC obligatoire
- Règles dures : pas de `git add -A/.`, pas d'`--amend`/`--no-verify` sans demande, 1 commit = 1 changement cohérent

## Bilan

**6 commits pushés :** `eb43961` → `4d3d673` → `0b70ff5` → `3f50cd5` → `aef6160` → `f9d4de5`

**Impact total :** -4115 lignes, -65 Mo sur disque

**Structure finale du repo** (propre, 1 fichier = 1 rôle) :
```
Plinko/
├── CLAUDE.md                    ← quick reference Claude Code
├── project-context.md           ← source de vérité
├── decisions-log.md             ← historique immuable
├── agents/                      ← routing multi-agents (5 fichiers)
├── sessions/                    ← logs datés
├── screenshots/                 ← QA visuelle
├── scripts/serve_web.sh         ← build web + serveur local
├── generate_trajectories.py     ← script Python prod
├── plinko_app/                  ← Flutter app (android/ios/web uniquement)
└── .github/workflows/           ← CI deploy web
```

## État projet à la clôture

- **Build 41** déployé sur `m4tthux.github.io/plinko`
- Code inchangé (aucun .dart modifié dans cette session)
- Repo 100% aligné GitHub ↔ local sur `f9d4de5`
- Working tree clean

## Prochaine session

Repartir d'une base saine pour attaquer le **backlog produit** :
- Visuel end game (feux d'artifice jackpot x100, halo or)
- Retirer LaunchZoneOverlay DEBUG avant prod
- Cadrer : lourdeur bille (gravity), émotion win/lose, Build iOS
