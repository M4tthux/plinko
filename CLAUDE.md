# CLAUDE.md — Plinko (Balleck Team)

> Fichier de référence pour Claude Code. Chargé automatiquement à chaque session.
> Source de vérité complète : `project-context.md` | Historique décisions : `decisions-log.md`

---

## Projet

Mini-jeu mobile promotionnel type Plinko, développé en Flutter (Chrome pour dev, iOS+Android pour prod).
Le joueur lance une bille qui rebondit sur des picots vers des cases de récompense.
Le résultat est **pré-déterminé** — la trajectoire est pré-calculée et rejouée frame par frame (illusion de hasard totale).
Destiné à être intégré comme expérience d'engagement pour des marques clientes.

---

## Équipe

| Qui | Rôle |
|---|---|
| **Matthieu** | CPO — décisions produit, validation, game design |
| **Claude** | Dev, Design, QA, Doc, tout le reste |

**Nom d'équipe : Balleck Team**

---

## Règles de session (rétrospective 2026-03-31)

- **Un problème = une session** — ne pas traiter plusieurs bugs dans la même session
- **Commit propre en fin de chaque session** — toujours committer avant de clore
- **Workflow hybride** : Claude Code pour dev/fichiers/terminal/Git/Flutter/trajectoires — Chat (Claude.ai) pour design visuel, screenshots, game design
- Claude ne suppose pas — il pose des questions si quelque chose est ambigu
- Claude itère en delta — ne réécrit pas tout à chaque feedback
- Claude met à jour `project-context.md` et crée un log `sessions/` en fin de session
- **Toute décision validée en cours de session** → écrire dans `project-context.md` immédiatement, sans attendre la fin
- **Session > 45 min** → checkpoint automatique (écriture fichiers + proposition de commit) sans que Matthieu ait à le demander
- Ne pas pousser en production sans validation explicite de Matthieu

---

## Commandes essentielles

```bash
# Lancer l'app Flutter (depuis plinko_app/)
cd plinko_app
flutter run -d chrome

# Vérifier que Flutter tourne (port actif)
# Si crash → relancer flutter run -d chrome dans un nouveau terminal Git CMD

# Régénérer les trajectoires (depuis la racine du projet)
python generate_trajectories.py
# → Vérifier 70/70 dans la sortie console
# → Le fichier est écrit directement dans plinko_app/assets/trajectories.json

# Git — commit de fin de session
git add <fichiers>
git commit -m "Session X — description courte"

# Vérifier l'état du projet
flutter doctor
```

**Important** : Flutter fonctionne uniquement dans **Git CMD** sur Windows (PATH `C:\flutter\bin` configuré via variables d'environnement utilisateur, pas dans PowerShell/cmd standard).

---

## Fichiers critiques

| Fichier | Rôle |
|---|---|
| `plinko_app/lib/config/plinko_config.dart` | **Config centrale** — toutes les valeurs de plateau |
| `plinko_app/lib/game/plinko_game.dart` | Jeu principal — collisions, loader, caméra |
| `plinko_app/lib/game/ball.dart` | Bille — physique + replay frame par frame |
| `plinko_app/lib/game/board.dart` | Plateau visuel + overlay zones DEBUG |
| `plinko_app/lib/ui/reward_overlay.dart` | Overlay récompense (fade-in, jackpot or) |
| `plinko_app/lib/ui/config_panel.dart` | Sliders live + debug + sauvegarde configs |
| `plinko_app/lib/data/trajectory_loader.dart` | Lecture JSON + sélection trajectoire |
| `plinko_app/lib/models/prize_lot.dart` | Table de lots (PrizeLot + LandedResult) |
| `plinko_app/lib/models/trajectory.dart` | Modèle de données trajectoire |
| `generate_trajectories.py` | Script Python génération (70 trajectoires) |
| `plinko_app/assets/trajectories.json` | 70 trajectoires pré-calculées (~326 Ko) |
| `project-context.md` | Source de vérité projet |
| `decisions-log.md` | Historique complet de toutes les décisions |

---

## Config plateau actuelle (refonte physique standard — 2026-04-09)

> Build actuel : **36** (déployé sur `m4tthux.github.io/plinko`)

| Paramètre | Valeur | Notes |
|---|---|---|
| `worldWidth` | **12.40** (calculé) | = (rows-1) × pegGX + 2 × pegRadius |
| `worldHeight` | 24.0 | Hauteur totale |
| `zoom` | 24.0 | Zoom caméra |
| `gravity` | **12.0** | Réduit pour sub-stepping |
| `rows` | **8** | Last row = 8 picots → 7 gaps = 7 cases |
| `startRow` | **2** | Commence à 3 picots (6 rangées visibles) |
| `pegGX` | **1.70** (fixe) | Gap libre = 2× diamètre bille (standard) |
| `pegGY` | 2.0 | Espacement vertical |
| `pegStartY` | 4.5 | Y du rang startRow |
| `pegRadius` | **0.25** | Ratio ~1:1 avec bille |
| `pegRestitution` | **0.35** | Rebond amorti |
| `ballRadius` | **0.30** | Ratio ~1:1 avec picot |
| `ballRestitution` | **0.35** | La gravité domine |
| **Parois latérales** | **Aucune** | Sortie picots du bas = Perdu |
| `slotCount` | 7 | 7 gaps entre 8 picots |
| `jackpotSlotIndex` | 3 | Centre (0-indexed sur 7) |
| `slotStartX` | = pegX(rows-1, 0) | 1er picot du bas |
| `slotEndX` | = pegX(rows-1, rows-1) | Dernier picot du bas |
| `slotWidth` | = pegGX (1.70) | Entre 2 picots |
| `slotWallHeight` | 2.5 | Hauteur cases |

### Physique (refonte build 33-36)
- **Sub-stepping** : 4 sous-pas physiques/frame (empêche le tunneling)
- **Pas de cooldown picots** (inutile avec sub-stepping)
- **Pas de vitesse Y forcée** (la gravité fait le travail)
- **Pas de bords** : sortie = Perdu (standard Plinko)
- **Mode physique forcé** : `forcePhysicsMode = true` (trajectoires en pause)

### CI/CD
- **GitHub Action** : push master → build Flutter web + deploy gh-pages
- URL : `m4tthux.github.io/plinko`
- Toujours incrémenter `kBuildTime` dans `main.dart` avant chaque commit

---

## Architecture trajectoires

- **Trajectoires** : cases × zones × variantes (à régénérer après changement de grille)
- Générées par `generate_trajectories.py` (miroir Python de la physique Dart)
- Stride=1 à la génération → interpolation linéaire dans `_updateReplay()` pour fluidité
- Filtre anti-stagnation : rejet si Y ne progresse pas de 0.5 unités sur 120 frames
- Stockées dans `plinko_app/assets/trajectories.json`
- Si aucune trajectoire dispo → **fallback physique temps réel** (log console détecte ce cas)
- **Règle** : après tout changement de config plateau → régénérer les trajectoires (70/70 obligatoire)

---

## Système de lots

- `PrizeLot` dans `models/prize_lot.dart` — nom, probabilité, isJackpot
- Valeurs par défaut : 1€(30%), 2€(25%), 5€(20%), 10€(13%), 20€(7%), 50€(3%), 1000€(2%)
- **Jackpot unique centré** : case centrale uniquement, jamais en décor sur autres cases
- Tirage : `_drawLot()` dans `plinko_game.dart` — probabiliste avant le lancer
- Assignation cases : `_assignSlots()` + `_assignSlotsDecor()`

---

## Backlog actif

### Haute priorité
- **Visuel end game** : overlay récompense refonte — feux d'artifice, halo, icône €, jackpot or spectaculaire

### Basse priorité
- **LaunchZoneOverlay DEBUG** (Z0–Z4) dans `board.dart` : à retirer avant prod

### Backlog cadrage requis
- **Lourdeur bille** : gravity=18.0 — augmenter ou ajuster replayStride ?
- **Jackpot unique** : hardcoder slot central = jackpot dans `_assignSlots()`
- **Émotion win/lose** : direction visuelle à cadrer avant dev (sobre vs spectaculaire)
- **Build iOS** : nécessite Mac + Xcode + compte Apple Developer

---

## Architecture multi-agents

Ce projet utilise une architecture multi-agents. Quand Matthieu exprime une intention floue, activer le mode orchestrateur avant toute action.

**Sous-agents disponibles :**

| Fichier | Rôle | Se déclenche quand |
|---|---|---|
| `agents/orchestrator.md` | Chef de projet — cadre et route | Intention floue de Matthieu |
| `agents/game-designer.md` | Game Design — mécaniques et équilibrage | Sujet lié au ressenti joueur |
| `agents/designer.md` | Design — visuel, UI, animations | Sujet lié à l'interface |
| `agents/developer.md` | Dev — Flutter, technique, implémentation | Sujet lié au code |
| `agents/benchmark.md` | Veille — marché, concurrents, standards | Décision stratégique ou comparaison |

**Règle :** lire `agents/orchestrator.md` en premier. Il contient le routing complet.

---

## Workflow multi-device

| Outil | Rôle | Accessible depuis |
|---|---|---|
| **GitHub** (`M4tthux/plinko`) | Source de vérité code + contexte | PC + téléphone |
| **Notion** | Board + specs vivantes — source de vérité produit | PC + téléphone |
| **Claude Code local** | Dev complet (Flutter, Chrome, terminal) | PC uniquement |
| **Claude Code remote** | Code, git, agents (pas de Flutter run) | Téléphone via claude.ai |

**Règle de sync :**
- Toujours `git pull` avant de commencer une session
- Toujours `git push` en fin de session
- Mettre à jour Notion en fin de session

---

## Board Notion

`https://www.notion.so/6c1e7a3c58094cadac6313c3a57bbda7`

Statuts : Backlog / En cours / En test / Done / Bloqué

### Specs Notion (pages vivantes, à maintenir à jour)
- 🎮 Game Design — `https://www.notion.so/336d826db45981639b1bf031dd8af08d`
- 🔧 Architecture Technique — `https://www.notion.so/336d826db45981dd9fe4d977798871ea`
- 🎱 Benchmark Physique Bille — `https://www.notion.so/336d826db45981049295d99d645aa8b0`

---

## Environnement dev

| Outil | Version | Notes |
|---|---|---|
| Flutter | 3.41.6 | `C:\flutter\bin` — Git CMD uniquement |
| Python | 3.14.3 | `python generate_trajectories.py` |
| Git | installé | Git CMD |
| Dart | via Flutter | Script offline `generate_trajectories.dart` (Dart non dispo en sandbox) |
| Chrome | — | Cible de test principale (`flutter run -d chrome`) |

**Cibles disponibles** : Chrome uniquement. Android (pas d'Android Studio), iOS (pas de Mac), Windows Desktop (pas de Visual Studio C++) sont indisponibles.

---

## QA visuelle

- Captures dans `screenshots/` avec date dans le nom : `YYYY-MM-DD_description.png`
- Effectuée depuis Chat (Claude.ai) avec partage de screenshot
- À faire après chaque feature validée

---

## Fin de session — checklist

1. Mettre à jour `project-context.md` (décisions, état d'avancement)
2. Créer log dans `sessions/YYYY-MM-DD_nom-session.md`
3. Committer : `git commit -m "Session X — description"`
4. `git push` — **obligatoire** pour sync multi-device
5. Mettre à jour la board Notion si tâches changent de statut
6. Mettre à jour les specs Notion si elles ont évolué
