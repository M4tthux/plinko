# Session Design/Dev onboarding — 2026-04-21 (Builds 65-71)

## Ce qui a été fait

- **Build 65** — Landing : punchline « Tombe. Rebondit. Gagne. » → « Lâche. Prie. Encaisse. », sous-titre supprimé. Onboarding : 4 titres réécrits (enjeu > mécanique), titres step 2 « Le plateau » → « Valeur des cases » et step 4 « Billes par lancer » → « Nombre de billes ». Spec Notion validée 2026-04-20 appliquée.
- **Build 66** — Retrait bouton « Passer » flottant top-right + progress bar cyan top. « Passer » devient ghost link inline à gauche de Suivant/Terminer (Row end-aligned, gap 8px). Step 4 : uniquement Terminer (showSkip=false).
- **Build 67** — Step 1 cible désormais `_boardKey` (plateau entier) au lieu du wordmark. Step 2 cible nouveau `_multipliersKey` (bande resserrée sur la rangée slots). Brief du commentaire Notion du 2026-04-20 (« bille comprise dans le rectangle »).
- **Build 68** — Retrait de la rangée top de la callout (step pill `1/4` + dots breadcrumb) — réduit la hauteur mobile.
- **Build 69** — Retrait du body/sous-titre : callout = titre + CTAs uniquement. Titres réécrits pour porter l'explication complète. `_boardKey` top padding 30% → 22% pour inclure la bille.
- **Build 70** — Step 4 : « Tu peux lancer... » → « Tu peux choisir entre 1 et 10 billes par lancer. ».
- **Build 71** — Fix iOS : bascule des targets `_boardKey`/`_multipliersKey` de `Padding(EdgeInsets.only(top%/bottom%))` vers `Positioned(left:2%, right:2%, top:%, bottom:%)`. Le spot débordait horizontalement sur iPhone Safari malgré un layout théoriquement centré.

## Décisions prises

- **Onboarding minimaliste** — un callout onboarding = titre unique + CTAs. Plus de body, plus de progress bar, plus de step pill/dots. Raison : hauteur mobile contrainte, lisibilité instantanée, éviter de rogner sur le plateau.
- **« Passer » inline** — plus de bouton flottant top-right ; le ghost link à côté de Suivant regroupe les deux actions. Step 4 sans « Passer » car Terminer suffit.
- **Titres porteurs d'explication** — pas juste un label descriptif, le titre dit ce que le joueur doit comprendre (enjeu ou règle concrète).
- **Targets onboarding en `Positioned` explicite** — préférer un rect défini par `left/right/top/bottom` plutôt qu'une heuristique `Padding` en % du container, pour éviter les décalages de renderer (HTML/CanvasKit, Safari iOS).

## Problèmes rencontrés

- **Débordement horizontal step 1 sur iPhone Safari** (build 67-70) : le rect target calculé via `Padding + KeyedSubtree` + `localToGlobal` donnait des coordonnées décalées de ~140px à droite sur iOS, mettant le spot à moitié hors champ. Résolu build 71 par `Positioned(left:2%, right:2%, ...)` qui force le cadre dans le viewport sans dépendre de `localToGlobal` sur un widget interne à un `Padding`.
- **Spec « Onboarding layout » encore En test** : à valider visuellement après re-test iPhone sur build 71.
- **Preview MCP headless** non utilisable pour Flutter dev (DDC ne boot pas dans le renderer). Vérif visuelle uniquement via `flutter run -d chrome` + serveur LAN mobile (`plinko-mobile-preview`).

## Décalages spec vs code identifiés

- `_wordmarkKey` n'est plus une target du tour (step 1 passé au plateau), mais la variable et la clé montée sur `_PlinkoTitleOverlay` sont conservées. Pas de mort-code apparent ; si le tour n'utilise plus cette clé à terme, candidat à cleanup.
- Champ `body` de `TourTarget` toujours exposé dans l'API mais plus affiché dans la callout (valeur `''` en pratique). À nettoyer dans une future passe refacto si le design reste au titre seul.

## Prochaine étape prioritaire

Re-tester le build 71 sur iPhone (step 1 + step 2) pour valider que le spot est correctement positionné sur mobile, puis passer la tâche Notion « Onboarding layout à retravailler » de **En test** à **Done**.
