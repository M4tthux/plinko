# plinko_app

Flutter app du projet Plinko (Balleck Team) — mini-jeu promotionnel type Plinko avec 17 cases à multiplicateurs et physique manuelle Flame.

Déployé sur `https://m4tthux.github.io/plinko/` à chaque push master (voir [`../.github/workflows/deploy-web.yml`](../.github/workflows/deploy-web.yml)).

## Commandes

```bash
# Dev local (Chrome)
flutter run -d chrome

# Build web release
flutter build web --release

# Build web + serveur local pour test mobile (même Wi-Fi)
bash ../scripts/serve_web.sh
```

Sur Windows : **Git CMD uniquement** — le PATH `C:\flutter\bin` n'est pas reconnu depuis PowerShell.

## Structure

- `lib/config/plinko_config.dart` — config centrale du plateau
- `lib/game/` — `plinko_game.dart`, `ball.dart`, `board.dart`
- `lib/ui/` — `reward_overlay.dart`, `config_panel.dart`
- `lib/main.dart` — UI principale, balance, popups gain
- `assets/trajectories.json` — 70 trajectoires pré-calculées (70 trajectoires × 9 cases historiques)

## Documentation

- [`../CLAUDE.md`](../CLAUDE.md) — référence Claude Code
- [`../project-context.md`](../project-context.md) — source de vérité projet
- [`../decisions-log.md`](../decisions-log.md) — historique complet des décisions
