# PROJECT CONTEXT — Plinko (Balleck Team)

> Source de vérité du projet. Mis à jour par Claude après chaque décision validée.
> Quick reference Claude Code : [`CLAUDE.md`](CLAUDE.md) | Historique complet : [`decisions-log.md`](decisions-log.md)

---

## Vision

Mini-jeu mobile promotionnel de type Plinko, développé en Flutter (web + iOS/Android).
Le joueur tape pour lancer une bille qui rebondit sur des picots avant d'atterrir sur une case à multiplicateur.
Le résultat est pré-déterminé (trajectoire pré-calculée et rejouée frame par frame) tout en donnant une illusion de hasard authentique.
Destiné à être intégré comme expérience d'engagement pour des marques clientes.

---

## Équipe

| Qui | Rôle |
|---|---|
| **Matthieu** | CPO — décisions produit, validation, game design |
| **Claude** | Équipe entière — Dev, Design, QA, Doc |

**Nom d'équipe : Balleck Team**

---

## Contraintes

| Domaine | Contrainte |
|---|---|
| **Framework** | Flutter (test : Chrome — prod : iOS + Android) |
| **Moteur physique** | Flame (runtime) — physique manuelle, pas de Forge2D (incompatible Web) |
| **Génération trajectoires** | `generate_trajectories.py` — miroir Python de la physique Dart |
| **Scope MVP** | Jouable sur mobile via web (GitHub Pages) — iOS/Android build = post-MVP |
| **Config MVP** | Codée en dur dans `plinko_config.dart` — pas de backend |
| **Post-MVP** | Deeplink, token signé, SDK marque, personnalisation thème marque |

---

## Build actuel : **41** (2026-04-12)

**URL déployée** : `m4tthux.github.io/plinko`
**CI/CD** : push master → GitHub Action → build Flutter web → gh-pages (auto)

### Ce que fait le build 41

- **Tap = lancer 1 bille (−1€)** depuis le centre avec micro-jitter ±0.2
- **Balance initiale : 50€** affichée en coin haut-gauche
- **Multi-ball** : plusieurs billes peuvent coexister à l'écran
- **17 cases à multiplicateurs fixes** (symétrique) : x100 bords → x0.1 centre
- **Gain = 1€ × mult[case]** au landing — popup flottant "+X€" center screen (900ms)
- **Sortie du plateau** = mise perdue (pas de crédit)

---

## Configuration plateau (plinko_config.dart)

> Valeurs actives Build 41. Toute modif → régénérer trajectoires (70/70).

| Paramètre | Valeur | Notes |
|---|---|---|
| `worldWidth` | **13.84** (calculé) | `(rows-1) × pegGX + 2 × pegRadius` |
| `worldHeight` | 18.0 | Plateau compact |
| `zoom` | 24.0 | Caméra |
| `gravity` | 12.0 | Sub-stepping ×4 |
| `rows` | **18** | Last row = 18 picots → 17 gaps = 17 cases |
| `startRow` | **2** | 16 rangées visibles (commence à 3 picots) |
| `pegGX` | **0.80** | Espacement horizontal |
| `pegGY` | **0.70** | Quasi-équilatéral (0.866 × pegGX) |
| `pegStartY` | 3.0 | Y du rang startRow |
| `pegRadius` | **0.12** | Petit — proportions Stake |
| `pegRestitution` | 0.35 | Rebond amorti |
| `ballRadius` | **0.16** | Ratio ~1.33× pegRadius |
| `ballStartY` | 1.8 | Émerge du LaunchHole |
| `ballRestitution` | 0.35 | Gravité domine |
| `slotCount` | **17** | Entre les 18 picots du bas |
| `slotWallHeight` | 1.2 | Bords de case |
| **Parois latérales** | Aucune | Sortie = Perdu (mise retirée) |

### Multiplicateurs (17 cases, symétrique)

```
Index : 0    1   2   3  4  5    6    7    8    9    10   11  12 13 14 15  16
Mult  : x100 x25 x10 x5 x2 x0.5 x0.2 x0.1 x0.1 x0.1 x0.2 x0.5 x2 x5 x10 x25 x100
```

### Physique (refonte Builds 33-41)

- **Sub-stepping** : 4 sous-pas/frame (empêche le tunneling)
- **Collision picot** : réflexion classique `v' = v - (1+e)·dot(v,n)·n`
- **Lancement centre + jitter** ±0.2 (standard industrie : Stake, BGaming)
- **Mode physique forcé** : `forcePhysicsMode = true` — trajectoires désactivées
- Pas de cooldown picots, pas de vitesse Y forcée, pas de parois latérales

---

## Décisions actives (Build 41)

> Historique complet : [`decisions-log.md`](decisions-log.md).

### Tech
- Flutter + Flame, physique manuelle (pas de Forge2D)
- Sub-stepping ×4 contre le tunneling
- Config codée en dur `plinko_config.dart`
- CI : push master → deploy web auto via GitHub Action
- Grille triangulaire : `(rows-1) × pegGX + 2 × pegRadius` dérive `worldWidth`

### Game Design
- Illusion de hasard totale — résultat pré-déterminé, trajectoire rejouée
- **Mode multiplicateur casino** (depuis Build 40) — plus de PrizeLot probabiliste
- **1 tap = 1 bille = −1€**, multi-ball autorisé
- **17 multiplicateurs fixes** symétriques (x100 bords → x0.1 centre)
- Lancement centre + jitter, pas de parois, sortie = Perdu
- Pas de sons / haptique pour le MVP
- Ambiance : futuriste / arcade — néons, fond sombre, bille lumineuse

### Process
- **Un problème = une session**
- **Commit propre en fin de chaque session** (incrémenter `kBuildTime` dans `main.dart`)
- **Workflow hybride** : Claude Code (dev/fichiers/Git/Flutter) — Chat (design visuel, game design)
- `CLAUDE.md` = référence native Claude Code
- `project-context.md` = source de vérité (ce fichier), mis à jour en live
- `decisions-log.md` = historique immuable

---

## Architecture trajectoires

- **Mode physique actuellement forcé** (`forcePhysicsMode = true`) — trajectoires en pause
- Générées par `generate_trajectories.py` (miroir Python de la physique Dart)
- Stride=1 à la génération → interpolation linéaire dans `Ball._updateReplay()` pour fluidité
- Filtre anti-stagnation : rejet si Y ne progresse pas de 0.5 sur 120 frames
- Stockées dans `plinko_app/assets/trajectories.json`
- Fallback physique temps réel si aucune trajectoire dispo (log console)
- **Règle** : toute modif config plateau → régénérer les trajectoires

---

## Structure des fichiers

```
Plinko/
├── CLAUDE.md                   ← quick reference Claude Code
├── project-context.md          ← ce fichier (source de vérité)
├── decisions-log.md            ← historique immuable
├── agents/                     ← sous-agents (orchestrator, game-designer, designer, developer, benchmark)
├── sessions/                   ← log daté par session
├── screenshots/                ← QA visuelle
├── scripts/serve_web.sh        ← build web + serveur local
├── generate_trajectories.py    ← script Python génération
├── plinko_app/                 ← Flutter app
│   ├── lib/
│   │   ├── config/plinko_config.dart   ← config centrale
│   │   ├── game/
│   │   │   ├── plinko_game.dart        ← jeu principal (collisions, caméra)
│   │   │   ├── ball.dart               ← bille (physique + replay + VFX)
│   │   │   └── board.dart              ← plateau visuel + DEBUG overlays
│   │   ├── ui/
│   │   │   ├── reward_overlay.dart     ← legacy (mode PrizeLot)
│   │   │   └── config_panel.dart       ← sliders live + save configs
│   │   ├── models/
│   │   │   ├── trajectory.dart         ← modèle trajectoire
│   │   │   └── prize_lot.dart          ← legacy (mode PrizeLot)
│   │   ├── data/trajectory_loader.dart ← lecture JSON
│   │   └── main.dart                   ← UI + balance + popup gain
│   ├── assets/trajectories.json        ← 70 trajectoires pré-calculées
│   ├── scripts/generate_trajectories.dart ← fallback Dart (si sandbox Dart dispo)
│   └── web/                            ← index.html + manifest PWA
└── .github/workflows/deploy-web.yml    ← CI deploy gh-pages
```

---

## Board Notion

- **Board** : `https://www.notion.so/6c1e7a3c58094cadac6313c3a57bbda7`
- 🎮 **Game Design** : `https://www.notion.so/336d826db45981639b1bf031dd8af08d`
- 🔧 **Architecture Technique** : `https://www.notion.so/336d826db45981dd9fe4d977798871ea`
- 🎱 **Benchmark Physique Bille** : `https://www.notion.so/336d826db45981049295d99d645aa8b0`

Statuts Board : Backlog / En cours / En test / Done / Bloqué.

---

## Questions ouvertes

### Game Design
- Écran d'intro : animation bille ou simple logo marque ? (basse priorité)
- Équilibrage multiplicateurs x100 aux bords : probabilité réelle vs ressenti joueur à monitorer

### Dev / Backlog
- **LaunchZoneOverlay DEBUG** (Z0–Z4) dans `board.dart` — à retirer avant prod
- **Build iOS/Android** : nécessite Mac + Xcode + compte Apple Developer (ou CI cloud : Codemagic, Bitrise)
- **Visuel end game** : overlay récompense (feux d'artifice, halo, jackpot or) non utilisé en mode multiplicateur — à décider si on garde pour jackpot x100

### Tech / Post-MVP
- Comment la récompense est transmise à la marque après la partie ? (webhook, API ?)
- Format du token signé (JWT ? HMAC ? durée validité ?)
- Multi-tenant : plateau configurable par marque ou identique ?
- Distribution : App Store distinct par marque ou app générique ?

---

## État d'avancement

| Domaine | Statut | Notes |
|---|---|---|
| **Game Design** | 🟢 Build 41 validé | Mode multiplicateur casino + tap multi-ball |
| **Tech & Architecture** | 🟢 Stabilisé | Sub-stepping, physique pure, grille triangulaire |
| **Design & UI** | 🟡 En cours | VFX Phase 1 OK (trail, squash, glow). Phase 2 : flash case, screen shake, scale pulse |
| **Dev** | 🟢 Build 41 | Animation "+X€" validée |
| **CI/CD** | 🟢 Done | Auto-deploy gh-pages sur push master |
| **Test mobile** | 🟢 Opérationnel | Accessible depuis Safari/Chrome iPhone via GitHub Pages |
| **Flutter local** | 🟢 Installé | v3.41.6 Windows (Git CMD) |
| **Build natif iOS/Android** | 🔴 Bloqué | Nécessite Mac + Xcode |

---

## Environnement dev

| Outil | Version | Notes |
|---|---|---|
| Flutter | 3.41.6 | `C:\flutter\bin` — Git CMD uniquement |
| Python | 3.14.3 | `python generate_trajectories.py` |
| Git | installé | Git CMD |
| Chrome | — | Cible de test principale (`flutter run -d chrome`) |

**Cibles dispo** : Chrome uniquement en local. iOS/Android → via déploiement web GitHub Pages ou futur Mac/Android Studio.

---

*Dernière mise à jour : 2026-04-17 (session cleanup archi repo + refonte Build 41)*
