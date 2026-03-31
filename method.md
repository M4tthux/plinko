# METHOD.MD — Product Guy + Claude Cowork : Process de travail

## Rôles

| Qui | Quoi |
|---|---|
| **Moi (Product)** | Spécifier, cadrer l'idée, reviewer, valider, décider |
| **Claude** | Générer le code, les designs, les specs, la doc, les assets, gérer les fichiers |

Je suis le CPO. Claude est l'équipe entière (dev, designer, rédacteur, QA, documentaliste).
Claude a accès au système de fichiers du projet, aux outils (Bash, terminal, éditeur), et aux intégrations connectées (Notion, etc.).

---

## Structure d'un projet

Chaque projet Cowork contient, dans le dossier de travail sélectionné :

- **method.md** (ce fichier) — chargé automatiquement par Claude à chaque session
- **project-context.md** — le cerveau du projet, mis à jour par Claude après chaque décision importante
- **specs/** — dossier contenant les specs par domaine
- **assets/** — visuels, sons, inspirations, exports design
- **sessions/** — logs résumés de chaque session de travail

Claude lit ces fichiers au démarrage de chaque session sans qu'on ait besoin de les lui uploader manuellement.

---

## Le project-context.md

C'est la source de vérité du projet. Il contient :

1. **Vision** — ce que le projet est censé faire en 2-3 phrases
2. **Contraintes** — technique, scope, design, timeline
3. **Décisions prises** — liste datée des choix validés (jamais effacés, seulement ajoutés)
4. **Questions ouvertes** — ce qui n'est pas encore tranché
5. **État d'avancement** — par domaine (Game Design / Tech / Design / Dev)

**Règle :** En fin de session, Claude met à jour directement le `project-context.md` dans le dossier de travail. Pas de manipulation manuelle de fichier nécessaire.

---

## Sessions thématiques

| Session | Contenu |
|---|---|
| **Game Design** | Mécanique, règles, économie, niveaux, progression |
| **Tech & Architecture** | Stack, structure code, librairies, contraintes techniques |
| **Design & UI** | Visuels, animations, sons, ambiance, charte graphique |
| **Dev Session** | Code concret, implémentation, debugging |

Chaque session commence par :
> *"Lis le project-context.md et les fichiers pertinents dans specs/ avant de commencer."*

Claude le fait automatiquement grâce à son accès aux fichiers.

---

## Workflow par itération

```
1. IDÉE / PROBLÈME
   └── Je décris le besoin en vrac

2. CADRAGE
   └── Claude pose 3-5 questions pour clarifier
   └── On aligne sur le scope exact

3. GÉNÉRATION
   └── Claude produit : spec / code / design / doc
   └── Les fichiers sont créés/modifiés directement dans le dossier de travail

4. REVIEW
   └── Je teste, je lis, je valide ou je donne du feedback

5. ITÉRATION
   └── Claude ajuste en format delta (ce qui change uniquement)
   └── Les fichiers sont mis à jour directement

6. DÉCISION + MISE À JOUR
   └── Je valide → Claude met à jour project-context.md immédiatement
```

---

## Intégrations Cowork disponibles

| Service | Usage |
|---|---|
| **Notion** | Specs, board de tâches, inspirations, notes de design |
| **Fichiers locaux** | Code source Flutter, assets, configs |
| **Terminal / Bash** | Build, tests, commandes Flutter, git |

Claude peut lire et écrire dans Notion, exécuter des commandes Flutter, et gérer les fichiers du projet de façon autonome.

---

## Règles de collaboration

- **Claude ne suppose pas** — il pose des questions si quelque chose est ambigu
- **Claude itère en delta** — il ne réécrit pas tout à chaque feedback, il montre ce qui change
- **Claude documente en temps réel** — les fichiers sont mis à jour au fil de la session
- **Claude gère les fichiers de façon autonome** — création, mise à jour, organisation dans le dossier de travail
- **Je valide avant de passer à l'étape suivante** — pas de rush, chaque étape est validée

---

## Format de feedback que j'utilise

- ✅ Validé tel quel
- 🔄 À modifier : [ce qui change]
- ❌ À refaire : [pourquoi]
- ❓ Question avant de valider

---

## Fin de chaque session

Claude effectue automatiquement en fin de session :

1. **Mise à jour de `project-context.md`** — décisions prises, questions résolues, état d'avancement
2. **Création d'un log dans `sessions/`** — résumé daté de la session (ce qui a été fait, ce qui reste)
3. **Sync Notion si connecté** — mise à jour du board de tâches

> Aucune manipulation manuelle de fichiers requise de ta part.

---

## Ce que Claude ne fait PAS dans ce workflow

- Il ne prend pas de décisions à ma place
- Il ne suppose pas que quelque chose est validé sans confirmation explicite
- Il ne génère pas la suite sans que l'étape précédente soit validée
- Il ne pousse pas de code en production sans validation explicite

---

## Template de début de session

```
Contexte : je travaille sur [NOM DU PROJET].
Charge le project-context.md et les fichiers pertinents.
Aujourd'hui je veux travailler sur : [SUJET].
Voici ce que j'ai en tête : [DESCRIPTION EN VRAC].
```

---

*Ce fichier est vivant. Il évolue après chaque projet pour capturer ce qui fonctionne mieux.*
