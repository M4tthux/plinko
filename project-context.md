# PROJECT CONTEXT — Plinko (Balleck Team)

> Source de vérité **produit** (vision, décisions, état). Quick ref technique : [`CLAUDE.md`](CLAUDE.md).

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
- **Hiérarchie docs** — project-context.md = source de vérité (vision + décisions + statut), CLAUDE.md = quick ref technique pour Claude Code. Deux fichiers, c'est tout. Vision uniquement dans project-context.md pour éviter le doublon.
- **Hook SessionStart** (`.claude/settings.json`) — `git pull` + `cat project-context.md` + dernier log `sessions/` à chaque démarrage. Garantit qu'aucune session ne démarre froide, même sans phrase trigger explicite.
- **Phase 2 différée** — refonte hook + skill plinko-context-loader (aujourd'hui ils doublonnent : hook lit project-context + dernier log, skill relit tout + Notion). À faire après 2 sessions de test Phase 1.

### Tech
- **Flame + physique manuelle** — Forge2D supprimé car incompatible Flutter Web
- **Sub-stepping ×4** — anti-tunneling validé via benchmark Stake / BGaming / Matter.js
- **Config hard-codée `plinko_config.dart`** — pas de backend au MVP, personnalisation marque = Post-MVP
- **CI push master → gh-pages auto** — plus besoin du PC pour déployer
- **Grille triangulaire** — `worldWidth` dérivé de `(rows-1) × pegGX + 2 × pegRadius` pour alignement pixel-perfect cases/picots
- **Trajectoires pré-calculées + replay frame par frame** — `generate_trajectories.py` produit un JSON (stride=1, interpolation linéaire côté Dart). Au runtime : zone du doigt → sélection d'une trajectoire → replay. Fallback physique temps réel si trajectoire manquante. Actuellement masqué par `forcePhysicsMode = true` en attendant régénération post-Build 45.

### Game Design
- **Illusion de hasard totale** — résultat pré-déterminé, trajectoire rejouée frame par frame
- **Lancer à l'aveugle** — pas d'aperçu de trajectoire, pas de ligne fantôme, pas de prédiction visuelle. Le joueur tape et découvre la chute. Oriente toute décision UI future (pas de helpers, pas d'indicateurs de probabilité pré-lancement).
- **Mode multiplicateur casino (Build 40)** — abandon du système PrizeLot probabiliste, remplacé par multiplicateurs positionnels fixes (lisibilité + standard industrie)
- **1 tap = 1 bille = −1€, multi-ball** — rythme de jeu soutenu, économie claire
- **Lancement centre + jitter, pas de parois** — distribution binomiale pure comme les vrais Plinko
- **Pas de sons / haptique au MVP** — repoussé Post-MVP pour ne pas figer le contrat son/marque
- **Ambiance futuriste / arcade** — néons, fond sombre, bille lumineuse
- **9 cases découplées des picots (Build 45)** — picots restent en grille triangulaire 12 rangs, mais les 9 cases du bas répartissent uniformément la largeur (slotWidth ≠ pegGX). Multiplicateurs : `100·25·10·2·0.1·2·10·25·100`. Décision = lisibilité mobile prime sur l'alignement strict cases/picots.

### Design / Immersivité mobile (Build 42→45)
- **Plein écran** — `AspectRatio(9/16)` retiré : le canvas occupe toute la fenêtre (récup ~150px sur iPhone 14)
- **Zoom dynamique fit-largeur** — `camera.zoom = screenWidth × 0.96 / worldWidth` recalculé sur chaque resize (vs zoom fixe 24 avant)
- **Réduction grille 17→9 cases, 16→10 rangées visibles** — cases 2× plus larges à l'écran. Trajectoires obsolètes mais `forcePhysicsMode = true` donc no-op (à régénérer si on relance le replay)
- **Picots/bille +20%** — `pegRadius 0.12→0.14`, `ballRadius 0.16→0.19` (ratio bille/picot maintenu ~1.36)

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
| Game Design | 🟢 Build 45 validé | 9 cases, multi `100·25·10·2·0.1·…` |
| Tech & Architecture | 🟢 Stabilisé | Sub-stepping, physique pure, grille triangulaire, cases découplées |
| Design & UI | 🟡 En cours | Immersivité mobile OK (Build 45). Trajectoires à régénérer. VFX Phase 2 à faire |
| Dev | 🟢 Build 45 | Plein écran + zoom dynamique + 9 cases |
| CI/CD | 🟢 Done | Auto-deploy gh-pages |
| Test mobile (web) | 🟢 OK | Safari/Chrome iPhone via GitHub Pages |
| Flutter local | 🟢 OK | v3.41.6 Windows (Git CMD) |
| Build natif iOS/Android | 🔴 Bloqué | Mac + Xcode requis |

---

*Dernière mise à jour : 2026-04-17 — Build 45 : plein écran + zoom dynamique + grille 9 cases découplée des picots.*
