# DECISIONS LOG — Plinko (Balleck Team)

> Historique complet et immuable de toutes les décisions prises.
> Les décisions ne sont jamais effacées — seulement ajoutées.
> Pour les décisions actives qui guident la suite, voir `project-context.md`.

---

## 📦 Index — repères rapides

> Les entrées détaillées ci-dessous restent intactes. Ce bloc sert d'index de navigation.

| Période | Builds | Résumé |
|---|---|---|
| 2026-03-19 → 2026-03-26 | setup | Cadrage équipe, stack (Flutter + Flame, pas Forge2D), MVP scope, ambiance futuriste, illusion de hasard pré-déterminée |
| 2026-03-27 → 2026-03-28 | 1-10 | Stabilisation physique (formule rebond, séparateurs solides, sub-stepping naissant), génération trajectoires Python, overlay récompense, ConfigPanel, **Système PrizeLot** (obsolète depuis Build 40) |
| 2026-03-29 → 2026-03-31 | 11-12 | Toggle mode physique forcé, jackpot unique centré (PrizeLot), filtre anti-stagnation trajectoires, migration Claude Code, CLAUDE.md + decisions-log créés |
| 2026-04-03 → 2026-04-04 | 13-27 | VFX Phase 1 (trail, squash&stretch, glow picots, particules), 7 cases, parois latérales toggle, resync source ← gh-pages (builds sans commit) |
| 2026-04-09 → 2026-04-12 | 28-39 | **Refonte physique complète** (sub-stepping ×4, ratio 1:1, gravité domine), CI GitHub Action auto gh-pages, grille triangulaire, proportions Stake 16 rangées |
| 2026-04-12 → 2026-04-17 | 40-41 | **Mode multiplicateur casino** (fin PrizeLot), 17 cases x100→x0.1, balance 50€, multi-ball, animation "+X€". Cleanup archi repo (−65 Mo, −4115 lignes). Convention commit formalisée. |

**Systèmes obsolètes** (conservés dans l'historique pour contexte) :
- `PrizeLot` / `LandedResult` / tirage probabiliste — remplacé par multiplicateurs positionnels fixes (Build 40)
- Parois latérales solides — retirées Build 35 (sortie = perdu)
- Overlay récompense plein écran — remplacé par popup "+X€" (Build 41)
- `_visualScale`, cooldown picots, minExitSpeed, anti-orbite — neutralisés par sub-stepping ×4 (Build 33)

---

## Journal complet

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
| 2026-04-12 | Dev | **Build 37** — refonte 8 rangées / 9 cases + bille dominante + LaunchHole (trou sombre en haut d'où émerge la bille). |
| 2026-04-12 | Dev | **Build 38** — pegGY 1.90 → 1.40 : plateau plus compact en hauteur. |
| 2026-04-12 | Dev | **Build 39** — proportions Stake : 16 rangées / 17 cases, picots petits (pegRadius 0.12) / bille ~1.33× (ballRadius 0.16), grille quasi-équilatérale (pegGX 0.80 × pegGY 0.70). Refonte layout complète. |
| 2026-04-12 | Game Design | **Build 40 — mode multiplicateur casino** : suppression table de lots probabiliste. 17 cases à multiplicateurs positionnels fixes et symétriques (x100 extrémités → x0.1 centre). Balance 50€ initiale, tap = -1€ = 1 bille, gain = 1€ × mult[case], multi-ball autorisé (despawn 0.8s après landing). Plus d'overlay récompense plein écran. |
| 2026-04-12 | Design | **Build 41 — animation "+X€"** : popup flottant center screen (scale bump + fade 900ms) à chaque atterrissage. Or pour gain ≥ 1€, bleuté discret pour <1€. Remplace l'overlay plein écran. |
| 2026-04-17 | Process | **Cleanup archi repo** (session dédiée) : -4115 lignes, -65 Mo. 4 phases commitées. Suppression `plinko_app/{linux,macos,windows}/` (platforms inutiles), `Inspirations/` (56 Mo), `assets/` racine (8.9 Mo), `method.md`, `DESIGN.md`, `Informations générales/`, `specs/`, `brainstorm.skill`, `scripts/render_docs.py`. Refonte complète `project-context.md` pour Build 41 et personnalisation `plinko_app/README.md`. |
| 2026-04-17 | Process | **Règle cohérence docs** : en fin de session, vérifier que `project-context.md` n'a ni doublons ni contradictions avec `CLAUDE.md`. Arbitrage : `CLAUDE.md` = quick ref, `project-context.md` = source de vérité. Ajoutée aux règles de session + checklist fin de session dans CLAUDE.md. |
| 2026-04-17 | Process | **Convention de commit formalisée** : titre préfixé (`Build N —`, `Fix —`, `Cleanup Phase N —`, `Session N —`, `Refacto —`, `Docs —`) + corps en bullets (quoi + pourquoi) + trailer `Co-Authored-By Claude`. HEREDOC obligatoire. Règles dures : pas de `git add -A/.`, pas d'`--amend`/`--no-verify` sans demande, 1 commit = 1 changement cohérent. Documentée dans CLAUDE.md. |
| 2026-04-17 | Process | **Notion sync Build 41** : refonte pages 🎮 Game Design (v2.0) + 🔧 Architecture Technique (v2.0) + MAJ ciblée 🎱 Benchmark. Board cleané manuellement par Matthieu. |
| 2026-04-17 | Process | **Hook SessionStart** (`.claude/settings.json`, commit d4f9511) : git pull + cat project-context.md + dernier log sessions/ à chaque démarrage de session. Garantit qu'aucune session ne démarre "froide" même sans phrase trigger du skill. |
| 2026-04-17 | Process | **Audit archi contexte** : identifié 3 mécanismes qui se chevauchent (hook SessionStart + CLAUDE.md natif + skill plinko-context-loader). Hook et skill doublonnent `git pull` + project-context + dernier log. decisions-log.md orphelin au boot (lu par skill uniquement). Vision dupliquée mot pour mot entre project-context §Vision et CLAUDE.md §Projet. |
| 2026-04-17 | Process | **Phase 1 refacto dedup** (commit 55a2c6a) : retire §Projet de CLAUDE.md (doublon vision), retire §Build actuel + §Process de project-context.md (doublons CLAUDE.md §Système multiplicateurs + §Règles de session). Règle : vision = project-context.md uniquement. −30 lignes. Phase 2 (refonte hook/skill) différée après 2 sessions de test. |
| 2026-04-17 | Design | **Build 42→45 — immersivité plateau mobile** (commit 1e9d54f) : plein écran (`AspectRatio` retiré), zoom dynamique fit-largeur, réduction grille 17→9 cases / 16→10 rangées, picots/bille +20%. Trajectoires obsolètes mais masquées par `forcePhysicsMode=true`. |
| 2026-04-17 | Design | **Build 46 — responsive mobile + desktop** (commit ecb207a) : breakpoint unique 1024px, board plafonné 500px, layout desktop 3 colonnes `[240 \| 500 \| 240]`, HUD relatif au conteneur plateau. Bench industrie Stake/BGaming confirmait le pattern. |
| 2026-04-18 | Design | **Build 47→54 — refonte Deep Arcade (Neon Noir)** (commits 039b463 + 5cef879) : direction tranchée après benchmark multi-agents (game-designer, designer, benchmark). Principe *"80 % sombre, 20 % lumineux"*. Fond noir `#08080F` + caustique diffuse (retrait étoiles + gradient violet + séparateurs). Picots blancs purs. Cases rectangles verticaux contour fin néon (palette magenta→violet→indigo→bleu gris→gris). Bille magenta `#FF2EB4`. Titre PLINKO en overlay Flutter `top: 150` (blanc + soulignement cyan). HUD cyan/noir translucide. Anti-pattern identifié : gros contours épais = *néon 2010*, vrai néon = trait fin + halo large. Session : `sessions/2026-04-18_design-deep-arcade.md`. |
| 2026-04-18 | Game Design | **Build 49 — multiplicateurs échelle réduite** : passage de `100·25·10·2·0.1·2·10·25·100` à `10·2·0.5·0.1·0.1·0.1·0.5·2·10`. Raison : x100 trop "promesse casino" pour un mini-jeu promo, zone x0.5 moins punitive que x0.1 unique. Seuil `slotIsMajor` baissé à ≥10 pour garder le glow "jackpot" sur les extrémités. |
| 2026-04-18 | Dev | **Build 54 — contrôles UI mise + nombre de billes** : tap-to-launch retiré (`onTapUp` no-op). Deux rangées de boutons en bas — mise (1/2/5/10€, radio-style cyan, défaut 1€) + lancer (1/2/5/10 billes, CTA magenta). Rafale espacée de 120 ms. Boutons lancer grisés tant que `ballsInFlightNotifier > 0`. `betAmountNotifier` + `ballsInFlightNotifier` exposés sur `PlinkoGame`. Gain = `bet × mult` (constante `kBallCost` supprimée). |
| 2026-04-18 | Tech | **Trajectoires obsolètes à régénérer** : les builds 47→54 n'ont touché qu'au rendu, mais les grilles Build 42→45 (9 cases / 12 rangs / picots/bille +20 %) restent non-répercutées dans `trajectories.json`. Masquées par `forcePhysicsMode=true`. À régénérer via `python generate_trajectories.py` (70/70) avant de basculer en replay pour production. |
| 2026-04-20 | Design | **Rebrand wordmark PLINKO → DROPL** (handoff Claude Design v2, `plinko design (2).zip`) : nouveau lockup 5 lettres, "lowered O" comme cue de chute (O abaissé +10 unités SVG sous baseline DR/PL), Space Grotesk 700, letter-spacing −2.4 (52px) / −1.85 (40px), blanc pur sans ornement. Trois `<text>` SVG distincts (DR / O / PL) pour permettre le décalage Y du O. Taille mini 28px (sous → DROPL plat). Décision périmètre : DROPL = nom de marque/produit affiché ; "Plinko" reste l'**identifiant tech interne** (repo `M4tthux/plinko`, dossier `plinko_app/`, classe `PlinkoGame`, clé prefs `plinko_has_seen_tour`, URL `m4tthux.github.io/plinko`). Pas de rename code/repo au MVP. Spec consolidée : §2bis de `design-ui-spec.md` + page Notion 🎨 Design UI. Assets : `design_handoff/.../README.md` + nouveau `DROPL Wordmark In-Context.html`. |
| 2026-04-20 | Design | **Refonte code wordmark différée** : Build 59 affiche encore "PLINKO" via `Text` standard dans `landing_screen.dart` + step 02 du tour cible `wordmarkKey` "PLINKO". Décalage tracé en §7 de `design-ui-spec.md`. Refonte = créer `<DroplWordmark size={40\|52}>` (3 `<text>` SVG via `flutter_svg` ou `CustomPainter`), MAJ landing + step 02, MAJ texte callout *"Comment fonctionne DROPL"*, MAJ cible spotlight. Session dev dédiée à planifier (un problème = une session). |
| 2026-04-20 | Dev | **Build 60 — implémentation wordmark DROPL** : composant `DroplWordmark(size)` créé (`plinko_app/lib/ui/widgets/dropl_wordmark.dart`) via `CustomPainter` + 3 `TextPainter` (DR / O / PL), mapping fidèle du viewBox SVG (220×72 à 52px), text-anchor=middle, baseline via `computeDistanceToActualBaseline`. Remplace `_Wordmark` dans `landing_screen.dart` (size 52) et `_PlinkoTitleOverlay` dans `main.dart` (size 40 responsive). Halo cyan + soulignement cyan supprimés (§2bis : "pas d'ornement"). In-game wrappé dans `Center` pour centrage horizontal, `_wordmarkKey` conservée sur widget tight (spotlight step 02 à la bonne taille). Callout step 02 : *"Comment fonctionne Plinko"* → *"Comment fonctionne DROPL"*. Pas de dépendance ajoutée. `§7` du spec à MAJ : décalage wordmark résolu. |
| 2026-04-20 | Process | **Skill `plinko-mobile-preview`** : nouveau skill pour tester le projet sur iPhone via WiFi LAN sans passer par `git push` + CI gh-pages. `flutter build web --release` + `python -m http.server 8082 --bind 0.0.0.0`, URL `http://<IP>:8082`. Complémentaire à `flutter run -d chrome`. Raison : mode dev Flutter web (~20 Mo debug) fait page blanche sur Safari iOS, release (~2 Mo tree-shaké) passe. Rebuild requis après chaque modif (pas de hot reload). |
| 2026-04-20 | Process | **Règle "skill créé → ajout Glossaire Notion"** : tout `SKILL.md` créé/modifié en session doit être enregistré dans la base Notion 📚 Glossaire des Skills (`28d8e8e639fe410fa59f6a435bf96c32`). Découverte après création de `plinko-mobile-preview` : le fichier local seul ne suffit pas, aucun hook ne synchronise. Étape 4bis ajoutée dans `plinko-session-close`, case dans check-list anti-skip, mémoire `feedback_skill_glossary_sync.md` pour portée inter-projets. |
| 2026-04-20 | Dev | **Build 61 — retrait back button + alignement HUD 12px** : bouton retour top-left supprimé (classe `_BackButton` retirée de `main.dart`). Balance recalée `left:12` (au lieu de 64 pour laisser la place au back). Burger menu et panneau config `ConfigPanel` recalés `right:12`. Raison : alignement vertical cohérent avec les rangées de boutons du bas (`left/right:12`). Retour landing considéré non nécessaire au MVP (navigation principale = dans le jeu). |
| 2026-04-20 | Dev | **Build 62 — multiplier wording x0.1 → x.1** : `slotMultiplierLabel(i)` refacto en helper pur `formatMultiplier(double m)` testable. Règle : `m < 1` → strip du "0" initial ("0.1"→".1", "0.5"→".5", "0.25"→".25", "0.05"→".05"). `m` entier ou ≥ 1 inchangé. Raison : économie de caractère sur cases étroites, le "." signifie seul "fraction". Test unitaire `test/slot_multiplier_label_test.dart` — 8 cas. |
| 2026-04-21 | Design | **Build 63 — passe typo globale** : Space Grotesk (UI) + JetBrains Mono (build stamp) appliqués sur les 6 zones manquantes — balance, build stamp, boutons bet (1/2/5/10€), boutons lancer billes, popup gain "+X€", labels multiplicateurs cases (board.dart). Labels cases : weight w800 → w700 pour matcher spec §3 ("11 / 700 Space Grotesk"). Décalage §7 "Typo globale" résolu. Aucune valeur (size/color/letterSpacing/shadow) changée — swap police uniquement. Side panel placeholder desktop laissé en police système (hors critères, placeholder temporaire). |
| 2026-04-21 | Dev | **Build 64 — bouton (?) réafficher onboarding + alignement HUD top 40px** : nouveau widget `_HelpButton` (40×40, mêmes tokens que burger ⚙ — cyan outline, bg `0xFF0A0A14@75`, radius 10, shadow cyan blur 10, icône `Icons.help_outline`), positionné `top:16 right:62` (à gauche du burger). Tap → `setState(_tourActive = true)` : relance le tour au step 1/4 (wordmark DROPL). `hasSeenTour` inchangé (le bouton ne reset pas le flag). Balance passe de padding libre à `height:40` fixe avec `alignment: Alignment.center` → HUD top parfaitement aligné (balance + ? + ⚙ même ligne, même hauteur). Raison : permettre au joueur de revoir le tutoriel à tout moment sans passer par le landing. Source de vérité tailles = burger actuel. |
| 2026-04-21 | Process | **Tâche Notion Session 3 — Cleanup PlinkoTitle dead code** : classe `PlinkoTitle` (`board.dart` L300-393) + factory `buildTitle()` plus instanciées depuis Build 60 (remplacées par `DroplWordmark` + `_PlinkoTitleOverlay`). Créée Basse/Backlog pour visibilité — cleanup à faire dans une session dédiée. |
| 2026-04-20 | Process | **Refactor docs — board Notion = seule source de vérité des tâches actionnables** : constat que Matthieu ne lit jamais `project-context.md` (il bosse depuis la board mobile), donc §Questions ouvertes > Design/Dev et §État d'avancement dérivaient à chaque session. `project-context.md` = vision + décisions + questions produit non-tranchées uniquement. `plinko-session-close` : board remontée en Étape 2 (avant toute update doc), warning "INTERDIT tâche dans project-context.md", ancienne Étape 8 supprimée, renumérotation 3→9. `plinko-context-loader` : briefing ouvre par "🎯 Tâches actives (board Notion — source de vérité)". 7 items migrés de la §Design/Dev vers la board comme cartes Backlog (VFX Phase 2, régénérer trajectoires 12/9, passe typo, design hi-fi 12/9, demo ball step 3, layout callout) + 1 carte Done pour le refactor lui-même. DROPL wordmark Build 60 passé en Done. |
