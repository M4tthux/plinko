---
name: plinko-context-loader
description: >
  Charge le contexte complet du projet Plinko (Balleck Team) avant de démarrer une session de travail.
  Déclencher dès que l'utilisateur veut reprendre le projet Plinko, commencer une session de dev, game design,
  design ou tech. Utiliser pour les phrases : "on reprend", "charge le contexte", "lis le project-context",
  "dev session", "game design session", "on repart de là", "reprends le fil", "contexte Plinko",
  "on attaque", "nouvelle session", "on continue le projet". Également déclencher si l'utilisateur
  mentionne une tâche liée au jeu Plinko sans avoir chargé le contexte au préalable dans la session.
  Ne jamais répondre sur le projet Plinko sans avoir (1) fait `git pull`, (2) lu les fichiers,
  (3) consulté la board Notion — la mémoire entre sessions est vide, git + fichiers + board
  sont la seule source de vérité.
---

# Plinko Context Loader — Balleck Team

Tu démarres (ou reprends) une session de travail sur le projet Plinko.
Exécute les étapes dans l'ordre. L'étape 0 est **bloquante** : ne jamais la sauter.

---

## Étape 0 — Sync Git (MANDATORY, avant toute lecture de fichier)

Depuis `C:\Users\Utilisateur\Projets\Plinko`, exécuter :

```bash
git pull
```

Raison : workflow multi-device (PC + téléphone via claude.ai). Sans pull, tu risques de lire une
version périmée de `project-context.md`, `CLAUDE.md` et `decisions-log.md`, et de committer en
fin de session par-dessus des changements distants. C'est la règle 1 de sync dans `CLAUDE.md`
(section "Workflow multi-device"). Si le pull échoue ou révèle un conflit, s'arrêter et le
signaler avant d'aller plus loin.

Reporter le résultat dans le briefing final (OK / Already up to date / conflit).

---

## Étape 1 — Lire les fichiers et la board Notion (simultanément)

**Fichiers locaux** (`Plinko/` dans le workspace de l'utilisateur) :
1. `CLAUDE.md` — quick reference : règles de session, commandes, config plateau, convention commit, checklist fin de session
2. `project-context.md` — source de vérité : vision, décisions actives, questions ouvertes, état d'avancement, build actuel
3. `decisions-log.md` — historique immuable des décisions (consultation ponctuelle si besoin de contexte historique)
4. Dernier log de session dans `sessions/` (`ls sessions/` + lire le plus récent) — pour savoir ce qui a été fait juste avant

**Note** : `method.md` et `specs/` ont été supprimés lors du cleanup archi du 2026-04-17 — toutes les règles de workflow sont désormais dans `CLAUDE.md`. Les specs projet vivantes sont maintenant sur Notion (voir section suivante).

**Board Notion + Specs** :
- **Board tâches** : database `https://www.notion.so/6c1e7a3c58094cadac6313c3a57bbda7`
  - Pour récupérer les tâches actives avec leur statut, utilise `notion-search` avec `data_source_url: collection://78ff642e-c4ab-4027-a866-af55d0fcda8d` (la data source de la board) — `notion-fetch` sur la database ne retourne que le schéma, pas les pages
  - Repère les tâches **"En cours"**, **"En test"**, **"Bloqué"**
- **Specs vivantes** (à fetch si le sujet de session les concerne) :
  - 🎮 Game Design : `https://www.notion.so/336d826db45981639b1bf031dd8af08d`
  - 🔧 Architecture Technique : `https://www.notion.so/336d826db45981dd9fe4d977798871ea`
  - 🎱 Benchmark Physique Bille : `https://www.notion.so/336d826db45981049295d99d645aa8b0`

---

## Étape 2 — Identifier le focus de la session

- Quel domaine est concerné ? (Game Design / Tech / Design / Dev)
- Quelles tâches sont actives sur la board ?
- Y a-t-il des blocages ou des tâches en attente de validation ?
- Quelle est la prochaine étape logique selon les décisions déjà prises ?

---

## Étape 3 — Présenter le briefing de session

**Règle d'ordre** : la board Notion est la **source primaire des priorités**. Elle ouvre le briefing, avant toute synthèse issue de `project-context.md`. Les décisions/vision du context file sont du *pourquoi*, pas du *quoi faire* — elles viennent après.

```
📋 **Contexte chargé — Session [domaine]**

**Sync :** git pull [OK / Already up to date / conflit signalé]

**🎯 Tâches actives (board Notion — source de vérité) :**
- 🔵 En cours : [liste ou "aucune"]
- 🟡 En test : [liste ou "aucune"]
- 🔴 Bloqué : [liste si applicable]
- ⚪ Backlog prioritaire : [top 2-3 items pertinents pour le domaine de session, ou "à prioriser avec Matthieu"]

**Où on en est :** [état général en 1-2 phrases, synthèse board + dernier log]

**Décisions clés déjà prises** (extraites de project-context.md) :
- [décision 1]
- [décision 2]

**Questions produit ouvertes :** [uniquement si pertinentes pour la session]

Prêt. [question d'amorce ou confirmation directe selon le contexte]
```

---

## Règles importantes

- **Étape 0 non négociable** : toujours `git pull` avant de lire quoi que ce soit
- Ne jamais répondre de mémoire — fichiers + Notion priment toujours
- Si un fichier est absent ou vide, le signaler et proposer de le créer
- Si Notion n'est pas accessible, continuer avec les fichiers seuls et le signaler
- Respecter les règles de session dans `CLAUDE.md` (un problème = une session, commit propre en fin, workflow hybride, cohérence docs project-context ↔ CLAUDE, convention de commit formalisée)
- En fin de session, le skill `plinko-session-close` se déclenche automatiquement
