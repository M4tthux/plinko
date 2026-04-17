# Session 2026-04-17 — Responsive mobile + desktop (Build 46)

> 4ème session du jour après `2026-04-17_cleanup-archi-repo.md`, `2026-04-17_audit-archi-contexte.md`, `2026-04-17_immersivite-plateau-mobile.md`.

## Contexte

Matthieu liste 3 tâches à cadrer avant dev : (1) responsive, (2) passe design UI+anim, (3) mode récompense pré-définie avant lancer. Demande que pour chacune on fasse d'abord spec/design puis tâches Notion, puis dev. On attaque la tâche 1.

Bench industrie rapide : Stake / BGaming / crash games → tous gardent un plateau portrait à largeur fixe, décor autour sur desktop, jamais de canvas qui s'étire. Spec proposée, validée par Matthieu.

## Décisions

**Règle responsive finale (Build 46)** :
- **Breakpoint unique 1024px** — viewport < 1024 = mobile, ≥ 1024 = desktop. Pas de zone grise tablette.
- **Mobile** : `width = (viewport × 0.92).clamp(0, 500)`, centré.
- **Desktop** : layout 3 colonnes `[240 | 20 | 500 | 20 | 240]` = 1020px centré. Panneaux latéraux = placeholders dashed border + label "panel left/right".
- **HUD relatif au conteneur 500px** — balance, build badge, instructions, popups, config panel dans le Stack interne → se recentrent avec le plateau en desktop au lieu de partir aux bords du viewport.

**Adaptation CSS → Flutter** : la spec initiale était en CSS, traduite en widgets Flutter (`LayoutBuilder` = media query, `ConstrainedBox`/`SizedBox` = max-width, `Row` = grid, `CustomPainter` = border dashed qui n'existe pas nativement).

**Validation visuelle Chrome DevTools** aux 4 largeurs clés : 375 / 768 / 1024 / 1440 — OK.

## Actions

### Code
- `plinko_app/lib/main.dart` :
  - `kBuildTime` : 45 → 46
  - 4 nouvelles constantes en tête : `kDesktopBreakpoint = 1024`, `kBoardMaxWidth = 500`, `kSidePanelWidth = 240`, `kDesktopGap = 20`
  - `build()` refondu : `LayoutBuilder` qui branche mobile vs desktop
  - Mobile : `Center > SizedBox(width: clamp(maxWidth × 0.92, 0, 500))`
  - Desktop : `Center > SizedBox(width: 1020) > Row` avec 3 colonnes
  - Extraction du Stack jeu+HUD dans `_buildGameContainer()` pour réutilisation mobile/desktop
  - Nouveau widget `_SidePanelPlaceholder` avec `DottedBorderBox` (CustomPainter pour border dashed)
- Aucun changement sur `plinko_game.dart`, `plinko_config.dart`, physique ou trajectoires : le zoom dynamique `_applyResponsiveCamera(size)` reçoit simplement la size contrainte et s'adapte tout seul.

### Docs
- `project-context.md` :
  - §Décisions actives — nouvelle sous-section "Responsive mobile + desktop (Build 46)"
  - §État d'avancement — Build 45 → Build 46
  - Footer — dernière mise à jour 2026-04-17 Build 46
- `CLAUDE.md` :
  - §Config plateau actuelle — Build 45 → Build 46 avec mention responsive

### Notion
- **Tâche "Spec responsive — breakpoint unique 1024px + board mobile plafonné 500px"** (existait déjà) → Statut **Done** (code implémenté + validé visuellement).
- **Tâche "Passe design complète — refonte assets visuels"** (existait déjà) → inchangée, couvre bien la future tâche 2 de Matthieu.
- **Nouvelle tâche créée "Mode récompense pré-définie — choix du gain avant lancer"** (Backlog / Moyenne / Game Design / Post-MVP) avec 2 variantes à trancher (choix joueur vs token serveur), dépendances (régénérer trajectoires + backend token) et critères d'acceptation/test.

## Problèmes rencontrés

- **Prompt initial en CSS** — Matthieu a donné la spec en CSS/HTML. Adaptation 1:1 en Flutter faite : `LayoutBuilder` / `ConstrainedBox` / `Row` / `CustomPainter`. Pas de perte de sémantique.
- **Premier `flutter run` en background échoué** — working dir perdu (erreur `cd: plinko_app: No such file or directory`). Résolu en utilisant le chemin absolu `/c/Users/Utilisateur/Projets/Plinko/plinko_app`.
- **Border dashed non natif en Flutter** — `BorderStyle.dashed` n'existe pas. Implémenté via `CustomPainter` qui itère sur les `PathMetrics` avec segments de 6px / gap 4px.

## Prochaine étape

- **Tâche 2 : passe design UI + animations** — la tâche Notion existe (Post-MVP). Quand Matthieu veut démarrer, produire une spec design avant tout code (cf. règle "concevoir avant de développer"). Direction artistique déjà posée : néon rose/violet/doré, rails néon entre rangées de pegs.
- **Tâche 3 : récompense pré-définie** — tâche Notion créée. Nécessite de trancher variante A (choix joueur) vs B (token serveur) + régénérer les trajectoires + scoper le backend token.
- Backlog technique inchangé : régénérer trajectoires pour grille 12 rangs / 9 cases, retirer LaunchZoneOverlay DEBUG.
