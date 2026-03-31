# PLINKO PROMOTIONNEL — Spécification Game Design
> 26 mars 2026 · v1.0 · Balleck Team

---

## 1. Vision

Un jeu promotionnel de type Plinko, **simple dans sa mécanique, irréprochable dans son exécution**.
Le joueur lance une bille qui rebondit sur des picots avant d'atterrir dans une case de récompense.
Le résultat est pré-déterminé, mais la trajectoire est physiquement crédible — l'illusion de hasard doit être totale.

**Le mot d'ordre : moins de features, plus de polish.**

---

## 2. Positionnement

| Dimension | Choix |
|---|---|
| **Complexité** | Simple — une seule mécanique, maîtrisée à fond |
| **Réalisme** | Élevé — physique crédible, rebonds naturels, pas d'aléatoire visible |
| **Ambiance par défaut** | Futuriste / arcade — néons, dark background, bille lumineuse |
| **Thémisation** | Oui — couleurs, logo, nom des récompenses configurables par marque |
| **Cible** | Toutes marques — B2B white-label, pas de restriction sectorielle |

---

## 3. Identité Visuelle de Base

### 3.1 Ambiance
L'esthétique par défaut s'inspire de l'arcade futuriste et du flipper électronique :
- **Fond sombre** — noir profond ou violet profond
- **Picots lumineux** — petits cylindres colorés qui s'illuminent au contact de la bille
- **Bille néon** — lumineuse, avec un léger halo/trail en mouvement
- **Cases en bas** — tubes ou gobelets avec néons colorés, labels en typographie arcade
- **Ambiance lumière** — bloom, reflets sur les bords du plateau, vignette sombre sur les côtés

### 3.2 Référence principale
> Image 1 partagée en session : plateau sombre, picots colorés lumineux, bille cyan néon, cases multiplieurs avec gobelets, éclairage néon violet/rose sur les bords.

### 3.3 Ce qu'on évite
- Visuel "bonbon" ou too-colorful (cf. Image 2 — trop festif, manque de tension)
- Rebonds cartoonesques ou exagérés
- Particules ou effets qui cassent l'illusion de réalisme physique

---

## 4. Mécanique de Jeu

### 4.1 Flow complet

```
1. ARRIVÉE
   └── Ecran d'intro / loading (pendant que les 100 trajectoires se simulent)
   └── Durée : < 1 seconde perçue

2. VISÉE
   └── Joueur glisse le doigt horizontalement pour choisir le point de lancement
   └── Indicateur visuel subtil de la position (pas de trajectoire prévisionnelle)
   └── La bille attend en haut du plateau

3. LANCER
   └── Joueur relâche le doigt
   └── La bille tombe en suivant la trajectoire pré-calculée
   └── Rebonds sur les picots — physique réaliste, fluide

4. DESCENTE
   └── La caméra suit la bille vers le bas (révélation progressive du plateau)
   └── Suspense maintenu — on ne voit pas encore les cases
   └── Son de chaque rebond, crescendo à l'approche des cases

5. ARRIVÉE EN CASE
   └── La bille entre dans la case gagnante
   └── Animation de révélation de la récompense
   └── Son + haptique de victoire

6. RÉSULTAT
   └── Affichage de la récompense avec animation
   └── CTA selon contexte marque (récupérer, continuer, partager...)
```

### 4.2 L'illusion de hasard

Le joueur **ne sait pas** que le résultat est pré-déterminé.
Tout doit renforcer la perception d'une physique authentique :
- La trajectoire choisie correspond à son point de lancement réel (proximité maximale)
- Les rebonds sont naturels — pas de corrections visibles, pas de bille qui "hésite"
- La bille ne dévie pas brusquement à la fin pour aller dans la bonne case
- L'écart entre point de lancer simulé et point réel est de quelques pixels — imperceptible

**Principe clé : la trajectoire pré-calculée doit être indiscernable d'une trajectoire physique réelle.**

### 4.3 Suspense

Le suspense repose sur un seul mécanisme, mais radical : **le joueur ne voit pas les cases quand il lance**.

Le plateau est suffisamment long pour que les récompenses soient hors cadre au moment du lâcher. La caméra suit la bille vers le bas, révélant progressivement le plateau. C'est le scroll qui crée la tension — rien d'artificiel.

Renforcé par le son : crescendo des rebonds à l'approche des cases, impact à l'atterrissage.

Pas de ralenti, pas d'effet "presque", pas d'indicateur de visée. Le réalisme *est* le suspense.

---

## 5. Plateau

| Élément | Spec |
|---|---|
| **Picots** | Disposition en quinconce, positions fixes, physique réaliste |
| **Nombre de cases** | 9 par défaut |
| **Labels des cases** | Configurables par marque (récompenses, multiplicateurs, texte libre) |
| **Plateau** | Dimensions fixes pour le MVP — configurable post-MVP |

### 5.1 Hauteur du plateau — décision clé

Le plateau est **volontairement long** : au moment où le joueur relâche la bille, les cases de récompense ne sont **pas visibles à l'écran**.

C'est le cœur du dispositif de suspense :
- Le joueur voit uniquement la zone de lancement et les premiers picots
- La caméra suit la bille vers le bas au fur et à mesure de sa descente
- Les cases apparaissent progressivement dans le bas du champ de vision
- Le joueur ne sait pas où il va atterrir jusqu'aux derniers rebonds

**Aucun indicateur de visée n'est affiché** — le joueur glisse le doigt pour choisir son point de lancement horizontal, relâche, et découvre la trajectoire en temps réel avec la caméra.

---

## 6. Système de Thémisation (Post-MVP)

La marque cliente peut personnaliser :
- Couleurs principales (fond, picots, bille, cases)
- Logo affiché sur l'écran d'intro et/ou résultat
- Nom et visuel des récompenses
- Typographie (dans une liste de polices compatibles)

**Pour le MVP :** thème unique "futuriste néon" codé en dur. La structure du code anticipe la thémisation mais ne l'implémente pas.

---

## 7. Audio

| Moment | Son |
|---|---|
| Lancer | Whoosh léger |
| Rebond sur picot | Clic/tink court, pitch variable selon la force |
| Descente finale | Crescendo de tension |
| Atterrissage en case | Impact + accord de victoire |
| Révélation récompense | Fanfare courte, adaptée à la valeur de la récompense |

**Feedback haptique :** vibration courte à chaque rebond, vibration longue à l'atterrissage.

---

## 8. Ce que ce jeu n'est PAS

- Pas un jeu de casino — pas de mise, pas d'argent réel
- Pas un jeu à mécaniques multiples — une seule action, un seul résultat
- Pas un jeu de hasard réel — le résultat est toujours maîtrisé côté opérateur
- Pas un gadget — l'expérience doit être suffisamment soignée pour surprendre positivement

---

## 9. Décisions complémentaires

| Question | Décision |
|---|---|
| Trajectoire prévisionnelle pendant la visée ? | 🟡 En discussion — voir question ouverte §10 |
| Retry ou one-shot ? | ✅ One-shot — une seule partie par session promotionnelle. |
| Musique d'ambiance ? | ❌ Pas pour le MVP — effets sonores uniquement. La musique est déprioritisée. |

## 10. Questions Ouvertes

| Question | Priorité |
|---|---|
| **Trajectoire prévisionnelle pendant la visée ?** Afficher un indicateur de là où la bille va partir (pas la trajectoire complète, juste le point de lancement) ou garder le lancer totalement à l'aveugle ? Impact sur l'illusion vs guidage du joueur. | 🔴 À arbitrer avant Dev Session 3 |
| **Architecture des trajectoires** | ✅ Hybride pré-calculé offline — 90 trajectoires (9×5×2). Voir `specs/tech-architecture.md` §3 |
| Écran d'intro : animation de la bille ou simple logo marque ? | 🟢 Basse priorité |

---

*Dernière mise à jour : 2026-03-26 — Session Game Design v1*
