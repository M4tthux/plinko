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

## Questions ouvertes

### Game Design
- Écran d'intro : animation bille ou simple logo marque ? (basse priorité)
- Équilibrage multiplicateurs x100 : probabilité réelle vs ressenti joueur à monitorer

### Design / Dev
- **VFX Phase 2** — flash case, screen shake, scale pulse
- **LaunchZoneOverlay DEBUG** (Z0–Z4) — à retirer avant prod
- **Régénérer trajectoires** pour la nouvelle grille 12 rangs / 9 cases (aujourd'hui obsolètes, masquées par `forcePhysicsMode = true`)

### Tech Post-MVP
- Transmission récompense → marque : webhook ou API pull ?
- Token signé : JWT ou HMAC ? durée validité ?
- Multi-tenant : plateau configurable par marque ou identique ?
- Distribution : App Store par marque ou app générique ?
- Build natif iOS/Android : Mac + Xcode requis (ou CI cloud Codemagic / Bitrise)

---

## État d'avancement

| Domaine | Statut | Notes |
|---|---|---|
| Game Design | 🟢 Build 49 validé | 9 cases, multi `10·2·0.5·0.1×3·0.5·2·10` (échelle réduite) |
| Tech & Architecture | 🟢 Stabilisé | Sub-stepping, physique pure, grille triangulaire, cases découplées |
| Design & UI | 🟢 Build 54 | Direction Deep Arcade livrée (fond noir, picots blancs, cases fin néon, bille magenta). Contrôles mise/billes en bas. Trajectoires à régénérer. VFX Phase 2 à faire |
| Dev | 🟢 Build 54 | Contrôles mise + nombre de billes, tap-to-launch retiré, bet dynamique |
| CI/CD | 🟢 Done | Auto-deploy gh-pages |
| Test mobile (web) | 🟢 OK | Safari/Chrome iPhone via GitHub Pages |
| Flutter local | 🟢 OK | v3.41.6 Windows (Git CMD) |
| Build natif iOS/Android | 🔴 Bloqué | Mac + Xcode requis |

---

*Dernière mise à jour : 2026-04-18 — Build 54 : direction Deep Arcade livrée (fond noir, picots blancs, cases fin néon, bille magenta, titre overlay Flutter) + refonte multiplicateurs échelle réduite + contrôles UI mise/billes en bas remplaçant le tap-to-launch.*
