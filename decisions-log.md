# DECISIONS LOG — Plinko (Balleck Team)

> Historique complet et immuable de toutes les décisions prises.
> Les décisions ne sont jamais effacées — seulement ajoutées.
> Pour les décisions actives qui guident la suite, voir `project-context.md`.

---

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
| 2026-03-27 | Game Design | Bug "bocal" identifié : bille rebondit dans zone des cases comme dans une boîte — fixé Session 4 |
| 2026-03-27 | Feature | Sauvegarde configs nommées demandée : bouton Save + nom dans ConfigPanel, persistance locale |
| 2026-03-28 | Dev | Bug orbite picot diagnostiqué (mode physique fallback) : 3 causes — gap séparation trop petit (0.001), kick aléatoire tangentiel, absence de sub-stepping. |
| 2026-03-28 | Dev | **FIX bug orbite picot** : gap séparation 0.001→0.08 + minExitSpeed=2.5 forcée après rebond picot — `plinko_game.dart` + `generate_trajectories.dart` |
| 2026-03-28 | Dev | **FIX bug bocal** : slotDividerRestitution=0.15 (au lieu de wallRestitution=0.55) dans `_resolveSlotDividerCollisions()` — miroir dans `generate_trajectories.dart` |
| 2026-03-28 | Dev | `generate_trajectories.dart` sync config plateau : pegSpacingX=3.0, pegSpacingY=1.5, pegRowCount=14, pegColsOdd=6, pegColsEven=5, ballRadius=0.60 |
| 2026-03-28 | Dev | `trajectories.json` régénéré : 70/70 trajectoires, 0 manquantes (~1002 Ko) — simulation Python (Dart indisponible en sandbox) |
| 2026-03-28 | Dev | **Overlay récompense** implémenté : `ui/reward_overlay.dart` — fade-in + scale, cyan/or (jackpot), tap pour fermer. Connecté via `ValueNotifier<int?>` dans `PlinkoGame` + `ValueListenableBuilder` dans `main.dart` |
| 2026-03-28 | Dev | **Sauvegarde configs nommées** : classe `_ConfigStorage` (in-memory) + champ nom + bouton 💾 + liste rechargeable/supprimable dans `ConfigPanel` |
| 2026-03-28 | Dev | **Système de table de lots (Dev Session 5)** : `models/prize_lot.dart` (PrizeLot + LandedResult), `plinko_config.dart` (lots + currentSlotAssignment + jackpotSlotIndex), `plinko_game.dart` (_drawLot + _assignSlots + _assignSlotsDecor), `board.dart` (SlotLabel lit depuis currentSlotAssignment), `reward_overlay.dart` (prizeName + isJackpot), `config_panel.dart` (section "Table de lots" scrollable). |
| 2026-03-28 | Dev | **FIX bug orbite picot v4 (Dev Session 6)** : `plinko_game.dart` — composante Y tangentielle VERS LE BAS préservée, cooldown 5→8 frames, kick anti-orbite minDownwardVelocity=1.0. `ball.dart` — détecteur de blocage : si velocity.y < 1.5 pendant 90 frames → impulsion forcée (8.0) + amortissement X (0.2). |
| 2026-03-28 | Tech | Serveur Flutter (:60555) crashé en fin de Dev Session 6 — nécessite relance manuelle (`flutter run -d chrome`). |
| 2026-03-28 | Dev | **Dev Session 7** — Serveur relancé sur :50063. App chargée et testée. |
| 2026-03-28 | Dev | **FIX bug replayStride live** : slider ConfigPanel n'appliquait la valeur qu'au clic "Appliquer". Fix : `PlinkoConfig.replayStride = v` appliqué immédiatement dans le callback du slider. Validé. |
| 2026-03-28 | Dev | **FIX bug TrajectoryLoader vidé** : `rebuildBoard()` appelait `TrajectoryLoader.clear()` sans recharger les trajectoires → toutes les billes en mode physique fallback après chaque "Appliquer". Fix : suppression de `TrajectoryLoader.clear()`. |
| 2026-03-28 | Dev | **replayStride par défaut** changé de 2 à 3 — vitesse initiale légèrement ralentie. |
| 2026-03-28 | Dev | **FIX bug asymétrie picots** : `pegEffectiveSpacingX = worldWidth / pegColsOdd` + `pegOffsetOdd = effectiveX/2`. Grille toujours symétrique. |
| 2026-03-28 | Dev | **Minimum pegColsOdd = 4** (= slotCount/2+1) — garantit au moins un picot par case. |
| 2026-03-28 | QA | **Bug mismatch lot/case** logué : badge ≠ overlay — cause principale = TrajectoryLoader vidé (fixé). |
| 2026-03-28 | Dev | **Session 8 — FIX bug visuel bille traverse picots** : interpolation linéaire dans `_updateReplay()` + régénération trajectoires Python stride=1 (70/70, 1279 Ko). |
| 2026-03-28 | Dev | **Session 8 — FIX taille visuelle bille** : `_visualScale=0.75` dans `ball.dart` — revenu à 1.0 en Session 9 (gap visible entre bille et picots). |
| 2026-03-28 | Dev | **Session 8 — Anti-orbite renforcé** : `_stuckLimit` 90→30, `_stuckVyMin` 1.5→2.0, `_stuckNudgeY` 8→12, `_stuckDampX` 0.2→0.1. |
| 2026-03-28 | Dev | **Session 8 — replayStride** 5→4. Script Python `generate_trajectories.py` créé. |
| 2026-03-29 | Dev | **Toggle mode physique forcé** : `PlinkoConfig.forcePhysicsMode` + switch dans ConfigPanel (section 🔧 Debug). |
| 2026-03-29 | Dev | **`_visualScale` 1.0** : taille visuelle bille = rayon physique (0.60). La réduction à 0.75 créait un gap visible. |
| 2026-03-29 | Dev | **Badge version** `kBuildTime` en haut de l'écran — centré, taille 14, incrémenté à chaque session (build 11 à clôture). |
| 2026-03-29 | Game Design | **Jackpot unique centré** : 1000€ en case centrale UNIQUEMENT — exclu des fillers dans `_assignSlots` et `_assignSlotsDecor`. |
| 2026-03-29 | Game Design | **Valeurs par défaut** : 1€(30%), 2€(25%), 5€(20%), 10€(13%), 20€(7%), 50€(3%), 1000€(2% jackpot). |
| 2026-03-29 | Dev | **Filtre anti-stagnation trajectoires** : `generate_trajectories.py` rejette toute trajectoire où Y ne progresse pas de 0.5 unités sur 120 frames (2s). 70/70 régénérées, 326 Ko. |
| 2026-03-29 | Game Design | **Visuel end game cadré** : prix centré, icône €, feux d'artifice, halo. Jackpot = version or spectaculaire. À implémenter. |
| 2026-03-31 | Process | **Migration Claude Code décidée** : dev dans Claude Code (terminal), pas dans Cowork. |
| 2026-03-31 | Process | **Environnement complet validé** : Claude Code 2.1.81 + Node 24 + npm 11 + Git + Flutter 3.41.6 + Python 3.14.3 — tout en PATH sur Windows. |
| 2026-03-31 | Process | **Workflow hybride validé** : Claude Code pour dev/fichiers/terminal — Chat pour design visuel, screenshots, game design. Bridge = fichiers projet. |
| 2026-03-31 | Process | **Git initialisé** : premier commit propre en début de session Claude Code. |
| 2026-03-31 | Process | **CLAUDE.md créé** : remplace le skill plinko-context-loader nativement dans Claude Code. |
| 2026-03-31 | Process | **decisions-log.md créé** : historique complet séparé de project-context.md. |
| 2026-03-31 | Process | **screenshots/** créé : captures QA datées des états validés. |
| 2026-03-31 | Process | **Skills manquants identifiés** : plinko-flutter-run (relance serveur) + plinko-regen-trajectories (script Python auto). |
| 2026-04-03 | Dev | **Trail lumineux bille** : 10 positions, fade opacity + glow or. `ball.dart`. |
| 2026-04-03 | Dev | **Squash & stretch bille** : 15% déformation, 120ms, direction d'impact. `ball.dart` + `plinko_game.dart`. |
| 2026-04-03 | Dev | **Glow flash picots** : 200ms blanc lumineux au passage. `board.dart` + `plinko_game.dart`. |
| 2026-04-03 | Dev | **Glow dynamique** : halos bille modulés par vitesse (speedFactor). `ball.dart`. |
| 2026-04-03 | Dev | **Particules d'impact** : 12 particules or à l'atterrissage (600ms). `ball.dart` + `plinko_game.dart`. |
| 2026-04-03 | Game Design | **Slow-motion annulé** : pas de ralentissement derniers rangs (décision Matthieu). |
| 2026-04-04 | Game Design | **7 cases** au lieu de 9 : 1€, 10€, 25€, 500€(jackpot), 25€, 10€, Perdu. (session PC non committée, resync build 25) |
| 2026-04-04 | Dev | **worldWidth 15** (était 18) : adapté pour mobile. (build 26) |
| 2026-04-04 | Dev | **Parois latérales remises** : murs physiques restaurés. (build 27) |
| 2026-04-04 | Dev | **startRow=0** : toutes les rangées de picots affichées. (build 31) |
| 2026-04-04 | Dev | **pegRadius 0.20** (était 0.25) : picots plus petits. (build 31) |
| 2026-04-04 | Dev | **ballRestitution 0.10** (était 0.25) : rebond très faible + friction + nudge aléatoire. (build 30) |
| 2026-04-08 | Process | **Resync source ← gh-pages** : 7 builds (25-31) déployés sans commit source. Code source resynchronisé. |
| 2026-04-09 | Process | **GitHub Action CI** créé : `.github/workflows/deploy-web.yml` — push master → build Flutter web → deploy gh-pages automatiquement. Plus besoin du PC pour déployer. URL : `m4tthux.github.io/plinko`. |
| 2026-04-09 | Dev | **Build 33 — refonte physique complète** : sub-stepping 4 sous-pas/frame (anti-tunneling), ratio bille:picot 1:1 (0.30/0.25), restitution 0.75, gravity 12, suppression cooldown picots, suppression vitesse Y forcée. Basé sur benchmark Matter.js / Stake / BGaming. |
| 2026-04-09 | Dev | **Build 34 — proportions standard** : worldWidth 15→12, startRow 0→2. Gap libre entre picots = 2× diamètre bille (standard). Commence à 3 picots. |
| 2026-04-09 | Dev | **Build 35 — bords retirés + rebonds amortis** : suppression murs latéraux (sortie = perdu, comme vrais Plinko), restitution 0.75→0.35. La gravité domine, distribution binomiale pure. |
| 2026-04-09 | Dev | **Build 36 — cases alignées sur picots du bas** : rows 10→8, pegGX découplé de slotCount et fixé à 1.70, worldWidth calculé dynamiquement = (rows-1)×pegGX + 2×pegRadius. Cases entre les picots de la dernière rangée. Perdu uniquement si bille hors périmètre des picots du bas. |
| 2026-04-09 | Game Design | **Distribution 100% statistique** : pas de forçage central, lancement depuis le centre avec micro-jitter, distribution binomiale pure (comme les vrais Plinko). |
| 2026-04-09 | Game Design | **Pas de parois latérales** : la bille sort = perdu. La grille triangulaire recentre naturellement via statistiques. |
| 2026-04-09 | Game Design | **Rebonds amortis (0.35)** : la bille dévie légèrement, la gravité domine. Pas de gros rebonds qui font monter la bille. |
| 2026-04-09 | Process | **Règle : incrémenter `kBuildTime`** à chaque modification qui affecte le runtime. Permet de vérifier facilement la version en ligne. |
