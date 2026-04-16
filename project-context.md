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
- **Ambiance futuriste / arcade** — néons, fond sombre, bille lumineuse

---

## Questions ouvertes

### Game Design
- Écran d'intro : animation bille ou simple logo marque ? (basse priorité)
- Équilibrage multiplicateurs x100 : probabilité réelle vs ressenti joueur à monitorer

### Design / Dev
- **Visuel end game** — overlay jackpot x100 spectaculaire à décider (feux d'artifice, halo) ou sobriété popup actuel
- **VFX Phase 2** — flash case, screen shake, scale pulse
- **LaunchZoneOverlay DEBUG** (Z0–Z4) — à retirer avant prod

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
| Game Design | 🟢 Build 41 validé | Mode multiplicateur casino + multi-ball |
| Tech & Architecture | 🟢 Stabilisé | Sub-stepping, physique pure, grille triangulaire |
| Design & UI | 🟡 En cours | VFX Phase 1 OK. Phase 2 à faire |
| Dev | 🟢 Build 41 | Animation "+X€" validée |
| CI/CD | 🟢 Done | Auto-deploy gh-pages |
| Test mobile (web) | 🟢 OK | Safari/Chrome iPhone via GitHub Pages |
| Flutter local | 🟢 OK | v3.41.6 Windows (Git CMD) |
| Build natif iOS/Android | 🔴 Bloqué | Mac + Xcode requis |

---

*Dernière mise à jour : 2026-04-17 — allègement contexte (virer doublons CLAUDE.md + narratif).*
