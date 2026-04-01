# Session Fix Design + Web Mobile — 2026-04-01

## Ce qui a été fait
- **Fix bug damier** : `plateau.png` (généré par Gemini) était 100% opaque avec faux motif de transparence baked-in → retiré de l'overlay Flutter
- **Fix picots** : `rond.png` (Gemini) aussi 100% opaque avec fond blanc → retour au rendu code (cercles avec dégradé cyan→violet par rangée, halo + reflet)
- **Restauration BoardFrame** : cadre néon violet redessiné par Flame (remplace plateau.png overlay)
- **backgroundBuilder** ajouté au GameWidget pour fond opaque garanti sur Chrome
- **Build Flutter web release** : `flutter build web --release` → site statique dans `build/web/`
- **Viewport meta tag** ajouté à `web/index.html` pour rendu mobile correct
- **Script `scripts/serve_web.sh`** : build + serve local en une commande
- **Test iPhone validé** : jeu accessible via `http://192.168.1.13:8080` sur Safari

## Décisions prises
- Passe design complète reportée en fin de projet (tous les assets Gemini sont inutilisables en l'état)
- Items cadrage design (gravité bille, jackpot hardcodé, émotion win/lose) reportés à la passe design
- Test mobile via web local (pas de build iOS natif — pas de Mac)

## Problèmes rencontrés
- **Assets Gemini** : les 3 PNG générés (background.png, plateau.png, rond.png) ont des problèmes d'alpha. Gemini ne gère pas correctement la transparence PNG — il bake le motif de transparence en pixels opaques.
- **Flutter process** : le serveur Flutter debug se ferme souvent entre les relances — nécessite `taskkill` + relance manuelle.

## Prochaine étape
- Passe design complète (picots, cadre, fond, bille) — en fin de projet
- Continuer le backlog fonctionnel
