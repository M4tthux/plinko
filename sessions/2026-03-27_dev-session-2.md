# Dev Session 2 — 2026-03-27

## Ce qui a été fait

- Montage du bon dossier projet (`C:\Users\Utilisateur\Projets\Plinko`) — le dossier "Projet Plinko" sélectionné au départ était vide
- Revue de code de la Session 1 : aucun bug bloquant, 2 points mineurs (withOpacity déprécié, lerp caméra framerate-dépendant)
- **Densité picots portée à x4** : pegSpacingX 2.0→1.0, pegSpacingY 1.5→0.9, 24 rangées, 17 picots/rangée, pegRadius 0.22→0.15, ballRadius 0.28→0.22, pegRestitution 0.40→0.50
- **Parois en dents de scie** : nouveau composant `SawtoothWall` (visuel zigzag + réflexion angulaire physique), alternance dent/plat, kick minimum inward garanti (`wallMinKickX = 1.5`)
- **Cases remontées** : worldHeight réduit de 42 à 29 — gap entre dernier picot et cases = ~1.3 unités. Clamp caméra ajusté.
- **2 nouvelles tâches Notion créées** :
  - Session 2 / Dev / Haute : Séparateurs de cases solides
  - Session 3 / Game Design / Moyenne : Case Jackpot bords rebondissants [Scénario B]

## Décisions prises

- Densité picots : x4 par rapport à l'original (formule : gap = pegSpacingX - 2×pegRadius doit être > 2×ballRadius)
- Parois sawtooth comme solution anti-glissement bord — dents alternées (une sur deux)
- worldHeight = 29.0 comme nouvelle référence

## Problèmes rencontrés

- **Bille coincée entre picot et mur** : le kick minimum (`wallMinKickX`) aide mais ne règle pas le fond du problème. La vraie solution est de s'assurer que le placement des picots garantit toujours un passage ≥ diamètre bille. Avec les valeurs actuelles : gap = 1.0 - 2×0.15 = 0.70, bille = 2×0.22 = 0.44. Le gap est suffisant en théorie mais pas garanti en pratique car les picots de bord sont proches du mur. **À résoudre en prochaine session.**
- Méthode `_preventWallSticking()` ajoutée puis retirée (approche rejetée par Matthieu — solution correcte = layout picots)

## Prochaine étape

Ajuster le placement des picots pour garantir un passage minimum entre chaque picot et le mur ≥ diamètre bille. Combiner pegSpacingX, pegRadius, ballRadius avec une règle géométrique explicite dans le code. Possiblement : réduire le nombre de colonnes de bord ou décaler la première/dernière colonne.
