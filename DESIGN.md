# DESIGN.md — Plinko (Balleck Team)

> Source de vérité design du projet. Maintenu par Claude, validé par Matthieu.
> Mis à jour après chaque session design. Référencé dans CLAUDE.md.

---

## Identité visuelle

**Concept** : Arcade futuriste — la tension entre la précision d'une machine et l'excitation du hasard apparent.
**Ambiance** : Néons dans le noir. Élégant mais électrique. Sobre jusqu'à ce que ça explose.

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

**Règle** : L'or (`#f0c040`) est réservé exclusivement au jackpot. Ne jamais l'utiliser ailleurs.

---

## Typographie

| Usage | Style | Taille | Notes |
|---|---|---|---|
| Titre principal | Bold, uppercase | 28px | `#ffffff` |
| Section | Semi-bold | 20px | Cyan `#00c8ff`, avec bordure basse |
| Sous-titre | Semi-bold | 16px | `#cccccc` |
| Label | Bold uppercase | 12px | `#8888aa`, letter-spacing 0.05em |
| Corps | Regular | 15px | `#e0e0f0`, line-height 1.7 |
| Code | Mono | 13px | `#a0d0ff` sur surface |

**Police** : System stack — `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`
**Fallback mono** : `'SF Mono', 'Fira Code', monospace`

---

## Composants validés

### Bille
- Rayon visuel = rayon physique (0.60 unités)
- Couleur : Cyan `#00c8ff` avec halo lumineux (2× et 1.4× le rayon)
- Pas de réduction visuelle (le gap bille/picot doit être nul)

### Picots
- Couleur : Violet `#7c5cbf` ou blanc selon le thème
- Rayon : 0.25 unités

### Cases de récompense
- 7 cases, labels centrés
- Jackpot central : or `#f0c040`, gras
- Autres cases : blanc `#e0e0f0`

### Overlay récompense — brief validé (2026-03-31)

**Direction : L'Explosion Contrôlée** — l'impact physique de la bille déclenche la célébration.

| État | Animation | Couleur |
|---|---|---|
| **Perte** | Fade doux, plateau s'assombrit, message rassurant centré | Pas de rouge — neutre |
| **Gain normal** | Flash blanc court → confettis depuis la case vers le haut → montant scale+bounce → halo | Cyan `#00c8ff` |
| **Jackpot** | Flash long → toutes cases s'éteignent sauf la gagnante → fontaine particules or → halo pulse 3× → montant tremble 1s puis se stabilise | Or `#f0c040` exclusif |

**Règles d'animation :**
- Zéro effet pendant le vol de la bille — tout commence à l'atterrissage
- Confettis partent depuis la case gagnante (pas du haut de l'écran)
- Le montant est toujours le centre visuel — les effets l'entourent, jamais devant
- Jackpot : toutes les autres cases s'éteignent avant la révélation (focus total)

---

## Animations & motion

| Élément | Comportement | Valeur |
|---|---|---|
| Caméra | Lerp fluide vers la bille | `cameraLerp = 0.08` |
| Caméra avance | Anticipation vers le bas | `cameraLeadY = 3.0` |
| Overlay récompense | Fade-in + scale | À définir en session design |
| Jackpot | Feux d'artifice + halo or | À implémenter |

**Principe** : le suspense vient de la caméra qui suit la bille et révèle progressivement l'atterrissage. Pas d'effets artificiels pendant le vol.

---

## Thémisation (Post-MVP)

L'identité visuelle est conçue pour être remplacée par la charte d'une marque cliente :
- Palette de couleurs → tokens CSS/Dart remplaçables
- Logo marque → zone dédiée en haut de l'écran
- Récompenses → configurables par marque
- L'ambiance "futuriste" est le thème par défaut, pas une contrainte permanente

---

## Dos & Don'ts

**Faire**
- Fond sombre en permanence — jamais de fond clair
- Or uniquement pour le jackpot
- Néons sur fond noir pour les moments forts (win, jackpot)
- Animations sobres pendant le vol, spectaculaires à l'atterrissage

**Ne pas faire**
- Mélanger or et cyan sur le même élément
- Effets pendant le vol de la bille (ça casse l'illusion)
- Texte blanc sur surface claire
- Plus de 2 couleurs d'accent sur le même écran

---

## Sessions design à venir

| Sujet | Priorité | Format |
|---|---|---|
| Visuel end game (overlay refonte) | Haute | Chat + screenshots → DESIGN.md |
| Écran d'intro | Basse | À cadrer |
| Thème marque template | Post-MVP | À cadrer |

---

*Dernière mise à jour : 2026-03-31 — Initialisation depuis les couleurs validées de render_docs.py + décisions sessions 1-9.*
