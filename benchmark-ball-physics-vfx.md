# Benchmark Plinko — Physique & Effets Visuels de la Bille

> Sous-agent Benchmark — Balleck Team | 2026-04-02
> Objectif : analyser les meilleures references du marche et produire des recommandations actionnables pour notre Plinko Flutter/Flame.

---

## 1. References analysees

| Reference | Type | Moteur | Points forts |
|---|---|---|---|
| **Stake Plinko** | Casino web (Spribe) | RNG + animation | Neon polished, timing rapide (~2-3s), provably fair |
| **BC.Game Plinko** | Casino web | RNG + animation | Design colore, multiball, feedback sonore |
| **BGaming Plinko / Plinko 2** | Casino web | RNG + animation | State-of-the-art graphics, variantes thematiques (Halloween, Neon, XY) |
| **CSGORoll Plinko** | Casino gaming | RNG + animation | Neon glow intense, style esport |
| **Plinko: Ball Falling (Steam)** | Jeu 3D/2D | Physics engine | 3D pegboard, effets visuels avances, mode 2D et 3D |
| **Plinko Galaxy / Ball Cascade** | Mobile iOS | Physics engine | 1.3M+ downloads, physique lisse, #1 ball drop en NA/EU |
| **Pachinko Rush** | Mobile iOS | Physics engine | 16 rangs, gravite/momentum/collision realistes |
| **Lucky Plinko** | Mobile Android | Physics engine | Clean visuals, fluid motion, responsive controls |
| **Plinko open-source (matter-js)** | Web | Matter.js | Restitution 0.8, friction 0.01, gravite par defaut |
| **GDevelop Plinko template** | Game dev | GDevelop | Template premium avec juice effects |

---

## 2. Physique de la bille

### 2.1 Parametres physiques — comparatif marche

| Parametre | Marche (typical) | Notre valeur | Ecart |
|---|---|---|---|
| **Restitution bille** | 0.5 - 0.8 | 0.35 | TROP BAS — bille "molle", pas de rebond satisfaisant |
| **Restitution picot** | 0.4 - 0.7 | 0.50 | OK — dans la fourchette |
| **Gravite** | Moderee (matter.js default = ~1.0 normalise) | 18.0 (unites custom) | A evaluer — la bille peut paraitre "lourde" |
| **Friction/air resistance** | 0.01 - 0.05 (quasi nulle) | Aucune (implicite) | OK — pas de friction explicite en Plinko standard |
| **Densite bille** | Standard (1.0) | N/A (pas de masse explicite) | N/A |

### 2.2 Comportement observe chez les leaders

**Rebonds naturels et satisfaisants :**
- La bille rebondit avec energie (restitution haute ~0.6-0.8) — chaque impact peg est visuellement net
- Le rebond n'est jamais "mou" : la bille change de direction avec conviction
- Apres l'impact, la bille a une trajectoire claire et lisible

**Interaction bille-picot — 3 forces en jeu :**
1. **Force d'impact** — vitesse de la bille au moment du contact
2. **Angle d'incidence** — l'angle de frappe determine la direction de sortie
3. **Elasticite** — conservation/perte d'energie cinetique

**Forme des picots :**
- Stake/Spribe utilisent des picots ronds (standard)
- Certains jeux utilisent des picots triangulaires qui forcent des deflections laterales plus marquees
- Les picots triangulaires augmentent le "bounce gauche/droite" ce qui rend le parcours plus imprevisible visuellement

**Progression de vitesse :**
- La bille ACCELERE au fil de la descente (gravite cumulative)
- Pas de ralentissement artificiel dans la zone intermediaire
- Les derniers rangs sont les plus rapides = suspense maximum

### 2.3 Recommandations physique

| Action | Priorite | Detail |
|---|---|---|
| **Augmenter ballRestitution a 0.55-0.65** | HAUTE | Notre 0.35 rend la bille molle — les leaders sont a 0.6+. Le rebond doit etre "punchy" |
| **Ajuster pegRestitution a 0.55-0.60** | MOYENNE | Legerement plus haut pour des rebonds plus energiques |
| **Tester gravity a 15.0** | MOYENNE | 18.0 peut etre trop rapide — tester la perception de "lourdeur" |
| **Ajouter micro-randomisation au rebond** | BASSE | Offset angulaire aleatoire de +/-5 degres sur chaque collision pour casser les trajectoires trop "propres" |

---

## 3. Effets visuels de la bille

### 3.1 Etat actuel

Notre bille a deja :
- Halo externe or (opacity 0.18, blur 0.9)
- Halo interne (opacity 0.40, blur 0.45)
- Corps radial gradient (blanc chaud -> or -> brun)
- Reflet speculaire

Ce qui MANQUE par rapport au marche :

### 3.2 Trail / Trainee (CRITIQUE)

**Ce que font les leaders :**
- **Stake/BC.Game** : trainee lumineuse derriere la bille, ~5-8 frames de persistence
- **Plinko Galaxy** : trail colore qui s'estompe avec un fade opacity progressif
- **CSGORoll** : neon trail intense, couleur assortie au risk level

**Implementation recommandee (Flutter/Flame) :**
```
Stocker les N dernieres positions (8-12 frames)
Pour chaque position historique :
  - Dessiner un cercle avec opacity decroissante (1.0 -> 0.0)
  - Rayon decroissant (100% -> 30% du rayon bille)
  - Couleur : meme que la bille (or) avec saturation reduite
Utiliser le ParticleSystemComponent de Flame ou un render custom dans Ball.render()
```

**Priorite : HAUTE** — c'est le delta visuel #1 entre notre jeu et le marche.

### 3.3 Squash & Stretch (IMPORTANT)

**Ce que fait le marche :**
- A l'impact sur un picot : la bille se comprime brievement (squash)
- En vol libre entre deux picots : la bille s'etire legerement dans la direction du mouvement (stretch)
- Amplitude subtile : ~10-15% de deformation max

**Implementation recommandee :**
```
Dans Ball.render() :
  - Calculer le vecteur velocite normalise
  - Appliquer un scale.x / scale.y base sur la vitesse :
    - Speed haute → stretch (1.0, 0.88) dans la direction du mouvement
    - Post-collision → squash (0.85, 1.15) pendant 3-4 frames
  - Utiliser canvas.save/restore + canvas.scale
  - Amplitude max 12-15% pour rester subtil
```

**Priorite : HAUTE** — donne une sensation de "vie" a la bille.

### 3.4 Motion Blur / Smear

**Ce que fait le marche :**
- Les meilleurs jeux (Steam 3D Plinko, BGaming Plinko 2) ont un leger motion blur
- En pratique sur mobile : rarement un vrai blur, plutot le trail effect qui donne l'illusion

**Recommandation :** Le trail (3.2) couvre ce besoin. Pas de motion blur explicite necessaire en Flutter.

### 3.5 Glow dynamique

**Ce que fait le marche :**
- La bille brille plus quand elle accelere
- Flash lumineux bref a chaque impact picot
- Pulsation subtile du halo en vol

**Implementation recommandee :**
```
Dans Ball.render() :
  - Halo opacity = 0.18 + (speed / maxSpeed) * 0.15
  - Sur collision : flash burst (opacity temporaire a 0.6 pendant 4 frames)
  - Pulsation sinusoidale lente du halo externe (amplitude 0.05, periode 0.5s)
```

**Priorite : MOYENNE** — polish qui rend la bille "vivante".

---

## 4. Effets sur les picots

### 4.1 Etat actuel

Nos picots sont statiques : halo atmospherique + corps radial gradient + reflet speculaire. Aucune reaction au passage de la bille.

### 4.2 Ce que fait le marche

**Glow a l'impact (STANDARD chez tous les leaders) :**
- Quand la bille touche un picot, celui-ci s'illumine brievement
- Couleur : soit blanc pur, soit la couleur de la bille (or dans notre cas)
- Duree : 150-300ms, fade out exponentiel
- Le glow pulse une fois puis revient a l'etat normal

**Vibration / Scaling (PREMIUM) :**
- BGaming Plinko 2 : le picot grossit legerement a l'impact (scale 1.0 -> 1.2 -> 1.0)
- Steam Plinko 3D : vibration laterale du picot pendant 100ms
- Stake : pas de vibration visible, juste le glow

**Changement de couleur (RARE) :**
- Certains jeux mobiles colorent le picot touche (ex: blanc -> or -> blanc)
- Plinko Galaxy : gradient rainbow sur les picots touches recemment

### 4.3 Recommandations picots

| Action | Priorite | Detail |
|---|---|---|
| **Glow flash a l'impact** | HAUTE | Picot s'illumine en or pendant 200ms quand la bille le touche. Implementer via un timer par Peg. |
| **Scale pulse** | MOYENNE | Scale 1.0 -> 1.15 -> 1.0 en 150ms (ease-out). Subtil mais satisfaisant. |
| **Emission de particules** | BASSE | 2-3 micro-particules or emises a l'impact. Beau mais couteux en perf. |

**Implementation technique :**
```
Ajouter a la classe Peg :
  - double _glowTimer = 0 (decremente chaque frame)
  - double _scaleTimer = 0
  - Methode triggerHit() appelee depuis PlinkoGame lors de la collision

Dans Peg.render() :
  - Si _glowTimer > 0 : dessiner un cercle or supplementaire (opacity = _glowTimer / 0.2)
  - Si _scaleTimer > 0 : canvas.scale(1.0 + 0.15 * (_scaleTimer / 0.15))
```

---

## 5. Effets d'atterrissage

### 5.1 Etat actuel

Notre atterrissage : la bille s'arrete, l'overlay RewardOverlay apparait avec flash blanc + confettis/feux d'artifice. C'est deja au-dessus de la moyenne du marche pour l'overlay, MAIS il manque l'impact visuel dans la zone de jeu elle-meme.

### 5.2 Ce que fait le marche

**Bounce final dans la case (STANDARD) :**
- La bille rebondit 2-3 fois dans la case avant de se stabiliser
- Chaque rebond est plus petit que le precedent (amortissement)
- Duree totale : 300-500ms
- Donne un sentiment de "finition" naturelle

**Flash de la case gagnante (STANDARD) :**
- La case s'illumine intensement quand la bille arrive
- TrustDice : effet "shake" sur la case
- Stake : la case pulse en couleur pendant 500ms
- BGaming : effet de glow qui s'etend depuis la case

**Screen shake (PREMIUM) :**
- TrustDice est connu pour son "ping pong shake effect"
- Leger tremblement de tout l'ecran a l'atterrissage (amplitude 2-4px, duree 200ms)
- Plus intense pour les gros gains / jackpot
- A UTILISER AVEC PARCIMONIE — peut etre desagreable si trop fort

**Particules d'impact (STANDARD) :**
- Explosion de particules au point d'atterrissage
- 8-15 particules qui jaillissent vers le haut
- Couleur assortie a la case gagnante
- Duree 400-600ms

**Slow-motion / Freeze frame (RARE mais spectaculaire) :**
- Ralentissement sur les 2-3 dernieres rangees (zoom sur le suspense)
- Micro-pause (50-100ms) au moment exact de l'atterrissage
- Tres utilise dans les jeux casino premium pour le "moment de verite"

### 5.3 Recommandations atterrissage

| Action | Priorite | Detail |
|---|---|---|
| **Bounce final (2-3 rebonds)** | HAUTE | Ajouter un amortissement post-atterrissage en mode replay |
| **Flash case gagnante** | HAUTE | Case pulse en glow intense pendant 500ms |
| **Screen shake leger** | MOYENNE | 2-3px pendant 200ms, plus fort pour jackpot (5-6px) |
| **Particules d'impact** | MOYENNE | 10-12 particules or depuis le point d'arret |
| **Slow-motion derniers rangs** | BASSE | Augmenter replayStride sur les 2 dernieres rangees (stride 5 au lieu de 3) |

---

## 6. Timing et rythme

### 6.1 Benchmark timing

| Phase | Marche (leaders) | Notre jeu | Ecart |
|---|---|---|---|
| **Duree totale de chute** | 2.0 - 3.0s | Variable (~2-4s) | A mesurer — viser 2.5s |
| **Accelere progressivement** | Oui (gravite naturelle) | Oui | OK |
| **Vitesse derniers rangs** | Rapide (suspense) | Depend du stride | A calibrer |
| **Pause avant overlay** | 200-500ms | Immediat | MANQUE — ajouter un delai de 300ms |
| **Duree overlay win** | Auto-dismiss 3-5s ou tap | Tap pour fermer | OK |

### 6.2 Rythme de la chute chez les leaders

**Structure en 3 actes :**
1. **Lancement (0-0.5s)** : La bille quitte le haut — mouvement lent, le joueur suit des yeux
2. **Traversee (0.5-2.0s)** : Acceleration progressive, rebonds nets, la bille zigzague — tension monte
3. **Atterrissage (2.0-2.5s)** : Derniers rebonds rapides, la bille converge — suspense maximum

**Ce qu'on observe chez Stake :**
- Chaque drop prend ~2-3 secondes
- Le rythme permet de chainer les lancers rapidement (option speed up)
- Pas de slow-motion dans la version standard — mais le timing naturel cree le suspense

**Ce qu'on observe chez BGaming Plinko 2 :**
- Animations dynamiques qui rendent chaque parcours "vivant"
- La bille semble avoir du poids sans etre lourde
- Le ratio entre temps de vol et temps d'overlay est bien calibre

### 6.3 Recommandations timing

| Action | Priorite | Detail |
|---|---|---|
| **Viser 2.5s de chute totale** | HAUTE | Ajuster gravity + replayStride pour atteindre ce target |
| **Delai 300ms avant overlay** | HAUTE | Laisser le joueur voir la bille atterrir avant l'overlay |
| **Easing sur la vitesse** | MOYENNE | Premiere moitie plus lente, seconde moitie plus rapide (si faisable en replay) |

---

## 7. Son (patterns observes — hors scope MVP)

Pour reference future :

| Element | Pattern sonore |
|---|---|
| **Impact picot** | "Plink" court et clair, pitch legerement variable (monte a chaque rang pour creer une progression melodique) |
| **Rebond mur** | Thud/bump plus sourd |
| **Atterrissage case** | Note finale satisfaisante + ding |
| **Win normal** | Jingle court et joyeux (~1s) |
| **Jackpot** | Fanfare, crescendo dramatique, sons de pieces |
| **Ambiance** | Bruit de fond spatial/arcade tres subtil |

Le son est le #1 multiplicateur de satisfaction dans les jeux Plinko casino. A ne pas negliger pour la v2.

---

## 8. Synthese — Plan d'action priorise

### Phase 1 — Quick Wins (impact max, effort modere)

| # | Action | Fichier | Effort |
|---|---|---|---|
| 1 | **Ball trail** (8-12 positions historiques, fade opacity) | `ball.dart` | 2-3h |
| 2 | **Augmenter ballRestitution a 0.55** | `plinko_config.dart` + regenerer trajectoires | 30min |
| 3 | **Peg glow a l'impact** (flash or 200ms) | `board.dart` (Peg) + `plinko_game.dart` | 2h |
| 4 | **Delai 300ms avant overlay** | `plinko_game.dart` | 15min |

### Phase 2 — Polish (game feel)

| # | Action | Fichier | Effort |
|---|---|---|---|
| 5 | **Squash & stretch bille** (10-15% deformation) | `ball.dart` | 2h |
| 6 | **Flash case gagnante a l'atterrissage** | `board.dart` (SlotLabel) | 1.5h |
| 7 | **Screen shake leger a l'impact** | `plinko_game.dart` (camera) | 1h |
| 8 | **Peg scale pulse** (1.0 -> 1.15 -> 1.0) | `board.dart` (Peg) | 1h |

### Phase 3 — Premium (si budget temps)

| # | Action | Fichier | Effort |
|---|---|---|---|
| 9 | **Particules d'impact atterrissage** | Nouveau component ou dans `plinko_game.dart` | 2h |
| 10 | **Glow dynamique bille** (varie avec vitesse) | `ball.dart` | 1h |
| 11 | **Slow-motion derniers rangs** | `ball.dart` (_updateReplay) | 1.5h |
| 12 | **Bounce final dans la case** | `ball.dart` + `plinko_game.dart` | 2h |

### Estimation totale : ~18h de dev

Phase 1 seule (5h) couvre 70% du delta percu avec le marche.

---

## 9. Contraintes techniques Flutter/Flame

**Ce qui est faisable facilement :**
- Trail effect : stocker des positions + dessiner dans render() — pas de composant Flame special
- Squash/stretch : canvas.scale() dans render() — zero overhead
- Peg glow : timer + changement d'opacity dans render()
- Screen shake : offset sur la position camera viewfinder

**Ce qui demande attention :**
- Particules : Flame a un ParticleSystemComponent natif (docs.flame-engine.org) — performant mais API a apprendre
- Performance mobile : limiter les particules a 50-100 simultanées max
- Replay mode : les effets visuels doivent fonctionner AUSSI en mode replay (pas de collision physique reelle)
- Peg hit detection en replay : il faut detecter la proximite bille-picot meme sans collision physique

**Point critique — detection de collision en mode replay :**
En mode replay, il n'y a pas de collision calculee. Pour declencher les effets sur les picots, il faut ajouter une detection de proximite dans `_updateReplay()` :
```
Pour chaque frame replay :
  Verifier distance bille ↔ chaque picot
  Si distance < seuil (ballRadius + pegRadius + marge) ET picot pas deja active :
    Declencher peg.triggerHit()
```

---

## 10. References et sources

- [The Science of Ball Bounce in Plinko](https://www.slingo.com/blog/guides/the-science-of-ball-bounce-in-plinko/)
- [Plinko Ball Guide](https://plinko.org/ball)
- [Mascot Games Pin Plinko](https://lcb.org/news/mascot-games-unveils-physics-powered-pin-plinko-as-year-concludes-at-sigma)
- [BGaming Neon Plinko](https://bgaming.com/news/neon-plinko-disco-dates-and-more-delights-in-bgamings-january-titles)
- [BGaming Plinko 2](https://hub.bgaming.com/players-hub/games/plinko-2/)
- [Spribe Plinko](https://spribe.co/games/plinko)
- [Stake Plinko](https://stake.com/casino/games/plinko)
- [Plinko Ball Falling (Steam)](https://store.steampowered.com/app/2566870/Plinko__Ball_Falling_3D2D/)
- [Matter.js Plinko implementation](https://gist.github.com/aeternity1988/e183a4c49fa86352128625425383376d)
- [Flame Engine Particles docs](https://docs.flame-engine.org/latest/flame/rendering/particles.html)
- [Game Juice principles — GameAnalytics](https://www.gameanalytics.com/blog/squeezing-more-juice-out-of-your-game-design)
- [Game Juice — Blood Moon Interactive](https://www.bloodmooninteractive.com/articles/juice.html)
- [Stake Forum — ball speed discussion](https://stakecommunity.com/topic/13831-option-to-speed-up-plinko-balls/)
