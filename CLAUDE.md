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

## Config plateau actuelle (validée — Session 9)

| Paramètre | Valeur | Notes |
|---|---|---|
| `worldWidth` | 18.0 | Largeur en unités physiques |
| `worldHeight` | 29.0 | Hauteur totale |
| `gravity` | 18.0 | Unités/s² |
| `pegRadius` | 0.25 | Rayon picot |
| `pegSpacingX` | 3.0 | Espacement horizontal picots |
| `pegSpacingY` | 1.5 | Espacement vertical picots |
| `pegRowCount` | 14 | Nombre de rangées |
| `pegColsOdd` | 6 | Picots/rangée impaire |
| `pegColsEven` | 5 | Picots/rangée paire |
| `pegRestitution` | 0.50 | Rebond picot |
| `ballRadius` | 0.60 | Rayon bille |
| `ballRestitution` | 0.35 | |
| `wallRestitution` | 0.55 | Rebond mur |
| `minWallKick` | 1.5 | Kick minimum anti-couloir |
| `funnelZoneWidth` | 2.5 | Zone entonnoir latéral |
| `funnelForce` | 30.0 | Force entonnoir |
| `slotCount` | 7 | Cases : 10/50/100/500/100/50/10 pts |
| `replayStride` | 4 | Vitesse replay (5=trop lent, 4=bon compromis) |
| `slotWeights` | [6,4,3,1,3,4,6] | Distribution — jackpot central plus rare |
| `launchMin/Max` | 1.0 / 17.0 | Zone de lancer clampée |

---

## Architecture trajectoires

- **70 trajectoires** : 7 cases × 5 zones × 2 variantes
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

## Board Notion

`https://www.notion.so/6c1e7a3c58094cadac6313c3a57bbda7`

Statuts : Backlog / En cours / En test / Done / Bloqué

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
4. Mettre à jour la board Notion si tâches changent de statut
