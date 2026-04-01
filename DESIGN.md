# DESIGN.md — Plinko (Balleck Team)

> Source de vérité design du projet. Maintenu par Claude, validé par Matthieu.
> Mis à jour après chaque session design. Référencé dans CLAUDE.md.

---

## Identité visuelle

**Concept** : Arcade futuriste — la tension entre la précision d'une machine et l'excitation du hasard apparent.
**Ambiance** : Néons dans le noir. Élégant mais électrique. Sobre jusqu'à ce que ça explose.
**Cible plateforme** : Mobile portrait (360×780px de référence). Le plateau occupe ~90% de la largeur.

---

## Palette de couleurs

| Rôle | Nom | Hex | Usage |
|---|---|---|---|
| **Background** | Noir profond | `#0f0f1a` | Fond principal de l'app |
| **Surface** | Bleu nuit | `#1a1a2e` | Panneaux, cards, overlays |
| **Border** | Violet sombre | `#2e2e4e` | Séparateurs, bordures |
| **Accent primaire** | Violet néon | `#7c5cbf` | Éléments interactifs, highlights |
| **Accent secondaire** | Cyan électrique | `#00c8ff` | Bille, titres, état actif |
| **Texte principal** | Blanc froid | `#e0e0f0` | Corps de texte |
| **Texte secondaire** | Gris lavande | `#8888aa` | Labels, metadata |
| **Succès** | Vert menthe | `#4caf82` | Gains, validations |
| **Erreur** | Rouge corail | `#e05c5c` | Pertes, alertes |
| **Or jackpot** | Or chaud | `#f0c040` | Jackpot uniquement — réservé |

**Règle absolue** : L'or (`#f0c040`) est réservé exclusivement au jackpot. Ne jamais l'utiliser ailleurs.
**Règle absolue** : Fond sombre en permanence — jamais de fond clair, jamais de surface blanche.

---

## Grille — constantes physiques validées

> Validé par mesure sur screenshots de référence + calculateur sizing. Ne pas modifier sans recalculer le passage bille/picots.

```
ROWS        = 10          // rangs — rang R contient R+1 picots
BALL_RADIUS = 8           // px — rayon visuel ET physique
PEG_RADIUS  = 5           // px
GX          = 32          // px — espacement centre à centre horizontal
GY          = 37          // px — espacement centre à centre vertical (GX × 1.15)
GAP_FREE    = 6           // px — espace libre entre bille et picot (GX - 2×PEG - 2×BALL)
BALL_SPEED  = 1.0×        // modificateur de base — ralenti sur rangs 8-10

// Assertion à valider si les valeurs changent :
// GX > 2×PEG_RADIUS + 2×BALL_RADIUS  →  32 > 26 ✓

// Position d'un picot [R][C] :
// x = boardCenterX - (R × GX / 2) + C × GX
// y = topPadding + R × GY
```

**Grille triangulaire** : rang R contient R+1 picots. Total = 10×11/2 = **55 picots**.
**Cases** : 11 cases en bas (rang final + 1), symétriques.
**Passage garanti** : la bille ne peut aller qu'en `[R+1][C]` (gauche) ou `[R+1][C+1]` (droite) à chaque rang.
**Trajectoire prédéterminée** : `generatePath(targetCase, ROWS)` retourne un tableau de 9 directions `[0|1]` calculé au lancer. La physique visuelle est réelle, les directions aux picots sont forcées.

**Stratégie de suspense sur les derniers rangs :**
- Rangs 1–6 : vitesse normale
- Rangs 7–8 : vitesse × 0.7, caméra zoom léger
- Rangs 9–10 : vitesse × 0.4, caméra très proche — la bille semble hésiter

---

## Palette des picots par zone (grille triangulaire)

La grille est divisée en zones verticales avec une couleur dominante par zone.
La transition est progressive — pas de changement brutal entre zones.

| Zone | Couleur | Hex | Rangs |
|---|---|---|---|
| Haut | Cyan | `#00c8ff` | 1–3 |
| Milieu haut | Violet | `#7c5cbf` | 4–6 |
| Milieu bas | Violet foncé | `#4a3a8a` | 7–9 |
| Bas | Gris bleuté | `#556080` | 10 |

> Les lignes du bas sont plus sombres pour créer de la profondeur et accentuer le suspense final.

---

## Typographie

| Usage | Style | Taille | Couleur | Notes |
|---|---|---|---|---|
| Titre principal | Bold, uppercase | 28px | `#ffffff` | Glow violet léger |
| Section | Semi-bold | 20px | `#00c8ff` | Avec bordure basse cyan |
| Sous-titre | Semi-bold | 16px | `#cccccc` | — |
| Label | Bold uppercase | 12px | `#8888aa` | letter-spacing 0.05em |
| Corps | Regular | 15px | `#e0e0f0` | line-height 1.7 |
| Code | Mono | 13px | `#a0d0ff` | Sur surface `#1a1a2e` |
| Multiplicateur case | Bold | ~40% hauteur case | `#ffffff` | Centré verticalement et horizontalement |
| Jackpot label | Bold | ~40% hauteur case | `#f0c040` | Glow or |

**Police** : System stack — `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`
**Fallback mono** : `'SF Mono', 'Fira Code', monospace`

---

## Composants validés

### Plateau (board)

- Forme : rectangle légèrement trapézoïdal (bords convergent légèrement vers le bas)
- Bordure : 2px, couleur `#7c5cbf`, avec glow extérieur violet diffus (~8px blur)
- Fond interne : `#0f0f1a` avec légère texture nébuleuse (opacité 15–20%)
- Coins : radius 12px sur les coins extérieurs du cadre
- Marges internes : 16px sur les côtés, 12px en haut et en bas

### Bille

- Rayon : **8px** (= `BALL_RADIUS`) — visuel ET physique, pas de réduction
- Ratio bille/picot : **1.6×** — la bille domine visuellement les picots
- Couleur core : Cyan `#00c8ff`
- Reflet spéculaire : point blanc haut-gauche, radius 30% du rayon (2.4px), opacity 80%
- Halo interne : cyan `#00c8ff` à opacity 60%, radius 1.4× (11.2px)
- Halo externe (bloom) : cyan `#00c8ff` à opacity 25%, radius 2.5× (20px)
- Style : sphère cristalline translucide — pas opaque, pas flat

### Picots

- Rayon : **5px** (= `PEG_RADIUS`)
- Style : sphère cristalline avec reflet spéculaire haut-droit (point blanc, radius 30%, opacity 65%)
- Couleur : selon zone (voir tableau "Palette des picots par zone")
- Halo : même couleur que le picot, radius 2.2× (11px), opacity 40%
- Pas d'outline — le halo suffit à définir le bord
- État `hit` : flash blanc 60ms, halo × 2 pendant 200ms

### Cases de récompense

- Nombre : **11 cases** (= ROWS + 1, grille triangulaire à 10 rangs)
- Largeur unitaire : `(boardWidth) / 11` — s'adapte automatiquement
- Forme : trapèze inversé, plus large en haut qu'en bas — style "verre" ou "seau" cristallin
- Hauteur : ~60px
- Radius coins : 8px en haut, 2px en bas
- Fond : translucide `rgba(255,255,255,0.05)` avec bordure 1px `rgba(255,255,255,0.15)`
- Reflet interne : liseré blanc haut 1px, opacity 30% (effet verre)
- Label : centré, bold, taille ~20px (ajustée à la largeur)

**Labels et couleurs des 11 cases (de gauche à droite) :**

| Position | Label | Couleur label | Couleur bordure |
|---|---|---|---|
| 1 (bord) | ×1 | `#8888aa` | `#556080` |
| 2 | ×2 | `#00c8ff` | `#00c8ff` |
| 3 | ×5 | `#7c5cbf` | `#7c5cbf` |
| 4 | ×10 | `#4caf82` | `#4caf82` |
| 5 | ×50 | `#e05c5c` | `#e05c5c` |
| 6 (centre / jackpot) | ×500 | `#f0c040` | `#f0c040` |
| 7 | ×50 | `#e05c5c` | `#e05c5c` |
| 8 | ×10 | `#4caf82` | `#4caf82` |
| 9 | ×5 | `#7c5cbf` | `#7c5cbf` |
| 10 | ×2 | `#00c8ff` | `#00c8ff` |
| 11 (bord) | ×1 | `#8888aa` | `#556080` |

> Symétrique. Jackpot au centre (case 6). Valeurs configurables — seule la symétrie et la position centrale du jackpot sont des contraintes design.

### Trajectoire — mécanique prédéterminée

> La récompense est fixée en début de partie. La trajectoire est calculée avant le lancer.

```
generatePath(targetCase, ROWS) → [d0, d1, ..., d8]
// di ∈ {0=gauche, 1=droite}
// La bille part du picot [0][0] (sommet)
// À chaque rang R, col suivante = min(col + di, R)
// La case d'atterrissage = col finale après 9 décisions
```

**Stratégie de suspense par zone :**

| Rangs | Vitesse | Caméra | Intention |
|---|---|---|---|
| 1–6 | × 1.0 | Suit la bille, zoom normal | La bille vit, rebondit librement |
| 7–8 | × 0.7 | Zoom léger vers le bas | Tension qui monte |
| 9–10 | × 0.4 | Très proche, quasi macro | La bille hésite — révélation imminente |

La physique visuelle (gravity, bounce au contact) est réelle. Seules les **directions aux picots** sont forcées.

### Overlay récompense — brief validé (2026-03-31)

**Direction : L'Explosion Contrôlée** — l'impact physique de la bille déclenche la célébration.

| État | Animation | Durée totale | Couleur |
|---|---|---|---|
| **Perte** | Fade doux (200ms), plateau s'assombrit à 60%, message rassurant centré, fade-out 400ms | ~800ms | Neutre — pas de rouge |
| **Gain normal** | Flash blanc 80ms → confettis depuis la case vers le haut 600ms → montant scale+bounce 300ms → halo pulse 2× | ~1.2s | Cyan `#00c8ff` |
| **Jackpot** | Flash long 150ms → toutes cases dimmed 200ms → fontaine particules or 1s → halo pulse 3× → montant tremble 1s puis scale stabilisé | ~2.5s | Or `#f0c040` exclusif |

**Règles d'animation :**
- Zéro effet pendant le vol de la bille — tout commence à l'atterrissage
- Confettis partent depuis la case gagnante (pas du haut de l'écran)
- Le montant est toujours le centre visuel — les effets l'entourent, jamais devant
- Jackpot : toutes les autres cases s'éteignent (`opacity: 0.2`) avant la révélation (focus total)
- Easing standard : `cubic-bezier(0.34, 1.56, 0.64, 1)` pour les bounces
- Easing fade : `ease-out` pour les disparitions

---

## Système de z-index

```
100 — overlay récompense (confettis, montant, halo)
 80 — bille (toujours au-dessus des picots)
 60 — picots
 40 — cases de récompense
 20 — cadre du plateau / bordure
 10 — fond du plateau (texture nébuleuse)
  0 — background app
```

---

## Animations & motion

| Élément | Comportement | Valeur |
|---|---|---|
| Caméra | Lerp fluide vers la bille | `cameraLerp = 0.08` |
| Caméra avance | Anticipation vers le bas | `cameraLeadY = 3.0` |
| Confettis gain | Scale 0→1, direction aléatoire ±45°, gravity | durée 600ms |
| Montant gain | Scale 0.5→1.1→1.0, opacity 0→1 | durée 300ms, bounce easing |
| Halo case gagnante | opacity 0.4→1.0→0.4 repeat | 3 pulses, 400ms each |
| Cases jackpot dimmed | opacity 1→0.2 | durée 200ms, ease-out |
| Flash blanc initial | opacity 0→0.8→0 | durée 80ms (gain) / 150ms (jackpot) |

**Principe** : le suspense vient de la caméra qui suit la bille et révèle progressivement l'atterrissage. Pas d'effets artificiels pendant le vol.

---

## États des composants

### Picot
| État | Visuel |
|---|---|
| `idle` | Couleur de zone, halo standard |
| `hit` | Flash blanc 60ms, halo x2 pendant 200ms puis retour idle |

### Case de récompense
| État | Visuel |
|---|---|
| `idle` | Translucide, bordure couleur de zone |
| `active` (bille dedans) | Bordure full opacity, halo extérieur |
| `dimmed` (jackpot reveal) | opacity 0.2, pas de halo |
| `jackpot` | Bordure or pleine, glow or fort |

### Bille
| État | Visuel |
|---|---|
| `flying` | Normal — aucun effet spécial |
| `landed` | Flash de la case → bille disparaît |

---

## Thémisation (Post-MVP)

L'identité visuelle est conçue pour être remplacée par la charte d'une marque cliente :
- Palette de couleurs → tokens CSS/Dart remplaçables
- Logo marque → zone dédiée en haut de l'écran
- Récompenses → configurables par marque
- L'ambiance "futuriste" est le thème par défaut, pas une contrainte permanente

---

## Prompt prefix — image-gen (à copier en tête de chaque prompt asset)

```
Sci-fi neon arcade style. Near-black deep space background (#0f0f1a).
Additive light blending — glows accumulate on darkness.
Color palette: neon violet #7c5cbf, electric cyan #00c8ff, white core highlights.
Crystal/glass material style — translucent with specular highlight top-right.
Transparent PNG, no background, isolated object.
Consistent with a dark futuristic Plinko board aesthetic.
```

---

## Dos & Don'ts

**Faire**
- Fond sombre en permanence — jamais de fond clair
- Or uniquement pour le jackpot
- Néons sur fond noir pour les moments forts (win, jackpot)
- Animations sobres pendant le vol, spectaculaires à l'atterrissage
- Reflet spéculaire sur tous les objets ronds (bille, picots)
- Z-index respecté à chaque composant

**Ne pas faire**
- Mélanger or et cyan sur le même élément
- Effets pendant le vol de la bille (ça casse l'illusion)
- Texte blanc sur surface claire
- Plus de 2 couleurs d'accent sur le même écran (hors jackpot)
- Coins ronds > 12px sur le cadre principal
- Picots sans halo — le halo est constitutif du style

---

## Sessions design à venir

| Sujet | Priorité | Format |
|---|---|---|
| Visuel end game (overlay refonte) | Haute | Chat + screenshots → DESIGN.md |
| Écran d'intro | Basse | À cadrer |
| Thème marque template | Post-MVP | À cadrer |

---

*Dernière mise à jour : 2026-04-01 — Grille triangulaire 10 rangs validée. Constantes physiques figées : BALL_RADIUS=8, PEG_RADIUS=5, GX=32, GY=37, GAP_FREE=6. Cases passées de 7 à 11 (ROWS+1) avec labels et couleurs complets. Passage bille/picots garanti (32 > 26 ✓). Stratégie de suspense rangs 7–10 documentée.*
