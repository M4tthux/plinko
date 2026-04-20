# 🎨 Design UI — DROPL (ex-Plinko)

> **Spec UI vivante.** Source de vérité : [page Notion](https://www.notion.so/Design-UI-347d826db45980498628dfd5b720a15c).
> Ce fichier Markdown est le miroir versionné (copier-coller dans Notion en cas de MAJ).
> Assets lourds (PNG de ref, prototypes HTML/JSX) : `design_handoff/design_handoff_plinko_onboarding_hifi/`. ⚠️ Les `.html` et `.jsx` sont des **prototypes de référence uniquement** — la production est en Flutter/Dart.
>
> **Rebrand 2026-04-20** : le wordmark passe de **PLINKO** → **DROPL** (5 lettres, "lowered O" comme cue de chute). Le nom de produit affiché est désormais DROPL ; "Plinko" reste l'identifiant tech interne (repo, package, dossier `plinko_app/`, clés `plinko_*`). Voir §2bis "Wordmark — DROPL" et §7 pour les décalages spec ↔ code (le wordmark "PLINKO" est encore rendu dans `landing_screen.dart` — refonte code en session dédiée).

---

## 1. Direction artistique — Deep Arcade (Neon Noir)

**Principe central :** *80 % de l'écran sombre et mat pour que les 20 % lumineux aient du poids. Si on retire la bille et les picots, le fond doit être presque ennuyeux.*

- **Anti-pattern** : gros contours épais uniformes. Vrai néon = trait fin + halo large.
- **Fond noir #050510 / #08080F** neutre, pas de gradient violet, pas d'étoiles, pas de grille perspective.
- **Picots blancs purs** — halo discret au repos, amplifié au hit.
- **Bille magenta `#FF3EA5`** — c'est l'élément qui doit briller sans rivaliser avec les cases jackpot.
- **Cases rectangles verticaux contour fin néon** — hiérarchie par la chaleur, pas la taille. x0.1 gris neutre, jamais rouge ni punitif.
- **Cyan = accent** (contour, ring, CTA primaire), **magenta = action** (bille, boutons billes).

Validée Build 47→54 après benchmark multi-agents (benchmark / game-designer / designer).

---

## 2. Design tokens

### Couleurs

| Token | Hex | Usage |
|---|---|---|
| `--bg-base` | `#050510` | Fond principal |
| `--bg-mid` | `#0b0b1c` | Élévation 1 (cards, panels) |
| `--accent-cyan` | `#22e4d9` | Contour ring, CTA primaire, accents UI |
| `--accent-magenta` | `#FF2EB4` | Bille (ball.dart), boutons lancer (main.dart), extrémités cases. Note : landing_screen.dart utilise `#FF3EA5` pour le dégradé ambiant fond uniquement. |
| `--accent-green` | `#47e57a` | Alt (réservé succès / futur) |
| `--mult-x10` | `#ff3ea5` | Case x10 (edge) |
| `--mult-x2` | `#c64aff` | Case x2 |
| `--mult-x0.5` | `#5b6cff` | Case x0.5 |
| `--mult-x0.1` | `#2a2d4a` | Case x0.1 (neutre) |
| `--text` | `#ffffff` | Texte principal |
| `--text-muted` | `rgba(255,255,255,0.55)` | Texte secondaire |
| `--text-ghost` | `rgba(255,255,255,0.3)` | Ghost links |
| `--spotlight-dim` | `rgba(0,0,0,0.62)` | Overlay onboarding |

### Background recipe (écran de jeu)

> 📐 **Notation d'intention (CSS-like)** — ce bloc décrit le *résultat visuel voulu*, pas du code. Flutter implémente via `CustomPainter` + `Stack` : `RadialGradient` pour les dégradés, `CustomPaint` pour la texture diagonale et le bruit fractal. Voir §7 pour les décalages d'implémentation connus.

```
radial-gradient(ellipse 80% 40% at 50% 0%,   <accent>18 0%, transparent 60%),
radial-gradient(ellipse 120% 60% at 50% 110%, #ff3ea514 0%, transparent 55%),
linear-gradient(180deg, #0a0a18 0%, #07070f 100%)
+ SVG fractal-noise overlay, opacity 0.6, mix-blend overlay
+ 135° diagonal 2px/5px repeating lines, rgba(255,255,255,0.012)
```

### Typographie

| Rôle | Police | Specs |
|---|---|---|
| Primary | Space Grotesk | 400 / 500 / 600 / 700 |
| Mono | JetBrains Mono | 400 / 500 — microcopy, build stamp, labels uppercase |
| Wordmark | Space Grotesk 700 | **DROPL** — voir §2bis. Lockup header 40px / letter-spacing −1.85, splash 52px / letter-spacing −2.4, "lowered-O" construction. ⚠ Ancien wordmark PLINKO (44px, ls 8px, halo cyan) **abandonné**. |
| Body | Space Grotesk | 14–15px, line-height 1.4–1.45 |
| Eyebrow | Space Grotesk / Mono uppercase | 11px, letter-spacing 2–2.5px |

---

## 2bis. Wordmark — DROPL (final)

**Concept : Chute.** Un "O" abaissé est le seul ornement du wordmark. Le mot se lit DROPL en premier ; le cue de chute est un micro-événement vertical *à l'intérieur* du mot, pas une décoration autour.

### Construction

- **Police** : Space Grotesk 700
- **Letter-spacing** : proportionnel à la taille — `letter-spacing = size × −0.046`. À 52px → −2.4px. À 40px → −1.85px.
- **Groupes de kerning** : `DR | O | PL` rendus comme **trois `<text>` SVG distincts**, pour que le O puisse se déplacer en Y sans affecter le reste du mot.
- **Baseline offset** : le O est positionné **+10 unités SVG sous la baseline** de DR/PL (≈ 19 % de la cap-height, soit ~10px à 52px et ~8px à 40px).
- **Position horizontale du O** : optiquement centré entre DR et PL. Au lockup 52px (viewBox 220) : DR center 58, O center 110, PL center 160.
- **Pas d'ornement** : pas de soulignement, pas de trail, pas de glow, pas d'accent couleur. Blanc pur sur fond sombre.

### SVG de référence (lockup isolé, 52px — splash / app icon)

```html
<svg viewBox="0 0 220 72" aria-label="DROPL">
  <g text-anchor="middle" font-family="Space Grotesk" font-weight="700"
     font-size="52" letter-spacing="-2.4" fill="#fff">
    <text x="58"  y="50">DR</text>
    <text x="110" y="60">O</text>   <!-- +10 vs baseline 50 -->
    <text x="160" y="50">PL</text>
  </g>
</svg>
```

### SVG de référence (in-screen, 40px — header de jeu)

```html
<svg viewBox="0 0 160 56" aria-label="DROPL">
  <g text-anchor="middle" font-family="Space Grotesk" font-weight="700"
     font-size="40" letter-spacing="-1.85" fill="#fff">
    <text x="42"  y="38">DR</text>
    <text x="80"  y="46">O</text>   <!-- +8 vs baseline 38 -->
    <text x="116" y="38">PL</text>
  </g>
</svg>
```

### Règles d'usage

- ❌ **Ne pas** substituer une autre police — le "O qui tombe" ne se lit que parce que le reste est en Space Grotesk 700 serré.
- ❌ **Ne pas** animer le O en affichage normal. Animation d'entrée (le O tombe depuis −20px) **uniquement sur splash / app launch**.
- ❌ **Ne pas** colorer le O — il reste du même blanc que DR / PL.
- 📏 **Taille minimum** : **28px**. En dessous, le O abaissé se lit comme une erreur de baseline. Utiliser un `DROPL` plat (sans drop) sous 28px.

### App-icon / splash

- Lockup 52px centré sur canvas `#050510` avec la background recipe standard (voir §2).
- App icon : un seul "D" à 64 % de la hauteur du canvas, même police / weight, centré. Le wordmark complet ne descend pas à la taille d'icône.

> **Implémenté Build 60** : `DroplWordmark(size)` dans `plinko_app/lib/ui/widgets/dropl_wordmark.dart`. CustomPainter + 3 `TextPainter` (DR / O / PL), `text-anchor=middle` via `centerX - width/2`, baseline via `computeDistanceToActualBaseline`. Pas de dépendance `flutter_svg` ajoutée.

---

## 3. Composants

### Board & pegs (spec hi-fi)

```
Grid:      10 rows visibles (12 logiques, startRow=2), count = r + 3 pegs per row (3…12)
Spacing:   7 viewBox units (viewBox 100×110)
Peg outer: r=1.1, white radial glow, opacity 0.35 (0.7 sur spotlight step 3)
Peg core:  r=0.55, solid white
Ball core: r=1.4, #FF2EB4 (magenta prod — ball.dart)
Ball glow: r=2.2, radial-gradient #ff7cc8 → #FF2EB4 → transparent, blur 1.2, opacity 0.75
Ball hi:   r=0.45, white 0.75, offset (-0.4, -0.4) (spéculaire)
Trail:     stroke #FF2EB4, width 0.4, dash 0.8 / 0.6, opacity 0.5
```

### Chips — rangée mise / rangée billes

```
Stake chip  42h, radius 10
  idle     : 1px white/15, bg white/4
  selected : 1px cyan,     bg linear(cyan22 → cyan44), shadow glow + inset
Ball chip   40h, radius 10
  idle     : 1px magenta55, bg magenta 0a → 14
  selected : 1px magenta,   bg magenta33 → 55, shadow glow + inset
```

### Cases multiplicateur

```
Row flex, gap 3, padding 0 1%
Chaque cellule : radius 6, 1px solid <color>,
                 bg linear(color22 → color44), padding 5px 0
Texte : 11 / 700 Space Grotesk, text-shadow de la couleur
Edges (x10) : outer glow 12px + 4px supplémentaire
```

### Callout coachmark (onboarding)

```
Position : auto — below si spot dans moitié haute, above sinon
Width    : phone-width − 36 (18 margin latérale)
Padding  : 14 16 14
Radius   : 16
Bg       : linear(180°, rgba(20,20,36,0.92), rgba(12,12,24,0.92))
Border   : 1px cyan/40%
Backdrop : blur(20px) saturate(140%)
Shadow   : 0 10 30 rgba(0,0,0,0.5), 0 0 20 cyan/27, inset 0 1 0 white/8
Title    : 20 / 700, tracking -0.3
Body     : 13, line 1.45, white/75
CTA      : 8×18, radius 10, bg linear(cyan → cyanCC), text #0a0a18, 13/700
Step pill: "<n> / 4" en cyan, 20h, radius 10
Dots     : 4 dots — active 16×5 cyan, idle 5×5 white/20
Anim     : fade + 8px rise, 420ms cubic-bezier(0.2, 0.8, 0.2, 1)
```

### Spotlight

```
Mask   : SVG <mask> rect blanc + trou rounded-rect noir sur target
Ring   : 1.5px cyan, radius 14, box-shadow 16px cyan/53 + 32px cyan/33 + inset 16px cyan/20
Padding: 6px autour de la cible (10px sur step 3 — le plateau)
Motion : transition 420ms same ease
```

> ⚠ **Décalage d'implémentation** (Build 59) : en Flutter Web, le ring est une bordure **2px cyan sèche sans halo** et le dim est fait via **4 rectangles** autour du trou (pas `Path.combine` ni `BlendMode.clear`). Voir §7.

### Progress bar (toujours visible pendant le tour)

```
Top: 58, height 3, radius 3, bg white/10
Fill: ((step-1)/4) × 100%, cyan + 8px cyan shadow
```

### Skip button

```
Top-right of phone, 64,16
Padding 6×12, radius 14, 12px
Bg rgba(0,0,0,0.4), backdrop-blur 8, border 1px white/20
Caché au step final (le CTA "Terminer" fait la fin naturelle)
```

### Help button (?) — relance du tour (Build 64)

```
Position : top:16, right:62 (40 + 10 gap + 12 marge burger à droite)
Size     : 40×40 (strictement aligné sur le burger ⚙ et la balance)
Radius   : 10
Bg       : #0A0A14 @ 0.75
Border   : 1px cyan #00D9FF @ 0.85
Shadow   : cyan @ 0.35, blur 10
Icon     : Icons.help_outline, white, 20px
Tap      : setState(_tourActive = true) → relance au step 1/4 (wordmark DROPL)
           hasSeenTour inchangé — le bouton est un déclencheur, pas un reset
```

> Source de vérité tailles HUD top = burger ⚙ actuel. Balance wrappée en `height:40 + alignment:center` pour aligner visuellement sur la même ligne.

---

## 4. Onboarding — flow 5 steps

### 01 — Landing
- Game UI derrière un gradient vertical fade-to-black bas
- Headline : **"Tombe. Rebondit. Gagne."** (26px / 700 / tracking −0.5)
- Sous-titre : *"Mini-jeu physique. Chaque lancer, un chemin différent."* (14px, 65 % white)
- CTA primaire : **Jouer** (dégradé cyan, 52h, radius 14, glow)
- Ghost link : **Comment ça marche ?** — lance le tour (tourStep = 2)

### 02 — Intro (spotlight sur le wordmark)
- Overlay dim 62 % noir, trou SVG-mask autour du wordmark **DROPL** (voir §2bis)
- Ring cyan + glow sur le spotlight
- Callout docké sous le wordmark :
  - Title : *"Comment fonctionne DROPL"*
  - Body : *"Lâche des billes depuis le haut. Chaque bille atterrit dans une case à multiplicateur."*

### 03 — Le plateau
- Spotlight couvre toute la pyramide de picots
- **Demo ball** tombe automatiquement 500ms après l'entrée du step, trajectoire aléatoire, trail dashed magenta
- Callout sous le plateau :
  - Title : *"Le plateau"*
  - Body : *"Les picots randomisent la trajectoire. Les cases extérieures paient plus, les centrales moins."*

### 04 — Mise (€ / bille)
- Spotlight = bande horizontale autour de la rangée mise (€1 / €2 / €5 / €10)
- Callout dockée **au-dessus** du spotlight (proche du bas)
- Title : *"Mise par bille"* · Body : *"Choisis combien coûte chaque bille. Débité de ton solde."*
- Première chip (€1) en état sélectionné

### 05 — Billes par lancer (final)
- Spotlight sur la rangée billes (1 / 2 / 5 / 10)
- Callout dockée **au-dessus**
- Title : *"Billes par lancer"* · Body : *"Choisis 1 à 10. Coût total = mise × billes."*
- CTA passe de **"Suivant"** → **"Terminer"** ; tap = fin du tour

---

## 5. Interactions & state machine

### Tour state machine

```
tourStep    : 1..5   (1 = landing, 2..5 = tour)
hasSeenTour : boolean   // persisté en SharedPreferences

// entry points
  fresh user + !hasSeenTour  → tourStep = 2 (non-gating actuellement, voir §7)
  ghost "Comment ça marche ?" → tourStep = 2
  in-game help button (?)     → tourStep = 2 (Build 64, relance à tout moment ; hasSeenTour inchangé)
  primary "Jouer"             → tourStep = 1 (no tour ; set hasSeenTour)

// transitions
  Suivant   → tourStep = min(5, tourStep+1)
  Passer    → tourStep = 1, hasSeenTour = true
  Terminer  → tourStep = 1, hasSeenTour = true
```

### Demo ball (step 3)
- Se lance une fois à l'entrée step 3, délai 500ms
- 10 rebonds, L/R aléatoire par rang, ~140ms par rebond
- Trail magenta dashed qui s'accumule
- En fin de course, atterrit dans une case (option : flash de la cellule)

### Selection state qui évolue
- Step 4+ : première chip mise (€1) en sélection
- Step 5 : 2e chip billes (2) en sélection
- Purement visuel pendant le tour ; la vraie sélection = input utilisateur post-tour

### Keyboard (dev only — retirer avant prod)
- ← / → naviguer entre steps
- R relance depuis step 1

### Persistence
- Design/prototype HTML : `localStorage` (`plinko-step`, `plinko-tweaks`) — **prototype uniquement, jamais en prod**
- Production Flutter : `SharedPreferences` → clé `plinko_has_seen_tour`

---

## 6. Motion spec

| Élément | Durée | Easing | Détail |
|---|---|---|---|
| Spotlight hole + ring | 420ms | `cubic-bezier(0.2, 0.8, 0.2, 1)` | position + size |
| Callout | 420ms | same | 8px rise + opacity fade au change de step |
| Progress bar fill | 420ms | same | — |
| Dot pill (active) | 200ms | — | length + color crossfade |
| Demo ball | 140ms / peg | linear | snappy ; swap pour easing si physique compatible |

---

## 7. Décalages connus — spec vs code actuel (Build 59)

> Historique complet dans `decisions-log.md` et `sessions/2026-04-19_onboarding-landing-session.md`.

| Sujet | Spec (handoff) | Code actuel | Raison du décalage |
|---|---|---|---|
| **Grille plateau** | ~~11 rangs, 3…13 picots~~ → **corrigé : 10 rangées visibles (12 logiques), 3…12 picots, 9 cases** | Aligné avec le code | Gap résiduel : les assets `design_handoff/hifi/*.jsx` et les prototypes HTML décrivent encore l'ancienne grille 11 rangs / 3–13 picots. À mettre à jour quand on relancera le handoff Design. |
| **Dim overlay** | SVG mask `<mask>` | **4 rectangles** autour du trou | `Path.combine(difference)` / `saveLayer + BlendMode.clear` rendent de façon incohérente sur le renderer HTML Flutter Web. |
| **Ring spotlight** | 1.5px + halo 16/32/inset | **2px sèche, aucun halo** | Cumul des `BoxShadow` cyan (ring + callout + progress) teintait tout l'écran. Cyan réservé au contour. |
| **Demo ball step 3** | Spec | **Pas encore implémentée** | À faire. |
| **Dots progression** | Bas-gauche callout | **Haut-droite callout** | À aligner. |
| **Eyebrow "HOW TO PLAY"** | Spec | **Absent** | À ajouter (équivalent FR "COMMENT JOUER"). |
| **Auto-launch tour** | fresh user + !hasSeenTour | **Manuel uniquement** (via "Comment ça marche ?") | `hasSeenTour` persisté mais non-gating pour l'instant. |
| **Typo globale** | Space Grotesk + JetBrains Mono partout | ✅ **Résolu Build 63** : Space Grotesk appliqué sur balance, boutons bet, boutons lancer, popup gain, labels multiplicateurs cases. JetBrains Mono sur build stamp (microcopy). Labels cases w700 (match spec §3). Seul reste non typé : `_SidePanelPlaceholder` desktop (hors scope — placeholder temporaire). | — |
| **Wordmark DROPL** | Lockup 3 `<text>` SVG, O abaissé +10 unités, ls −2.4 (52px) / −1.85 (40px) | **✅ Résolu Build 60** : `DroplWordmark(size)` dans `plinko_app/lib/ui/widgets/dropl_wordmark.dart` (CustomPainter + 3 TextPainter, mapping fidèle du viewBox). Remplace landing (size 52) + `_PlinkoTitleOverlay` in-game (size 40 responsive). Callout step 02 : "Comment fonctionne DROPL". | — |
| **Identifiants tech** | — | Repo `M4tthux/plinko`, dossier `plinko_app/`, classe `PlinkoGame`, clé prefs `plinko_has_seen_tour`, URL `m4tthux.github.io/plinko` | **Décision** : DROPL = nom de marque/produit affiché. "Plinko" reste l'ID tech interne (pas de rename repo / package au MVP). À reconsidérer Post-MVP si la marque DROPL se consolide. |

---

## 8. Sources & assets

### Handoff Claude Design (GitHub)
`design_handoff/design_handoff_plinko_onboarding_hifi/`

- `README.md` — brief original (EN, source de cette spec — version 2026-04-20 incluant rebrand DROPL)
- `reference-hifi.png` — screenshot de référence visuelle
- `Plinko Onboarding Hifi.html` — prototype hi-fi onboarding (référence, pas code prod)
- `DROPL Wordmark In-Context.html` — lockup wordmark final (isolé 52px + in-context 40px) — voir §2bis
- `Plinko Onboarding Wireframes.html` — wireframes lo-fi initiaux
- `hifi/*.jsx` — composants React de référence (board, screen, tour, frame)

### Sessions de référence

- `sessions/2026-04-18_design-deep-arcade.md` — définition de la DA
- `sessions/2026-04-19_onboarding-landing-session.md` — implémentation onboarding

### Fichiers de code impactés

- `plinko_app/lib/ui/landing_screen.dart`
- `plinko_app/lib/ui/onboarding/coachmark.dart`
- `plinko_app/lib/ui/onboarding/tour_overlay.dart`
- `plinko_app/lib/services/onboarding_prefs.dart`
- `plinko_app/lib/config/plinko_config.dart` (tokens concrets : `slotMultipliers`, `pegRadius`, `ballRadius`…)

---

## 9. Questions ouvertes (héritées du handoff)

1. Le jeu tracke-t-il déjà un flag "first-time" ? Si oui, quelle clé ?
2. Tour auto au 1er open, ou manuel via "Comment ça marche ?" uniquement ? *(actuellement : manuel)*
3. Cibles de localisation — wireframe FR, hi-fi EN. Autres locales au launch ?
4. La demo ball step 3 doit-elle atterrir dans une case précise (ex. toujours x0.5) ou vraiment aléatoire ?
5. La cellule mult doit-elle flasher / highlight quand la demo ball atterrit ?

---

## 10. Règle source de vérité

- **Intention + tokens évolutifs** → cette page Notion
- **Valeurs exactes en prod** → `plinko_app/lib/config/plinko_config.dart`
- **Assets binaires + prototypes** → `design_handoff/` sur GitHub
- **Historique des décisions** → `decisions-log.md` + `sessions/`

En cas de conflit entre cette page et le code : le code gagne pour les valeurs, la page gagne pour l'intention. Toute divergence doit être tracée dans §7.
