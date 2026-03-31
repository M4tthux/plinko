# Session 11 — Design néon + Table de lots — 2026-03-31

## Ce qui a été fait

- **Refonte design plateau** (`board.dart`) : picots ronds avec gradient cyan→violet (4 tons par rangée), fond pyramide glow, cases pill-shape avec LinearGradient + bordure néon
- **Redesign bille** (`ball.dart`) : halo externe (r×2.0, opacité 0.15), halo interne (r×1.4), corps RadialGradient cyan, highlight speculaire
- **Overlay récompense v3** (`reward_overlay.dart`) : flash blanc, confettis bas→haut (win), feux d'artifice or (jackpot), pulse ×3, shake montant 1s, mode perte (fade doux, carte grise, "Pas de chance cette fois…", sans particules)
- **Table de lots réelle chargée** (`plinko_config.dart`) : Perdu(33%), 1€(22%), 2€(18%), 5€(12%), 10€(8%), 25€(4%), 50€(2.5%), 500€(0.5% jackpot)
- **replayStride** changé de 4 → 3 (demande explicite Matthieu)
- **isLoss** ajouté à `PrizeLot` + `LandedResult` + `RewardOverlay`
- **highlightedSlotIndex** dans `PlinkoConfig` pour le dim des cases non-gagnantes
- `kBuildTime` incrémenté à build 15
- **Débogage DDC** : identifié boucle reload (port 52005 → taskkill PID 19428 → relaunch manuel Matthieu → port 52142)
- **Validation visuelle** : plateau néon cyan→violet confirmé, overlay "Perdu" confirmé

## Décisions prises

- `replayStride` par défaut = 3 (4 = trop lent, 3 = bon rythme)
- Table de lots réelle = spec client (Perdu 33% → 500€ 0.5%)
- Mode perte = overlay sobre sans particules (carte grise + message rassurant)
- Jackpot = 500€ (ancienne valeur 1000€ → 500€)
- `_visualScale = 1.0` (rayon physique = rayon visuel)

## Problèmes rencontrés

- **White page / DDC loop** : Flutter en boucle reload sans jamais compléter les 353 scripts DDC (~5fps). Cause : hot reload loop. Fix : taskkill PID + relaunch manuel.
- **DDC lenteur** : ~5fps en mode debug → 308 frames × stride = ~60s de vol. Config panel slider utilisé pour ajuster stride en live.
- **Overlay raté au premier atterrissage** : ConfigPanel couvrait l'écran. Re-lancé pour capturer.

## Prochaine étape

- Valider visuellement overlay **win** (flash blanc + confettis) et **jackpot** (feux d'artifice or)
- Itérations design si nécessaire — nouvelle conversation dédiée design
- Backlog : retirer LaunchZoneOverlay DEBUG (Z0–Z4) avant prod
