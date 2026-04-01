# PROJECT CONTEXT — Plinko (Balleck Team)

> Source de vérité du projet. Mis à jour par Claude en fin de chaque session.

---

## Vision

Mini-jeu mobile promotionnel de type Plinko, développé en Flutter (iOS + Android).
Le joueur glisse son doigt pour viser et relâche pour lancer une bille qui rebondit sur des picots avant d'atterrir dans une case de récompense — dont le résultat est pré-déterminé mais la trajectoire semble authentique.
Destiné à être intégré comme expérience d'engagement pour des marques clientes.

---

## Équipe

| Qui | Rôle |
|---|---|
| **Matthieu** | CPO — Product, expérience, mécanique d'engagement |
| **Claude** | Équipe entière — Dev, Design, Spec, QA, Doc |

**Nom d'équipe : Balleck Team** ✅

---

## Contraintes

| Domaine | Contrainte |
|---|---|
| **Framework** | Flutter — iOS + Android |
| **Moteur physique** | Flame (runtime) — physique manuelle (pas de Forge2D, incompatible Web) |
| **Génération trajectoires** | Script Dart offline `generate_trajectories.dart` — réutilise la physique interne |
| **Scope MVP** | Jouable sur device réel, lancé depuis Xcode / Android Studio |
| **Config MVP** | Codée en dur dans `plinko_config.dart` — pas de backend |
| **Post-MVP** | Deeplink, token signé, SDK marque, personnalisation thème |

---

## Configuration plateau actuelle (plinko_config.dart)

> À conserver comme référence — permet de retrouver les valeurs validées.

| Paramètre | Valeur | Notes |
|---|---|---|
| `worldWidth` | 18.0 | Largeur en unités physiques |
| `worldHeight` | 29.0 | Hauteur totale |
| `gravity` | 18.0 | Unités/s² |
| `pegRadius` | **0.25** | Rayon picot |
| `pegSpacingX` | **3.0** | Espacement horizontal picots |
| `pegSpacingY` | **1.5** | Espacement vertical picots |
| `pegColsOdd` | **6** | Picots/rangée impaire |
| `pegColsEven` | **5** | Picots/rangée paire |
| `pegRowCount` | **14** | Nombre de rangées |
| `pegRestitution` | 0.50 | Rebond picot |
| `ballRadius` | **0.60** | Rayon bille (2× taille initiale, validée) |
| `ballRestitution` | 0.35 | |
| `wallRestitution` | 0.55 | Rebond mur |
| `minWallKick` | 1.5 | Kick minimum anti-couloir |
| `funnelZoneWidth` | 2.5 | Zone entonnoir latéral |
| `funnelForce` | 30.0 | Force entonnoir |
| `slotCount` | **7** | Cases : 10/50/100/500/100/50/10 pts |
| `replayStride` | **3** | Vitesse replay — ajusté Session 11 (4=trop lent, 3=bon rythme) |
| `cameraLerp` | 0.08 | Fluidité caméra |
| `cameraLeadY` | 3.0 | Avance caméra vers le bas |
| `launchMin/Max` | 1.0 / 17.0 | Zone de lancer clampée |

---

## Décisions actives

> Décisions qui guident la suite du projet. Historique complet dans [`decisions-log.md`](decisions-log.md).

### Tech & Architecture
- Framework : Flutter (iOS + Android) — test via Chrome (`flutter run -d chrome`)
- Physique manuelle (Flame only) — Forge2D supprimé (incompatible Flutter Web)
- Config MVP codée en dur dans `plinko_config.dart`
- Architecture trajectoires : 70 pré-calculées (7 cases × 5 zones × 2 variantes) — fallback physique si manquante
- Après tout changement de config plateau → régénérer trajectoires (70/70 obligatoire)

### Game Design
- Illusion de hasard totale — résultat pré-déterminé, trajectoire rejouée frame par frame
- One-shot — une seule partie par session
- Pas de sons pour le MVP
- Pas de trajectoire prévisionnelle — lancer à l'aveugle
- Jackpot unique centré : 500€ en case centrale uniquement
- Table de lots réelle (Session 11) : Perdu(33%), 1€(22%), 2€(18%), 5€(12%), 10€(8%), 25€(4%), 50€(2.5%), 500€(0.5% jackpot)
- Ambiance : futuriste / arcade — néons, fond sombre, bille lumineuse

### Process (depuis migration Claude Code — 2026-03-31)
- Workflow hybride : Claude Code (dev/fichiers/terminal/Git) — Chat (design visuel/screenshots/game design)
- Un problème = une session
- Commit propre en fin de chaque session
- `CLAUDE.md` = référence native Claude Code (remplace plinko-context-loader)
- `decisions-log.md` = historique complet de toutes les décisions

---

## Décisions prises (archive — voir decisions-log.md)

| Date | Domaine | Décision |
|---|---|---|
| 2026-03-26 | Équipe | Nom de l'équipe : Balleck Team |
| 2026-03-26 | Process | Méthode de travail : METHOD.MD Cowork |
| 2026-03-26 | Game Design | Ambiance par défaut : futuriste / arcade — néons, fond sombre, bille lumineuse |
| 2026-03-26 | Game Design | Mécanique : simple et unique — lancer, rebonds réalistes, atterrissage en case |
| 2026-03-26 | Game Design | Réalisme physique prioritaire — pas de rebonds hasardeux, illusion totale |
| 2026-03-26 | Game Design | Illusion de hasard totale — le joueur ne sait pas que le résultat est pré-déterminé |
| 2026-03-26 | Game Design | Thémisation prévue (couleurs, logo, récompenses) — post-MVP |
| 2026-03-26 | Game Design | Suspense via caméra (révélation progressive) + son (crescendo) — pas de mécanique artificielle |
| 2026-03-26 | Game Design | Pas de trajectoire prévisionnelle — lancer à l'aveugle |
| 2026-03-26 | Game Design | One-shot — une seule partie par session |
| 2026-03-26 | Game Design | Pas de sons pour le MVP — ni musique ni effets sonores. Sons et haptique repoussés en Post-MVP. |
| 2026-03-19 | Tech | Framework : Flutter (iOS + Android) |
| 2026-03-26 | Tech | Sélection au runtime : détection zone du doigt → lecture mémoire → replay frame par frame |
| 2026-03-19 | Tech | Config MVP codée en dur dans plinko_config.dart |
| 2026-03-19 | Tech | Lancement MVP depuis Xcode / Android Studio |
| 2026-03-26 | Tech | Forge2D supprimé entièrement (incompatible Flutter Web). Physique = manuelle (Flame only). |
| 2026-03-26 | Tech | Flutter v3.41.6 installé sur Windows (C:\flutter). Test via Chrome (flutter run -d chrome). |
| 2026-03-26 | Process | Board Notion créée — source de vérité des tâches. Skills plinko-context-loader + plinko-session-close installés. |
| 2026-03-26 | MVP Scope | Sons, haptique, SDK marque, deeplink, webhook → Post-MVP. MVP = bille + rebonds + case + overlay récompense. |
| 2026-03-27 | Dev | worldHeight réduit de 42 à 29 — cases remontées sous les picots |
| 2026-03-27 | Dev | Suppression dents de scie → parois latérales droites (SideWall) |
| 2026-03-27 | Dev | pegRadius 0.15→0.25, ballRadius 0.22→0.30, pegSpacingX 1.0→2.0, 9/8 picots/rangée, 20 rangées |
| 2026-03-27 | Game Design | slotCount 9→7. Labels : 10pts / 50pts / 100pts / 500pts / 100pts / 50pts / 10pts |
| 2026-03-27 | Dev | Entonnoir latéral : funnelZoneWidth=2.5, funnelForce=30, minWallKick=1.5 |
| 2026-03-27 | Dev | **BUGFIX** — Formule rebond picot corrigée : `v -= n × dot × (1 + restitution)`. L'ancienne formule `(2 × dot × restitution)` annulait la vitesse normale → bille collée. Validé par simulation Python. |
| 2026-03-27 | Dev | Zone de lancer clampée à [pegSpacingX/2, worldWidth-pegSpacingX/2] = [1.0, 17.0] — anti-couloir |
| 2026-03-27 | Dev | Séparateurs de cases solides : `_resolveSlotDividerCollisions()` dans plinko_game.dart |
| 2026-03-27 | Tech | Architecture trajectoires sans Forge2D — `generate_trajectories.dart` réutilise la physique interne du jeu |
| 2026-03-27 | Tech | Génération brute force : 5000 essais par (zone, case), 2 variantes conservées |
| 2026-03-27 | Tech | 70 trajectoires générées (7 cases × 5 zones × 2), 0 manquantes — `assets/trajectories.json` (~1MB) |
| 2026-03-27 | Dev | Ball.replay() : mode replay frame-par-frame depuis JSON. Fallback physique si pas de trajectoire. |
| 2026-03-27 | Dev | replayStride=4 dans plinko_config.dart — vitesse visuelle de la bille, facilement ajustable |
| 2026-03-27 | Dev | slotWeights=[6,4,3,1,3,4,6] pour distribution MVP (Jackpot central = plus rare) |
| 2026-03-27 | Dev | Bug reset bille corrigé : `_resetPending` flag + `_ballInFlight=false` déplacé dans `_resetBall()` |
| 2026-03-27 | Dev | LaunchZoneOverlay DEBUG (Z0–Z4) ajouté dans board.dart — à retirer avant prod |
| 2026-03-27 | Dev | **ConfigPanel** créé (ui/config_panel.dart) — 6 sliders live + validation physique temps réel + bouton Appliquer → rebuildBoard() |
| 2026-03-27 | Dev | Config validée visuellement : ballRadius=0.60, pegRadius=0.25, pegSpacingX=3.0, 6/5 picots, 14 rangées |
| 2026-03-27 | Dev | **BUGFIX** — `const collisionDist` → `final` dans plinko_game.dart (ballRadius/pegRadius sont `static var`, non const) |
| 2026-03-27 | Game Design | Bug "bocal" identifié : bille rebondit dans zone des cases comme dans une boîte — à investiguer session suivante |
| 2026-03-27 | Feature | Sauvegarde configs nommées demandée : bouton Save + nom dans ConfigPanel, persistance locale |
| 2026-03-28 | Dev | Bug orbite picot diagnostiqué (mode physique fallback) : 3 causes — gap séparation trop petit (0.001), kick aléatoire tangentiel, absence de sub-stepping. Fix : augmenter gap de séparation + forcer vitesse de séparation minimum après rebond. |
| 2026-03-28 | Dev | **FIX bug orbite picot** : gap séparation 0.001→0.08 + minExitSpeed=2.5 forcée après rebond picot — `plinko_game.dart` + `generate_trajectories.dart` |
| 2026-03-28 | Dev | **FIX bug bocal** : slotDividerRestitution=0.15 (au lieu de wallRestitution=0.55) dans `_resolveSlotDividerCollisions()` — miroir dans `generate_trajectories.dart` |
| 2026-03-28 | Dev | `generate_trajectories.dart` sync config plateau : pegSpacingX=3.0, pegSpacingY=1.5, pegRowCount=14, pegColsOdd=6, pegColsEven=5, ballRadius=0.60 |
| 2026-03-28 | Dev | `trajectories.json` régénéré : 70/70 trajectoires, 0 manquantes (~1002 Ko) — simulation Python (Dart indisponible en sandbox) |
| 2026-03-28 | Dev | **Overlay récompense** implémenté : `ui/reward_overlay.dart` — fade-in + scale, cyan/or (jackpot), tap pour fermer. Connecté via `ValueNotifier<int?>` dans `PlinkoGame` + `ValueListenableBuilder` dans `main.dart` |
| 2026-03-28 | Dev | **Sauvegarde configs nommées** : classe `_ConfigStorage` (in-memory) + champ nom + bouton 💾 + liste rechargeable/supprimable dans `ConfigPanel` |
| 2026-03-28 | Dev | **Système de table de lots (Dev Session 5)** : `models/prize_lot.dart` (PrizeLot + LandedResult), `plinko_config.dart` (lots + currentSlotAssignment + jackpotSlotIndex), `plinko_game.dart` (_drawLot + _assignSlots + _assignSlotsDecor), `board.dart` (SlotLabel lit depuis currentSlotAssignment), `reward_overlay.dart` (prizeName + isJackpot), `config_panel.dart` (section "Table de lots" scrollable). Non validé — serveur Flutter crashé avant test. |
| 2026-03-28 | Dev | **FIX bug orbite picot v4 (Dev Session 6)** : `plinko_game.dart` — composante Y tangentielle VERS LE BAS préservée (ne plus amortir la descente), cooldown 5→8 frames, kick anti-orbite minDownwardVelocity=1.0. `ball.dart` — détecteur de blocage : si velocity.y < 1.5 pendant 90 frames → impulsion forcée (8.0) + amortissement X (0.2). |
| 2026-03-28 | Tech | Serveur Flutter (:60555) crashé en fin de Dev Session 6 — nécessite relance manuelle (`flutter run -d chrome` dans terminal Windows). |
| 2026-03-28 | Dev | **Dev Session 7** — Serveur relancé sur :50063. App chargée et testée. |
| 2026-03-28 | Dev | **FIX bug replayStride live** : slider ConfigPanel n'appliquait la valeur qu'au clic "Appliquer". Fix : `PlinkoConfig.replayStride = v` appliqué immédiatement dans le callback du slider. Validé par l'utilisateur. |
| 2026-03-28 | Dev | **FIX bug TrajectoryLoader vidé** : `rebuildBoard()` appelait `TrajectoryLoader.clear()` sans recharger les trajectoires → toutes les billes en mode physique fallback après chaque "Appliquer". Fix : suppression de `TrajectoryLoader.clear()` dans `rebuildBoard()` (trajectoires = coordonnées X,Y pures, indépendantes des picots). |
| 2026-03-28 | Dev | **replayStride par défaut** changé de 2 à 3 — vitesse initiale légèrement ralentie (2 = trop rapide selon Matthieu). |
| 2026-03-28 | Dev | **FIX bug asymétrie picots** : formule `offsetX = pegSpacingX/2` ne centrait les picots que si worldWidth divisible par pegSpacingX. Fix : `pegEffectiveSpacingX = worldWidth / pegColsOdd` + `pegOffsetOdd = effectiveX/2`. Résultat : grille toujours symétrique et couvrant tout le plateau. |
| 2026-03-28 | Dev | **Minimum pegColsOdd = 4** (= slotCount/2+1) — garantit qu'au moins un picot couvre chaque case, même en config minimum. |
| 2026-03-28 | QA | **Nouveau bug logué** : mismatch lot tiré vs case d'atterrissage (badge ≠ overlay). Cause principale identifiée = TrajectoryLoader vidé (fixé). Cause secondaire possible = race condition `refreshLotLabels()` pendant vol. Log console ajouté pour détecter le fallback physique. |
| 2026-03-28 | QA | **Nouveau bug logué** : asymétrie picots quand `pegSpacingX` ne divise pas `worldWidth` — fixé cette session. |
| 2026-03-28 | Dev | **Session 8 — FIX bug visuel bille traverse picots** : cause = `stride=2` dans génération sautait la frame de rebond → interpolation linéaire traversait le picot. Fix : interpolation linéaire dans `_updateReplay()` + régénération trajectoires en Python avec `stride=1` (70/70, 1279 Ko). |
| 2026-03-28 | Dev | **Session 8 — FIX taille visuelle bille** : `_visualScale=0.75` dans `ball.dart` — rayon rendu 0.45 au lieu de 0.60 (physique inchangée). Halo réduit (3×→2×, 1.8×→1.4×). |
| 2026-03-28 | Dev | **Session 8 — Anti-orbite renforcé** : `_stuckLimit` 90→30, `_stuckVyMin` 1.5→2.0, `_stuckNudgeY` 8→12, `_stuckDampX` 0.2→0.1. Détection en 0.5s au lieu de 1.5s. |
| 2026-03-28 | Dev | **Session 8 — replayStride** 5→4. Script Python `generate_trajectories.py` créé comme référence de régénération (Dart non dispo sandbox). |
| 2026-03-29 | Dev | **Toggle mode physique forcé** : `PlinkoConfig.forcePhysicsMode` + switch dans ConfigPanel (section 🔧 Debug) — permet de tester l'anti-orbite sans manipuler les fichiers. |
| 2026-03-29 | Dev | **`_visualScale` 1.0** : taille visuelle bille = rayon physique (0.60). La réduction à 0.75 créait un gap visible entre bille et picots. |
| 2026-03-29 | Dev | **Badge version** `kBuildTime` en haut de l'écran — centré, taille 14, incrémenté à chaque session (build 11 à clôture). |
| 2026-03-29 | Game Design | **Jackpot unique centré** : 1000€ en case centrale UNIQUEMENT — exclu des fillers dans `_assignSlots` et `_assignSlotsDecor`. Jamais en décor sur d'autres cases. |
| 2026-03-29 | Game Design | **Valeurs par défaut** : 1€(30%), 2€(25%), 5€(20%), 10€(13%), 20€(7%), 50€(3%), 1000€(2% jackpot). |
| 2026-03-29 | Dev | **Filtre anti-stagnation trajectoires** : `generate_trajectories.py` rejette toute trajectoire où Y ne progresse pas de 0.5 unités sur 120 frames (2s). 70/70 régénérées, 326 Ko. |
| 2026-03-29 | Game Design | **Visuel end game cadré** : prix centré, icône €, feux d'artifice, halo. Jackpot = version or spectaculaire. À implémenter session suivante. |
| 2026-03-31 | Process | **Migration Claude Code décidée** : prochaine session de dev dans Claude Code (terminal), pas dans Cowork. |
| 2026-03-31 | Process | **Environnement complet validé** : Claude Code 2.1.81 + Node 24 + npm 11 + Git + Flutter 3.41.6 + Python 3.14.3 — tout en PATH sur Windows. |
| 2026-03-31 | Process | **CLAUDE.md à créer** : remplacera le skill plinko-context-loader en natif Claude Code. Première action de la prochaine session. |
| 2026-03-31 | Process | **Git à initialiser** : première action de la prochaine session avant tout nouveau code. |
| 2026-03-31 | Process | **Skills manquants identifiés** : plinko-flutter-run (relance serveur), plinko-regen-trajectories (script Python auto), decisions-log.md (séparer historique des décisions actives). |
| 2026-03-31 | Process | **Workflow hybride validé** : Claude Code pour dev/fichiers/terminal — Chat (Cowork/Claude.ai) pour design visuel, screenshots, game design. Bridge = fichiers projet partagés. |
| 2026-03-31 | Dev | **Dev Session 10 — Refonte visuelle end game** : `reward_overlay.dart` v3 — flash blanc, confettis bas→haut (win), feux d'artifice (jackpot), halo pulse ×3, montant shake 1s, dim cases non-gagnantes (board.dart). Couleurs DESIGN.md : or `#f0c040`, surface `#1a1a2e`. |
| 2026-03-31 | Dev | **isLoss ajouté** à `PrizeLot` + `LandedResult` — prépare le tableau de lots avec perte. Mode perte : overlay neutre, fade doux, pas de particules. |
| 2026-03-31 | Dev | **highlightedSlotIndex** dans `PlinkoConfig` — jackpot dim toutes cases sauf la gagnante pendant l'overlay. |
| 2026-03-31 | Dev | **Session 11 — Refonte design néon** : picots ronds avec gradient cyan→violet (4 tons par rangée), fond pyramide glow, cases pill-shape avec gradient + bordure néon. `board.dart` refactorisé. |
| 2026-03-31 | Dev | **Session 11 — Table de lots réelle** : Perdu(33%), 1€(22%), 2€(18%), 5€(12%), 10€(8%), 25€(4%), 50€(2.5%), 500€(0.5% jackpot). `plinko_config.dart` mis à jour. |
| 2026-03-31 | Dev | **Session 11 — replayStride** 4→3. Validé par Matthieu comme bon rythme. |
| 2026-03-31 | Design | **Session 11 — Design validé visuellement** : plateau néon cyan→violet, overlay "Perdu" mode perte confirmé (carte grise, "Pas de chance cette fois…", sans particules). |

---

## Questions ouvertes

### Game Design
- Trajectoire prévisionnelle pendant la visée ? (à arbitrer avant Dev Session 4)
- Écran d'intro : animation de la bille ou simple logo marque ? (basse priorité)
- Vitesse de chute de la bille : replayStride=4 (ajusté Session 8) — à valider à l'usage

### Dev — En test (valider en prochaine session)
- *(aucune tâche en test)*

### Dev — En test (valider visuellement en prochaine session)
- **Overlay win/jackpot** : mode "Perdu" validé (Session 11). Overlay win (flash blanc + confettis) et jackpot (feux d'artifice or) non encore testés visuellement — code correct, à valider.

### Dev — Backlog prioritaire
- **LaunchZoneOverlay DEBUG** (Z0–Z4) : à retirer avant prod — Basse priorité

### Backlog — à cadrer en session dédiée
- **Lourdeur bille** : gravity=18.0 actuelle — augmenter dans le générateur Python et régénérer ? Ou ajuster replayStride ? À qualifier : chute trop lente ou rebonds trop élastiques ?
- **Jackpot unique** : fixer la règle dans `_assignSlots()` — slot central toujours = jackpot, hardcodé. Court à implémenter.
- **Skills manquants** : plinko-flutter-run (relance serveur Flutter) + plinko-regen-trajectories (script Python auto)
- **Build iOS** : nécessite Mac + Xcode + compte Apple Developer. Sans Mac → services CI cloud (Codemagic, Bitrise). Préparer guide étapes quand Matthieu sera équipé.
- **Intro du jeu** : one-shot ou à chaque partie ? Durée max 3s, skippable. Logo marque ou animation bille de démo ?

### Tech (Post-MVP)
- Comment la récompense est transmise à la marque après la partie ? (webhook, API ?)
- Format exact du token signé (JWT ? HMAC ? durée de validité ?)
- Combien de marques simultanées ? Architecture multi-tenant ?
- Le plateau est-il configurable par marque ou toujours identique ?
- Distribution : App Store distinct par marque ou app générique ?

---

## État d'avancement

| Domaine | Statut | Notes |
|---|---|---|
| **Game Design** | 🟡 2 questions ouvertes | Trajectoire prévisionnelle + vitesse bille à valider |
| **Tech & Architecture** | 🟢 Spec MVP v2 validée | Architecture trajectoires implémentée et validée |
| **Design & UI** | 🟡 Backlog | Assets Gemini inutilisables (opaques, faux alpha). Rendu code restauré. Passe design complète prévue en fin de projet. |
| **Dev** | 🟢 Stable | Bug damier résolu (plateau.png opaque retiré + backgroundBuilder). Rendu code fonctionnel. |
| **Test mobile** | 🟢 Opérationnel | Build web + serve local sur port 8080, testé sur iPhone via Safari. |
| **Flutter** | 🟢 Installé | v3.41.6 stable, PATH configuré sur Windows — Git CMD opérationnel |
| **Migration Claude Code** | 🟢 Done | CLAUDE.md + Git + decisions-log.md + DESIGN.md + brainstorm.skill créés. Workflow opérationnel. |

---

## Fichiers du projet

| Fichier | Description |
|---|---|
| `CLAUDE.md` | **Référence Claude Code** — contexte natif, commandes, règles |
| `decisions-log.md` | Historique complet de toutes les décisions |
| `method.md` | Méthode de collaboration Cowork |
| `project-context.md` | Ce fichier — source de vérité |
| `screenshots/` | Captures QA datées des états validés |
| `specs/tech-architecture.md` | Spec technique MVP v1.0 |
| `specs/game-design.md` | Game Design v1.0 |
| `Informations générales/architecture.md` | Structure des dossiers du projet |
| `Informations générales/environnement.md` | Environnement de dev Windows |
| `plinko_app/` | Code source Flutter |
| `plinko_app/lib/config/plinko_config.dart` | **Config centrale — toutes les valeurs de plateau** |
| `plinko_app/lib/game/ball.dart` | Bille — physique + replay |
| `plinko_app/lib/game/board.dart` | Plateau visuel + overlay zones DEBUG |
| `plinko_app/lib/game/plinko_game.dart` | Jeu principal — collisions, loader, caméra |
| `plinko_app/lib/data/trajectory_loader.dart` | Lecture JSON + sélection trajectoire |
| `plinko_app/lib/models/trajectory.dart` | Modèle de données trajectoire |
| `plinko_app/scripts/generate_trajectories.dart` | Script offline — génération trajectoires |
| `plinko_app/assets/trajectories.json` | 70 trajectoires pré-calculées (~1MB) |
| `sessions/2026-03-26_init.md` | Log session d'initialisation |
| `sessions/2026-03-26_game-design.md` | Log session Game Design |
| `sessions/2026-03-26_dev-session-1.md` | Log Dev Session 1 — socle physique |
| `sessions/2026-03-26_dev-session-1b.md` | Log Dev Session 1b — Flutter, forge2d, Notion |
| `sessions/2026-03-27_dev-session-2.md` | Log Dev Session 2 — tuning plateau |
| `plinko_app/lib/ui/config_panel.dart` | ConfigPanel — sliders live, validation physique, bouton Appliquer, sauvegarde configs nommées |
| `plinko_app/lib/ui/reward_overlay.dart` | Overlay récompense v3 — flash blanc, confettis, pulse ×3 jackpot, shake, mode perte |
| `sessions/2026-03-27_dev-session-3.md` | Log Dev Session 3 — bugfix physique, replay, trajectoires |
| `sessions/2026-03-27_dev-session-3b.md` | Log Dev Session 3b — ConfigPanel, bug const→final, bug bocal identifié |
| `sessions/2026-03-28_dev-session-4.md` | Log Dev Session 4 — fix orbite+bocal, trajectories.json, overlay récompense, sauvegarde configs |
| `sessions/2026-03-28_dev-session-5.md` | Log Dev Session 5 — système de table de lots (prize_lot, draw probabiliste, ConfigPanel) |
| `sessions/2026-03-28_dev-session-6.md` | Log Dev Session 6 — fix orbite v4, serveur Flutter crashé |
| `sessions/2026-03-28_dev-session-7.md` | Log Dev Session 7 — fix TrajectoryLoader, replayStride live, asymétrie picots, bugs loggués |
| `sessions/2026-03-28_dev-session-8.md` | Log Dev Session 8 — fix bille traverse picots, taille visuelle, anti-orbite v5, replayStride=4 |
| `generate_trajectories.py` | Script Python génération trajectoires (stride=1 — référence sandbox, Dart non dispo) |
| `scripts/serve_web.sh` | Script build web + serveur local pour test mobile |

---

*Dernière mise à jour : 2026-04-01 — Session Fix Design + Web Mobile. Bug damier résolu (plateau.png Gemini 100% opaque retiré, backgroundBuilder ajouté). Picots restaurés en rendu code (dégradé cyan→violet). Build web release + serve local (port 8080) pour test iPhone — validé. Passe design complète reportée en fin de projet.*
