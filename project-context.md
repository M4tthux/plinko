# PROJECT CONTEXT — Plinko (Balleck Team)

> Source de vérité **produit** (vision, décisions, état). Quick ref technique : [`CLAUDE.md`](CLAUDE.md). Historique immuable : [`decisions-log.md`](decisions-log.md).

---

## Vision

Mini-jeu mobile promotionnel type Plinko (Flutter web + iOS/Android).
Le joueur tape pour lancer une bille qui rebondit sur des picots et atterrit dans une case à multiplicateur.
Résultat pré-déterminé (trajectoire pré-calculée et rejouée), illusion de hasard totale.
Destiné à être intégré comme expérience d'engagement pour des marques clientes.

---

## Contraintes

| Domaine | MVP | Post-MVP |
|---|---|---|
| **Framework** | Flutter — test Chrome, prod iOS+Android | — |
| **Moteur** | Flame + physique manuelle (Forge2D incompatible Web) | — |
| **Trajectoires** | `generate_trajectories.py` (miroir Python de la physique Dart) | — |
| **Scope** | Web mobile via GitHub Pages | Build natif iOS/Android |
| **Config** | Hard-codée `plinko_config.dart` | Backend + multi-tenant marque |
| **Intégration** | — | Deeplink, token signé, SDK marque, thème |

---

## Décisions actives (le *pourquoi*)

> Les *quoi* sont dans CLAUDE.md. Cette section garde les raisons que le code ne montre pas.

### Process / Docs
- **Hiérarchie docs** (Phase 1 refacto 2026-04-17) — project-context.md = source de vérité (vision + décisions + statut), CLAUDE.md = quick ref technique pure, decisions-log.md = historique immuable. Vision uniquement dans project-context.md, §Projet retiré de CLAUDE.md pour supprimer le doublon.
- **Phase 2 différée** — refonte hook + skill plinko-context-loader (aujourd'hui ils doublonnent : hook lit project-context + dernier log, skill relit tout + Notion). À faire après 2 sessions de test Phase 1.
- **Spec UI Design consolidée** (2026-04-19) — ajout page Notion 🎨 Design UI (`https://www.notion.so/Design-UI-347d826db45980498628dfd5b720a15c`) + miroir versionné `design-ui-spec.md` à la racine. Consolide DA Deep Arcade + handoff onboarding Claude Design en un seul doc. Règle : **intention + tokens évolutifs** sur Notion, **valeurs exactes** dans `plinko_config.dart`, **assets binaires** dans `design_handoff/`. Décalages spec vs code tracés en §7 du doc. Prochaine étape : consolider les multiples versions de design historiques (assets Gemini → refonte → Deep Arcade → handoff onboarding) et archiver les périmées.
- **Rebrand wordmark PLINKO → DROPL** (2026-04-20, handoff Claude Design v2) — nouveau wordmark 5 lettres avec "O abaissé" comme cue de chute (Space Grotesk 700, 3 `<text>` SVG distincts DR/O/PL, baseline offset +10 unités, ls −2.4 à 52px / −1.85 à 40px, blanc pur sans ornement). **Décision périmètre** : DROPL = nom de marque/produit affiché. *"Plinko"* reste l'**identifiant tech interne** (repo `M4tthux/plinko`, dossier `plinko_app/`, classe `PlinkoGame`, clé prefs `plinko_has_seen_tour`, URL `m4tthux.github.io/plinko`) — **pas de rename code/repo au MVP**. À reconsidérer Post-MVP si la marque DROPL se consolide. Spec : §2bis de `design-ui-spec.md`. Assets : `design_handoff/.../DROPL Wordmark In-Context.html` + README v2.
- **Implémentation DROPL wordmark** (Build 60, 2026-04-20) — composant Flutter `DroplWordmark(size)` créé (`plinko_app/lib/ui/widgets/dropl_wordmark.dart`) via `CustomPainter` + 3 `TextPainter` (DR / O / PL) mappant fidèlement le viewBox SVG de référence (220×72 à 52px). Centrage optique `text-anchor=middle` implémenté par calcul `centerX - width/2`, baseline via `computeDistanceToActualBaseline`. Remplace `_Wordmark` dans `landing_screen.dart` (size 52, splash) et `_PlinkoTitleOverlay` dans `main.dart` (size 40 responsive, header in-screen) — halo cyan + soulignement supprimés conformément à §2bis. In-game wordmark wrappé dans `Center` pour centrage horizontal tout en conservant la `GlobalKey _wordmarkKey` sur le widget tight (préserve la taille du spotlight step 02). Callout step 02 du tour : *"Comment fonctionne Plinko"* → *"Comment fonctionne DROPL"*. Pas de dépendance ajoutée (pas de `flutter_svg`). `§7` du spec : décalage wordmark résolu, à mettre à jour.
- **Skill `plinko-mobile-preview`** (2026-04-20) — nouveau skill pour tester le build Flutter sur iPhone via WiFi LAN sans passer par `git push` + CI gh-pages. `flutter build web --release` (bundle léger ~2 Mo, vs ~20 Mo en debug que Safari iOS refuse) + `python -m http.server 8082 --bind 0.0.0.0`, URL LAN `http://<IP>:8082` à ouvrir sur le mobile. Pare-feu Windows → ouvrir port 8082 en admin. Complémentaire à `flutter run -d chrome` (port 8081, PC seulement). Rebuild requis après chaque modif code (pas de hot reload).
- **Règle "skill créé → ajout Glossaire Notion"** (2026-04-20) — tout `SKILL.md` créé/modifié en session doit être enregistré dans la base Notion 📚 Glossaire des Skills (`28d8e8e639fe410fa59f6a435bf96c32`). Le fichier local seul ne suffit pas — Matthieu s'en est rendu compte quand `plinko-mobile-preview` n'apparaissait pas dans le glossaire post-création. Étape 5bis dans `plinko-session-close` pour rattraper tout oubli.
- **Board Notion = SEULE source de vérité des tâches actionnables** (2026-04-20, refactor docs) — constat : Matthieu ne lit jamais `project-context.md`, il bosse uniquement depuis la board. §Questions ouvertes > Design/Dev et §État d'avancement dérivaient systématiquement de la board. Décision : retirer toute tâche de `project-context.md` (§Design/Dev supprimée, §État d'avancement remplacée par un pointeur vers la board). `project-context.md` = vision + décisions + questions **produit non-tranchées** uniquement. `plinko-session-close` remonte la board en Étape 2 (avant toute update de doc) avec interdiction explicite d'écrire une tâche dans `project-context.md`. `plinko-context-loader` ouvre le briefing par les tâches actives de la board (source primaire des priorités), décisions/vision après. 7 items migrés de la §Design/Dev vers la board (VFX Phase 2, régénérer trajectoires, passe typo, design hi-fi 12/9, demo ball step 3, layout callout, refactor docs marqué Done). DROPL wordmark (déjà livré Build 60) passé en Done.

### Tech
- **Flame + physique manuelle** — Forge2D supprimé car incompatible Flutter Web
- **Sub-stepping ×4** — anti-tunneling validé via benchmark Stake / BGaming / Matter.js
- **Config hard-codée `plinko_config.dart`** — pas de backend au MVP, personnalisation marque = Post-MVP
- **CI push master → gh-pages auto** — plus besoin du PC pour déployer
- **Grille triangulaire** — `worldWidth` dérivé de `(rows-1) × pegGX + 2 × pegRadius` pour alignement pixel-perfect cases/picots

### Game Design
- **Illusion de hasard totale** — résultat pré-déterminé, trajectoire rejouée frame par frame
- **Mode multiplicateur casino (Build 40)** — abandon du système PrizeLot probabiliste, remplacé par multiplicateurs positionnels fixes (lisibilité + standard industrie)
- **1 tap = 1 bille = −1€, multi-ball** — rythme de jeu soutenu, économie claire
- **Lancement centre + jitter, pas de parois** — distribution binomiale pure comme les vrais Plinko
- **Pas de sons / haptique au MVP** — repoussé Post-MVP pour ne pas figer le contrat son/marque
- **Ambiance arcade rétro néon** — direction "Deep Arcade" validée Build 47→54 (voir section dédiée plus bas)
- **9 cases découplées des picots (Build 45)** — picots restent en grille triangulaire 12 rangs, mais les 9 cases du bas répartissent uniformément la largeur (slotWidth ≠ pegGX). Décision = lisibilité mobile prime sur l'alignement strict cases/picots. Multiplicateurs initiaux `100·25·10·2·0.1·…` révisés en Build 49 (voir plus bas).

### Design / Immersivité mobile (Build 42→45)
- **Plein écran** — `AspectRatio(9/16)` retiré : le canvas occupe toute la fenêtre (récup ~150px sur iPhone 14)
- **Zoom dynamique fit-largeur** — `camera.zoom = screenWidth × 0.96 / worldWidth` recalculé sur chaque resize (vs zoom fixe 24 avant)
- **Réduction grille 17→9 cases, 16→10 rangées visibles** — cases 2× plus larges à l'écran. Trajectoires obsolètes mais `forcePhysicsMode = true` donc no-op (à régénérer si on relance le replay)
- **Picots/bille +20%** — `pegRadius 0.12→0.14`, `ballRadius 0.16→0.19` (ratio bille/picot maintenu ~1.36)

### Direction artistique Deep Arcade (Build 47→54)
- **Direction "Deep Arcade / Neon Noir"** tranchée après benchmark multi-agents (benchmark mémoire / game-designer / designer). Principe central game-designer : *"80 % de l'écran sombre et mat pour que les 20 % lumineux aient du poids. Si on retire la bille et les picots, le fond doit être presque ennuyeux."* Le build précédent (violet plat + gros contours) faisait *néon 2010*, pas *arcade rétro* — l'excès de néon aplatissait la hiérarchie x100 / x0.1.
- **Anti-pattern principal identifié** : gros contours épais uniformes. Vrai néon = trait fin + halo large, pas trait épais coloré. Pièces flottantes jackpot + reflet verre + trapèze cases supprimés (visual noise qui concurrence la bille).
- **Fond noir #08080F + caustique radiale diffuse** — pas de gradient violet, pas d'étoiles, pas de grille perspective. Neutre pour ne pas contaminer la hiérarchie des cases.
- **Picots blancs purs** (fin du doré 3D) — neutralité maximale, halo discret au repos, amplifié au hit.
- **Bille magenta `#FF2EB4`** (fin du doré) — corps + trail + particules d'impact cohérents. Choix bille rose car c'est l'élément qui doit "briller" sans rivaliser avec les cases jackpot.
- **Cases rectangles verticaux contour fin néon** — palette magenta→violet→indigo→bleu gris→gris. Hiérarchie par la chaleur (pas la taille). x0.1 gris neutre, jamais rouge ni "punitif".
- **Titre PLINKO en overlay Flutter** (`Positioned top: 150`) — retiré du rendu Flame pour placement pixel-exact indépendant du zoom caméra. Blanc pur + soulignement cyan `#00D9FF` fin.

### Nouveau système multiplicateurs (Build 49)
- **Échelle réduite** — ancienne `100·25·10·2·0.1·2·10·25·100` → nouvelle `10·2·0.5·0.1·0.1·0.1·0.5·2·10`. Décision Matthieu : x100 trop "promesse casino" pour un mini-jeu promo, x0.1 en 3 cases centrales plus réaliste. Gains plus lissés, moins de frustration (x0.5 récupère la moitié de la mise vs perdre 90 % sur x0.1).
- **`slotIsMajor` seuil baissé à ≥ 10** — sinon plus aucune case n'aurait le glow "jackpot" après réduction d'échelle.

### Landing + Onboarding tour (Build 56→59, 2026-04-19)
- **Écran d'accueil créé** (`ui/landing_screen.dart`) — wordmark PLINKO glow cyan, headline "Tombe. Rebondit. Gagne.", sous-titre, CTA "Jouer" dégradé cyan 52h, ghost link "Comment ça marche ?". Route `/` avant le jeu.
- **Tour d'onboarding 4 steps** (`ui/onboarding/coachmark.dart` + `tour_overlay.dart`) — spotlight bordure 2px cyan sèche (pas de halo), dim 62% noir via **4 rectangles positionnés autour du trou** (pas `Path.combine` ni `BlendMode.clear` qui rendent de façon incohérente sur le renderer HTML de Flutter Web). Callout glass bas-dockée avec step pill "n / 4", title, body, CTA "Suivant / Terminer", bouton "Passer" top-right (caché step final). Steps : wordmark → plateau → rangée mise → rangée billes.
- **Zone cible "plateau" = overlay invisible resserré** (top 30% + bottom 25% du container) — le `GameWidget` entier était trop grand et ne laissait plus de place pour la callout. Cible seulement la pyramide + rangée multiplicateurs.
- **TourOverlay au niveau Scaffold** — plein viewport en desktop comme en mobile, pas contraint à la colonne 500px. `GlobalKey` globales, `_rectFor` utilise `localToGlobal` → positions correctes même en desktop 3-colonnes.
- **Callout clampée** (calloutEstH=150, safeEdge=20) — dock auto au-dessus ou en-dessous selon espace dispo, jamais hors-champ.
- **Déclenchement uniquement depuis le landing** via "Comment ça marche ?" — pas d'auto-launch au 1er open. `hasSeenTour` persisté en `SharedPreferences` (flag pour usage futur, non-gating pour l'instant).
- **Bouton retour top-left** (dans le jeu) → `Navigator.maybePop()` pour revenir au landing. Balance décalée à left:64 pour laisser la place.
- **Typo** — Space Grotesk (UI) + JetBrains Mono (labels) via `google_fonts`, **appliqués uniquement sur le landing et le coachmark** pour cette session. Passe typo globale reportée session suivante.
- **Choix `BoxShadow` minimaux** — halos cyan multiples (ring blur 32, callout blur 20, progress bar blur 8) combinés teintaient l'écran entier en cyan. Réduction à : 0 halo sur ring, 0 glow sur progress bar, bouton Suivant blur 6 seul. L'accent cyan est réservé au contour, pas au volume.

### Contrôles mise + nombre de billes (Build 54)
- **Tap-to-launch retiré** — remplacé par deux rangées de boutons en bas. Raison : ergonomie clavier/souris desktop + intention explicite vs tap répété.
- **Rangée mise (1/2/5/10€)** — radio-style cyan, défaut 1€. `betAmountNotifier` dans `PlinkoGame`. Gain = `bet × mult` (plus de constante `kBallCost`).
- **Rangée lancer (1/2/5/10 billes)** — CTA magenta, lancers multiples espacés de 120 ms. Boutons grisés tant que `ballsInFlightNotifier > 0` (double-protection dans `launchBalls` aussi). Décision : forcer l'attente de fin de rafale évite qu'on empile 40 billes d'un coup et qu'on ne voie plus rien.

### Responsive mobile + desktop (Build 46)
- **Breakpoint unique 1024px** — viewport < 1024 = mode mobile, ≥ 1024 = mode desktop. Une seule règle, pas de zone grise tablette.
- **Board plafonné à 500px** — même plateau sur tous les devices, jamais de stretching. Sur mobile : `width = (viewport × 0.92).clamp(0, 500)` centré. Décision : le format portrait du plateau prime, sur iPad/desktop on ajoute du décor autour plutôt que de déformer.
- **Mode desktop = 3 colonnes** — layout `[panel 240 | gap 20 | board 500 | gap 20 | panel 240]` = 1020px centré. Les panneaux latéraux sont des placeholders dashed border + label "panel left/right" en attendant le contenu réel (stats, historique, branding marque).
- **HUD relatif au conteneur du plateau, pas au viewport** — balance, build badge, instructions, popups, config panel positionnés dans le Stack 500px → se recentrent automatiquement avec le plateau en mode desktop. Évite que le HUD parte se coller aux bords d'un écran 1440px.
- **Constantes centralisées** — `kDesktopBreakpoint`, `kBoardMaxWidth`, `kSidePanelWidth`, `kDesktopGap` en tête de `main.dart` pour ajustement rapide.
- **Impact zéro sur physique et trajectoires** — `worldWidth`/`worldHeight` inchangés, `_applyResponsiveCamera(size)` reçoit simplement la size contrainte et zoom en conséquence.
- **Bench industrie (Stake / BGaming / crash games)** — pattern systématique : plateau portrait à largeur fixe, décor/UI autour sur desktop, jamais de canvas qui s'étire.

---

## Questions ouvertes (produit uniquement)

> ⚠️ Questions produit non-tranchées uniquement. Les tâches actionnables vivent sur la board Notion → https://www.notion.so/6c1e7a3c58094cadac6313c3a57bbda7. Ne jamais ajouter de tâche ici.

### Game Design
- Écran d'intro : animation bille ou simple logo marque ? (basse priorité)
- Équilibrage multiplicateurs x100 : probabilité réelle vs ressenti joueur à monitorer

### Tech Post-MVP
- Transmission récompense → marque : webhook ou API pull ?
- Token signé : JWT ou HMAC ? durée validité ?
- Multi-tenant : plateau configurable par marque ou identique ?
- Distribution : App Store par marque ou app générique ?
- Build natif iOS/Android : Mac + Xcode requis (ou CI cloud Codemagic / Bitrise)

---

## État d'avancement

👉 Source de vérité : board Notion → https://www.notion.so/6c1e7a3c58094cadac6313c3a57bbda7
Plus de tableau de statuts dans ce fichier (évite la dérive). Build + config plateau : CLAUDE.md.

---

*Dernière mise à jour : 2026-04-20 — Refactor docs : la board Notion devient la SEULE source de vérité pour les tâches actionnables. §Questions ouvertes ramenée aux questions produit non-tranchées (sous-section Design/Dev supprimée, items migrés sur la board). §État d'avancement remplacée par un pointeur vers la board (plus de tableau de statuts). Skills `plinko-session-close` et `plinko-context-loader` mis à jour en conséquence.*

*Session 2026-04-20 (Build 60) — Implémentation wordmark DROPL (composant Flutter `DroplWordmark` via CustomPainter + 3 TextPainter, remplace le wordmark landing + in-game, callout step 02 MAJ). Nouveau skill `plinko-mobile-preview` pour tester sur iPhone via WiFi LAN sans push gh-pages. Règle "skill créé → ajout Glossaire Notion" formalisée (Étape 4bis du session-close + mémoire feedback).*

*Session 2026-04-20 (Builds 61-62) — HUD top : retrait bouton retour top-left, balance recalée `left:12`, burger menu + panneau config recalés `right:12` (alignés sur rangées boutons bas). Multiplier wording : `formatMultiplier` extrait en helper pur, valeurs < 1 perdent le "0" initial ("0.1"→".1", "0.5"→".5"). Test unitaire 8 cas ajouté (`test/slot_multiplier_label_test.dart`).*
