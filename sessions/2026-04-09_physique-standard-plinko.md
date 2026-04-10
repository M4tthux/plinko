# Session Physique Standard Plinko — 2026-04-09

## Objectif
Refaire la physique du Plinko selon les standards industrie (Matter.js, Stake, BGaming) au lieu de continuer à bricoler des valeurs. La bille traversait les picots et sortait du plateau.

## Contexte initial
- Build 31 (de ce matin) : bille passe au travers des picots, rebondit en dehors du plateau, sensation de bille "bloquée" qui rebondit 3-4 fois en 0.5s sur un picot
- Session PC précédente avait fait 7 builds (25-31) non-committés sur master, juste déployés directement sur gh-pages
- Code source désynchronisé de la prod

## Chronologie des actions

### 1. Resync source ← gh-pages (~15min)
- Découverte : 7 builds (25-31) déployés mais pas committés
- Reconstitué les changements depuis les messages de commit gh-pages :
  - slotCount 9→7, worldWidth 18→15, startRow 0, pegRadius 0.20, ballRestitution 0.10
- Appliqué au code source + CLAUDE.md + project-context.md + decisions-log.md
- Mis à jour Notion Game Design (9→7 cases)
- Commit : `Resync source ← gh-pages builds 25-31`

### 2. Premier fix orbite picot (NAIF — échec)
- Tenté d'augmenter `separationGap` (0.05→0.20) + `cooldownDuration` (5→15) + vitesse Y forcée à 1.0
- Feedback Matthieu : risque de saut visuel + rebond trop lourd
- Réduit gap à 0.10
- Commit builds 32

### 3. Mise en place CI/CD GitHub Action (~10min)
- Créé `.github/workflows/deploy-web.yml`
- Push master → build Flutter web → deploy gh-pages automatiquement
- Plus besoin du PC pour déployer
- Matthieu peut tester depuis Safari iPhone directement

### 4. Benchmark + refonte physique propre (~45min)
Lancé 2 agents Explore en parallèle :
- **Agent 1** : recherche web sur implémentations Plinko standard (Matter.js, Stake, BGaming)
- **Agent 2** : analyse complète du code physique actuel

Findings clés :
- Ratio bille:picot doit être ~1:1 (on avait 2:1)
- Restitution standard = 0.75 initialement (trop fort)
- Espacement picots = 2× diamètre bille (on avait 2.7×)
- Gravity 9.8 (on avait 15, trop haute)
- **Sub-stepping obligatoire** pour éviter le tunneling
- Pas de vitesse Y forcée (hack)
- Pas de cooldown (pansement sur un vrai bug)

**Build 33 — refonte physique complète** :
- Sub-stepping 4 sous-pas/frame (anti-tunneling)
- Ratio 1:1 : ballRadius 0.40→0.30, pegRadius 0.20→0.25
- Restitution 0.75/0.75 (standard Matter.js)
- Gravity 15→12
- Suppression cooldown picots
- Suppression vitesse Y forcée
- Séparation gap 0.10→0.02

### 5. Ajustement proportions (~5min)
Matthieu choisit l'option "comme les vrais" :
**Build 34 — proportions standard Plinko** :
- worldWidth 15→12 (gap libre = 2× diamètre bille)
- startRow 0→2 (commence à 3 picots comme les vrais)

### 6. Correction bords + rebonds (~5min)
Matthieu confirme : les vrais Plinko n'ont pas de bords + rebonds beaucoup plus amortis.
**Build 35** :
- Suppression murs latéraux (sortie = Perdu)
- Restitution 0.75→0.35 (amortie — la gravité domine)

### 7. Cases alignées sur picots du bas (~15min)
Screenshot Matthieu : bille visuellement dans le plateau mais marquée Perdu car les picots de row 9 débordaient de worldWidth.

Problème architectural : `pegGX = worldWidth / slotCount` fait que la grille triangulaire déborde quand `rows > slotCount + 1`.

**Build 36 — refonte géométrie** :
- `rows` 10→8 (last row = 8 picots → 7 gaps = 7 cases naturellement)
- `pegGX` découplé de slotCount, fixé à 1.70
- `worldWidth` calculé dynamiquement = `(rows-1) × pegGX + 2 × pegRadius` = 12.40
- `slotStartX` = pegX(rows-1, 0) = 0.25
- `slotEndX` = pegX(rows-1, rows-1) = 12.15
- Condition "Perdu" : bille hors `[slotStartX - r, slotEndX + r]`
- Plus de zone morte entre bord du plateau et picots

## Décisions finales
- **Pas de forçage** : distribution 100% statistique (binomiale)
- **Pas de parois** : sortie = Perdu (standard Plinko)
- **Rebonds amortis 0.35** : la gravité domine
- **Sub-stepping 4** : anti-tunneling propre, plus besoin de cooldown
- **pegGX fixe** : découplé de slotCount pour géométrie saine

## Fichiers modifiés
| Fichier | Changements |
|---|---|
| `plinko_app/lib/config/plinko_config.dart` | Refonte complète : rows, pegGX fixe, worldWidth calculé, slotStartX/EndX |
| `plinko_app/lib/game/ball.dart` | stepPhysics() pour sub-stepping, suppression murs, condition Perdu sur périmètre picots |
| `plinko_app/lib/game/plinko_game.dart` | Boucle sub-stepping (4 sous-pas), suppression cooldown et vitesse Y forcée |
| `plinko_app/lib/main.dart` | Build 32→33→34→35→36 |
| `.github/workflows/deploy-web.yml` | **Nouveau** : CI auto-deploy |
| `CLAUDE.md` | Config à jour + section CI/CD |
| `project-context.md` | Config + décisions actives + état d'avancement |
| `decisions-log.md` | 10 nouvelles entrées (builds 32-36 + CI + décisions physique) |
| Notion Game Design | 7 cases confirmées |

## État final
- **Build 36** déployé sur `m4tthux.github.io/plinko`
- Physique standard Plinko : sub-stepping, pas de bords, rebonds amortis, distribution statistique
- Cases parfaitement alignées sur les picots du bas (plus de zone morte)
- CI/CD opérationnel pour les prochaines sessions

## À valider visuellement (prochaine session)
- Physique globale : la bille descend naturellement sans rester bloquée
- Atterrissage : toutes les positions dans le périmètre des picots donnent une case
- Distribution : lancer plusieurs fois pour vérifier la courbe en cloche
- VFX build 33+ : trail, squash & stretch, glow picots, glow dynamique, particules d'impact

## Prochaine étape
- Validation visuelle build 36
- Si OK → Phase 2 benchmark VFX (flash case gagnante, screen shake, scale pulse picots)
- Si pas OK → ajuster `gravity`, `pegRestitution`, ou `pegGX`
