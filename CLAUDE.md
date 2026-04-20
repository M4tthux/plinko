# CLAUDE.md — Plinko (Balleck Team)

> Fichier de référence pour Claude Code. Chargé automatiquement à chaque session.
> Source de vérité complète : `project-context.md` | Historique décisions : `decisions-log.md`

---

## Équipe

| Qui | Rôle |
|---|---|
| **Matthieu** | CPO — décisions produit, validation, game design |
| **Claude** | Dev, Design, QA, Doc, tout le reste |

**Nom d'équipe : Balleck Team**

---

## Règles de session

- **Spec avant code** — aucune ligne de code sans spec validée par Matthieu. Utiliser le skill `plinko-spec` pour toute nouvelle feature ou modification non triviale.
- **Un problème = une session** — ne pas traiter plusieurs bugs dans la même session
- **Commit propre en fin de chaque session** — toujours committer avant de clore
- **Workflow hybride** : Claude Code pour dev/fichiers/terminal/Git/Flutter/trajectoires — Chat (Claude.ai) pour design visuel, screenshots, game design
- Claude ne suppose pas — il pose des questions si quelque chose est ambigu
- Claude itère en delta — ne réécrit pas tout à chaque feedback
- Claude met à jour `project-context.md` et crée un log `sessions/` en fin de session
- **Toute décision validée en cours de session** → écrire dans `project-context.md` immédiatement, sans attendre la fin
- **Cohérence docs** : en fin de session, vérifier que `project-context.md` n'a ni doublons ni contradictions avec `CLAUDE.md` (cf. checklist fin de session)
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

# Vérifier l'état du projet
flutter doctor
```

---

## Convention de commit

**Format** : titre préfixé (≤72 car.) + corps bullets (quoi + pourquoi) + trailer `Co-Authored-By`.
Préfixes : `Build N —`, `Fix —`, `Cleanup Phase N —`, `Session N —`, `Refacto —`, `Docs —`.
**Toujours via HEREDOC** pour préserver le formatage multi-ligne.

```bash
git commit -m "$(cat <<'EOF'
Build 42 — titre court

- Quoi + pourquoi (pas le comment)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

**Règles dures :**
- Jamais `git add -A` / `git add .` — lister les fichiers par nom
- Jamais `--no-verify` / `--amend` sans instruction explicite
- 1 commit = 1 changement cohérent
- Avant chaque build déployé : incrémenter `kBuildTime` dans `main.dart`
- Flutter ne tourne que dans **Git CMD** sur Windows (PATH `C:\flutter\bin`)

---

## Fichiers critiques

| Fichier | Rôle |
|---|---|
| `plinko_app/lib/config/plinko_config.dart` | **Config centrale** — toutes les valeurs de plateau |
| `plinko_app/lib/game/plinko_game.dart` | Jeu principal — collisions, loader, caméra |
| `plinko_app/lib/game/ball.dart` | Bille — physique + replay frame par frame |
| `plinko_app/lib/game/board.dart` | Plateau visuel + overlay zones DEBUG |
| `plinko_app/lib/ui/config_panel.dart` | Sliders live + debug + sauvegarde configs |
| `plinko_app/lib/ui/widgets/dropl_wordmark.dart` | Wordmark DROPL réutilisable (CustomPainter, 3 TextPainter DR/O/PL) — Build 60 |
| `plinko_app/lib/data/trajectory_loader.dart` | Lecture JSON + sélection trajectoire |
| `plinko_app/lib/models/prize_lot.dart` | Table de lots (PrizeLot + LandedResult) |
| `plinko_app/lib/models/trajectory.dart` | Modèle de données trajectoire |
| `generate_trajectories.py` | Script Python génération (70 trajectoires) |
| `plinko_app/assets/trajectories.json` | 70 trajectoires pré-calculées (~326 Ko) |
| `project-context.md` | Source de vérité projet |
| `decisions-log.md` | Historique complet de toutes les décisions |

---

## Config plateau actuelle

> Build **64** — `m4tthux.github.io/plinko`. Grille 10 rangées visibles / 12 picots bas / **9 cases découplées**. **Direction Deep Arcade** (fond noir, picots blancs, cases fin néon, bille magenta). **Contrôles mise + nombre de billes** en bas (tap-to-launch retiré). **Typo globale** Space Grotesk + JetBrains Mono (Build 63). **HUD top aligné 40px** balance + (?) + ⚙ sur une ligne, bouton (?) relance le tour à tout moment (Build 64). Responsive mobile + desktop inchangé depuis Build 46.

| Paramètre | Valeur | Notes |
|---|---|---|
| `worldWidth` | **8.88** (calculé) | = (rows-1) × pegGX + 2 × pegRadius |
| `worldHeight` | **18.0** | Conservé — caméra centre sur le contenu réel |
| `zoom` | **dynamique** | `screenWidth × 0.96 / worldWidth` (plus de constante) |
| `gravity` | 12.0 | Sub-stepping 4× |
| `rows` | **12** | Last row = 12 picots |
| `startRow` | **2** | Commence à 3 picots (**10 rangées visibles**) |
| `pegGX` | **0.80** | Espacement horizontal entre picots |
| `pegGY` | **0.70** | Quasi-équilatéral (0.80×0.866=0.693) |
| `pegStartY` | **3.0** | Y du rang startRow |
| `pegRadius` | **0.14** | +20% vs Build 41 (lisibilité mobile) |
| `pegRestitution` | 0.35 | Rebond amorti |
| `ballRadius` | **0.19** | Ratio **~1.36×** pegRadius |
| `ballStartY` | **1.8** | Émerge du LaunchHole |
| `ballRestitution` | 0.35 | La gravité domine |
| **Parois latérales** | Aucune | Sortie picots du bas = Perdu |
| `slotCount` | **9** | Découplé des picots |
| `jackpotSlotIndex` | **4** | Centre (0-indexed sur 9) |
| `slotStartX` | = pegX(rows-1, 0) | 1er picot du bas |
| `slotEndX` | = pegX(rows-1, rows-1) | Dernier picot du bas |
| `slotWidth` | = (slotEndX − slotStartX) / 9 | **Découplé** : ne dépend plus de pegGX |
| `slotWallHeight` | **1.2** | Scaled pour grille compacte |
| **LaunchHole** | maintenu | Trou sombre en haut, émergence bille |

### Physique
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

## Système de multiplicateurs

9 cases, multiplicateurs positionnels fixes symétriques. **Échelle réduite Build 49** (voir `project-context.md` pour le pourquoi).

```
Index :  0    1    2    3    4    5    6    7    8
Mult  :  x10  x2   x0.5 x0.1 x0.1 x0.1 x0.5 x2   x10
```

**Économie :** balance 50€, mise sélectionnable 1/2/5/10€ via bouton (défaut 1€), gain = `bet × mult[case]`, sortie du plateau = perdu.
**Lancer (Build 54) :** boutons "1 / 2 / 5 / 10 billes" en bas d'écran. Tap-to-launch retiré. Rafale espacée de 120 ms, boutons grisés tant qu'une bille n'a pas fini son parcours. `betAmountNotifier` + `ballsInFlightNotifier` dans `PlinkoGame`.
**Animation "+X€"** (Build 41) : popup center screen (scale bump + fade 900ms), or si ≥1€, bleuté sinon.

Code : `PlinkoConfig.slotMultipliers` + `slotMultiplierLabel(i)` — crédit : `PlinkoGame._creditLanding()` — popup : `_GainPopup` dans `main.dart` — contrôles : `_BottomControls`, `_BetButton`, `_LaunchButton` dans `main.dart`.

---

## Backlog actif

> Questions ouvertes détaillées dans [`project-context.md`](project-context.md).

### Haute priorité
- **VFX Phase 2** : flash case, screen shake, scale pulse à l'atterrissage

### Basse priorité
- **LaunchZoneOverlay DEBUG** (Z0–Z4) dans `board.dart` : à retirer avant prod
- **Build natif iOS/Android** : Mac + Xcode requis (ou CI cloud Codemagic / Bitrise)

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
- 🎨 Design UI — `https://www.notion.so/Design-UI-347d826db45980498628dfd5b720a15c` (miroir Git : `design-ui-spec.md`)

### Naming — DROPL vs Plinko
**Marque/produit affiché = DROPL** (rebrand wordmark 2026-04-20, "O abaissé" — voir §2bis `design-ui-spec.md`).
**"Plinko" = identifiant tech interne** : repo `M4tthux/plinko`, dossier `plinko_app/`, classe `PlinkoGame`, clé prefs `plinko_has_seen_tour`, URL `m4tthux.github.io/plinko`, équipe `Balleck Team`. **Ne pas renommer le code / repo au MVP.**

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
2. **Cohérence docs** : vérifier que `project-context.md` n'a ni doublons ni contradictions avec `CLAUDE.md` (config plateau, décisions, build actuel, état d'avancement). En cas de divergence → CLAUDE.md = quick ref, project-context.md = source de vérité : corriger CLAUDE.md si project-context vient d'être mis à jour.
3. Créer log dans `sessions/YYYY-MM-DD_nom-session.md`
4. Committer : `git commit -m "Session X — description"`
5. `git push` — **obligatoire** pour sync multi-device
6. Mettre à jour la board Notion si tâches changent de statut
7. Mettre à jour les specs Notion si elles ont évolué
