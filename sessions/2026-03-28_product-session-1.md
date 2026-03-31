# Session Product — 2026-03-28 (Session 8b)

## Ce qui a été fait

Backlog grooming + discussions sur 7 sujets identifiés par Matthieu en fin de session dev.

**7 tâches créées sur la board Notion :**
- Physique bille — sentiment de lourdeur / gravité (Backlog / Game Design)
- Règle jackpot — un seul jackpot par plateau (Backlog / Game Design / Haute)
- Écran de résultat — émotion win / lose (Backlog / Design / Haute)
- Build iOS — tester sur device physique (Backlog / Dev)
- Design cases bas — refonte visuelle + affichage récompense (Backlog / Design / Haute)
- Bandes de lancement — afficher les 5 zones en haut (Backlog / Dev)
- Intro du jeu — animation d'ouverture (Backlog / Design)

## Décisions prises

- Jackpot = slot central uniquement, hardcodé — pas de jackpot multiple possible
- Intro = max 3 secondes, skippable — direction à confirmer (bille de démo vs logo marque)
- iOS : nécessite Mac + Xcode, pas de contournement sans. CI cloud (Codemagic) si pas de Mac.
- Bandes lancement = remplacement du LaunchZoneOverlay DEBUG existant (Z0–Z4)

## Questions ouvertes

- Lourdeur bille : chute trop lente ou rebonds trop élastiques ? → cadrer avant de toucher la gravity
- Émotion win/lose : direction sobre vs spectaculaire ? → montrer des références avant de dev
- Intro : one-shot (première partie) ou à chaque partie ?

## Prochaine étape

Prochaine session : valider les 9 tâches "En test" des sessions précédentes, puis attaquer par priorité :
1. Jackpot unique (court, Haute priorité)
2. Design cases + récompense (visuel, avant iOS)
3. Bandes de lancement (replace DEBUG)
