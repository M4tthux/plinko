# PLINKO PROMOTIONNEL — Spécification Technique & Architecture — MVP
> 19 mars 2026 · v1.0 · Confidentiel

---

# 1. Contexte & Périmètre MVP

Ce document définit les choix techniques retenus pour le MVP du jeu Plinko promotionnel. L'objectif du MVP est simple : pouvoir jouer au jeu sur un vrai téléphone (iOS ou Android) depuis Xcode / Android Studio, avec une physique réaliste et une mécanique de trajectoire pré-calculée fonctionnelle.

**Ce que le MVP inclut :**
- Physique réaliste — gravité, rebonds sur picots, friction
- Simulation de 100 trajectoires en arrière-plan → sélection de la trajectoire cible
- Interaction : glisser le doigt pour viser, relâcher pour lancer
- Caméra qui suit la bille (révélation progressive du plateau)
- 9 cases de récompenses configurables en bas
- Son + feedback haptique

**Ce que le MVP n'inclut pas :**
- Deeplink ou déclenchement externe — post-MVP
- Token signé / backend — post-MVP
- SDK embarqué dans l'app d'une marque cliente — post-MVP
- Personnalisation marque (thème, couleurs, logo) — post-MVP

---

# 2. Moteur Physique — Flame + Forge2D

## 2.1 Décision
Le moteur physique retenu est **Flame + Forge2D**. Flame est le game framework Flutter standard (game loop, caméra, rendu), et Forge2D est le port Flutter de Box2D — la référence de la physique 2D réaliste (gravité, rebonds, restitution, friction).

## 2.2 Pourquoi ce choix
- Forge2D implémente Box2D : physique éprouvée, résultats prévisibles et reproductibles
- La simulation headless (sans rendu) est native : on instancie un World Forge2D séparé, on tick à vitesse maximale, on lit les positions — aucun affichage requis
- Flame gère la caméra follow nativement (CameraComponent + FollowBehavior)
- Compatible iOS + Android, maintenu activement, bonne documentation

## 2.3 Packages Flutter

| Composant | Responsabilité | Package |
|---|---|---|
| **flame** | Game loop, rendu, caméra | `flame ^1.x` |
| **forge2d** | Moteur physique Box2D | `flame_forge2d ^0.x` |
| **audioplayers** | Sons (bille, récompense) | `audioplayers ^6.x` |
| **flutter_haptic_feedback** | Feedback haptique | `haptic_feedback ^0.x` |

---

# 3. Trajectoires — Architecture Hybride Pré-calculée

## 3.1 Principe

Le lot (récompense) est déterminé AVANT que le joueur ne joue.
Le frontend doit garantir que la bille atterrit dans la bonne case — sans que la physique soit truquée de façon visible.

**Décision d'architecture : trajectoires pré-calculées offline.**

Les trajectoires sont générées une seule fois par un script offline (hors app), stockées dans un fichier JSON, et chargées au démarrage de l'app. Au moment du lancer, le runtime fait une simple lecture mémoire — zéro calcul, zéro lag, garanti sur tout téléphone.

## 3.2 Structure des trajectoires

La largeur du plateau est découpée en **5 zones de lancement** :

```
|  Zone 1  |  Zone 2  |  Zone 3  |  Zone 4  |  Zone 5  |
   Gauche    C-Gauche   Centre    C-Droite    Droite
```

Pour chaque combinaison **case cible × zone de lancement**, on stocke **2 trajectoires valides** :

```
9 cases  ×  5 zones  ×  2 trajectoires  =  90 trajectoires
```

Chaque trajectoire = liste de positions (x, y) frame par frame + point de lancement X exact.

## 3.3 Script de génération offline

Un script Dart/Flutter standalone (`scripts/generate_trajectories.dart`) :

1. Instancie un World Forge2D identique au plateau réel (mêmes picots, mêmes dimensions)
2. Pour chaque case cible (1–9) et chaque zone (1–5), lance N simulations avec des X de départ couvrant la zone
3. Collecte les trajectoires valides (atterrit dans la bonne case)
4. Retient les 2 meilleures par combinaison (critère : trajectoire la plus naturelle visuellement)
5. Exporte le tout dans `assets/trajectories.json`

Ce script est rejoué uniquement si la configuration du plateau change (dimensions, positions des picots, nombre de cases).

## 3.4 Sélection au runtime

Quand le joueur relâche le doigt :

1. **Détecter la zone** — position X du doigt → zone 1 à 5
2. **Lire les trajectoires** — charger les 2 options pour (case cible, zone)
3. **Sélectionner** — choisir aléatoirement parmi les 2 options (variété minimale)
4. **Lancer** — la bille part du X exact de la trajectoire sélectionnée (écart de quelques pixels avec le doigt — imperceptible)
5. **Rejouer** — la bille suit la trajectoire frame par frame

## 3.5 Pourquoi cette approche

| Critère | Simulation temps réel | Hybride pré-calculé ✅ |
|---|---|---|
| **Performance** | < 500ms (risque sur téléphones lents) | Instantané — lecture fichier |
| **Fiabilité** | Dépend du device | Garanti sur tout device |
| **Réalisme** | Trajectoires Forge2D réelles | Trajectoires Forge2D réelles |
| **Illusion** | Très bonne (proximité doigt) | Très bonne (proximité zone) |
| **Complexité runtime** | Élevée (Isolate, World Forge2D) | Minimale (lecture JSON) |
| **Variété** | Infinie | 2 par combinaison (suffisant one-shot) |

Pour un jeu **one-shot promotionnel**, la variété infinie n'apporte rien. La fiabilité et la performance priment.

---

# 4. Structure du Code Flutter

## 4.1 Arborescence

```
plinko_app/
├── main.dart                     # Entry point
├── config/
│   └── plinko_config.dart        # Lots + config plateau (codés en dur MVP)
├── models/
│   ├── lot.dart                  # Modèle Lot (id, label, type, caseIndex…)
│   └── trajectory.dart           # Modèle Trajectory (zone, caseIndex, frames)
├── data/
│   └── trajectory_loader.dart    # Charge assets/trajectories.json au démarrage
├── game/
│   ├── plinko_game.dart          # Flame GameWidget principal
│   ├── board.dart                # Plateau : picots, cases, dimensions
│   ├── ball.dart                 # Bille : replay trajectoire frame par frame
│   ├── camera_controller.dart    # Caméra follow bille
│   └── reward_overlay.dart       # Révélation de la récompense
├── ui/
│   ├── launch_screen.dart        # Glisser + relâcher → détecte zone de lancement
│   └── result_screen.dart        # Écran résultat final
├── services/
│   └── haptics_audio.dart        # Sons + haptique
└── assets/
    └── trajectories.json         # 90 trajectoires pré-calculées (généré offline)

scripts/
└── generate_trajectories.dart    # Script offline — génère trajectories.json
```

## 4.2 Responsabilités clés

| Composant | Responsabilité | Package |
|---|---|---|
| **plinko_config.dart** | Config des lots, probabilités, cases — modifiable sans toucher au code jeu | – |
| **trajectory_loader.dart** | Charge `trajectories.json` au démarrage → sélectionne la trajectoire selon zone + case cible | – |
| **generate_trajectories.dart** | Script offline — simule et stocke les 90 trajectoires avec Forge2D | forge2d |
| **plinko_game.dart** | Orchestre le jeu : reçoit la trajectoire sélectionnée, rejoue la bille frame par frame | flame |
| **board.dart** | Définit picots (positions fixes), cases (labels, couleurs), dimensions du plateau | flame_forge2d |
| **camera_controller.dart** | Suit la bille en Y, avec lerp pour fluidité — plateau révélé progressivement | flame |
| **reward_overlay.dart** | Animation de révélation récompense au moment de l'arrivée dans la case | flutter |

---

# 5. Déclenchement — MVP vs Cible

## 5.1 MVP : lancement depuis l'IDE
Pour le MVP, aucun système de déclenchement externe n'est nécessaire. La configuration du jeu (lots, case cible, thème) est codée directement dans `plinko_config.dart`. On compile et on lance depuis Xcode (iOS) ou Android Studio (Android).

**Pour tester différents scénarios :**
- Changer la `caseIndex` dans `plinko_config.dart` → relancer
- Changer les lots → relancer
- Hot reload Flutter pour ajustements visuels

## 5.2 Post-MVP : Deeplink + App Standalone
Une fois le MVP validé, le déclenchement se fera via un deeplink universel :

```
plinko://play?token=BASE64_JSON
```

Le token contiendra la configuration de la session (lot attribué, case cible, brandId). L'app intercepte le deeplink au démarrage via `uni_links` et charge la config dynamiquement.

## 5.3 Cible finale : SDK embarqué
La version finale s'intégrera comme un module dans l'app Flutter de la marque cliente. Le Plinko sera déclenché par un appel de fonction depuis l'app parente, sans deeplink.

---

# 6. Récapitulatif des Décisions

| Sujet | Décision | Statut |
|---|---|---|
| **Framework** | Flutter (iOS + Android) | ✅ MVP |
| **Moteur physique** | Flame + Forge2D (port Box2D) | ✅ MVP |
| **Architecture trajectoires** | Hybride pré-calculé offline — 90 trajectoires (9×5×2) stockées en JSON | ✅ MVP |
| **Sélection trajectoire** | Détection zone du doigt → lecture trajectoire en mémoire → replay frame par frame | ✅ MVP |
| **Config MVP** | Codée en dur dans plinko_config.dart | ✅ MVP |
| **Lancement MVP** | Depuis Xcode / Android Studio directement | ✅ MVP |
| **Deeplink** | `plinko://play?token=…` (Base64 JSON) | 🔜 Post-MVP |
| **Token signé** | JWT ou signature HMAC côté backend | 🔜 Post-MVP |
| **SDK marque** | Module Flutter embarqué dans l'app cliente | 🔜 Post-MVP |
| **Personnalisation** | Thème, couleurs, logo marque dynamiques | 🔜 Post-MVP |

---

# 7. Questions Ouvertes (Post-MVP)

- Comment la récompense est-elle transmise à la marque après la partie ? (webhook, API ?)
- Format exact du token signé entre backend et frontend (JWT ? HMAC ? durée de validité ?)
- Combien de marques simultanées ? Impact sur l'architecture multi-tenant
- Le plateau est-il configurable par marque (nombre de picots, dimensions) ou toujours identique ?
- Afficher une trajectoire prévisionnelle pendant que le joueur vise, ou garder mystérieux ?
- Stratégie de distribution : App Store distinct par marque (white-label) ou app générique Plinko ?

---

# 8. Prochaines Étapes

**Dev Session 1 — Socle physique**
- Créer le projet Flutter + ajouter Flame & Forge2D
- Implémenter le plateau (picots + cases) et la bille avec physique réelle
- Valider que la bille rebondit de façon réaliste

**Dev Session 2 — Trajectoires pré-calculées**
- Implémenter `generate_trajectories.dart` (script offline Forge2D)
- Générer `assets/trajectories.json` (90 trajectoires)
- Implémenter `trajectory_loader.dart` + sélection par zone
- Valider que la bille atterrit dans la case cible

**Dev Session 3 — UX & polish**
- Caméra follow, interaction glisser + relâcher
- Overlay de récompense, son, haptique
- Test sur vrai device iOS + Android
