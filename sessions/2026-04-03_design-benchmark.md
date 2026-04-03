# Session Design Benchmark — 2026-04-03

## Ce qui a été fait
- Analyse du benchmark Notion "Benchmark Physique Bille" vs code actuel
- Identification de ce qui est applicable en l'état vs ce qui nécessite du dev
- Application des 3 quick wins :
  - `ballRestitution` 0.35 → 0.55 → 0.25 (0.55 trop fort selon Matthieu)
  - `pegRestitution` 0.50 → 0.55
  - `gravity` 18.0 → 15.0
  - Délai 300ms avant overlay récompense
- Ajout slider "Rebond bille" (`ballRestitution`) dans le config panel
- Build 24 (2026-04-03)

## Décisions prises
- Le benchmark recommandait ballRestitution 0.55-0.65, mais c'est trop fort visuellement → test à 0.25
- Tant qu'on est en `forcePhysicsMode = true`, pas besoin de régénérer les trajectoires pour tester les valeurs physiques
- Les valeurs finales seront fixées après test, puis trajectoires régénérées une seule fois pour la prod

## Problèmes rencontrés
- Flutter ne se lance pas depuis Claude Code (problème de PATH Windows/bash) → Matthieu lance manuellement
- Build 23 toujours affiché malgré changements → nécessitait hot restart (pas hot reload)
- kBuildTime mis à jour manuellement → build 24

## Prochaine étape
- Valider les valeurs physiques (ballRestitution=0.25, gravity=15, pegRestitution=0.55)
- Trail lumineux derrière la bille (8-12 positions, fade opacity)
- Squash & stretch bille (10-15% déformation)
- Glow flash picots au passage (200ms)
