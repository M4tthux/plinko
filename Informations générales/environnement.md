# Environnement de développement — Plinko (Balleck Team)

> Ce fichier documente l'environnement installé sur la machine de développement.
> Mis à jour à chaque changement d'outil ou de version.

---

## Machine

| Propriété | Valeur |
|---|---|
| OS | Windows 11 (version 10.0.26200.8037, build 25H2) |
| Utilisateur | C:\Users\Utilisateur |
| Locale | fr-FR |

---

## Outils installés

### Flutter SDK
| Propriété | Valeur |
|---|---|
| Version | 3.41.6 (channel stable) |
| Emplacement | `C:\flutter` |
| Ajouté au PATH | `C:\flutter\bin` (variables d'environnement utilisateur) |
| Terminal recommandé | **Git CMD** (seul terminal où `flutter` est reconnu dans la session actuelle) |
| Commande de vérification | `flutter doctor` |

### Git
| Propriété | Valeur |
|---|---|
| Statut | ✅ Installé |
| Terminal | Git CMD disponible |

### VS Code
| Propriété | Valeur |
|---|---|
| Statut | ✅ Installé |
| Extension Flutter | ✅ Installée (mais SDK non configuré via VS Code — utiliser Git CMD) |

---

## Cibles de build disponibles

| Cible | Statut | Notes |
|---|---|---|
| **Chrome (Web)** | ✅ Disponible | `flutter run -d chrome` — cible de test principale |
| **Android** | ❌ Non disponible | Android SDK manquant (pas d'Android Studio) |
| **Windows Desktop** | ❌ Non disponible | Visual Studio C++ requis (non installé) |
| **iOS** | ❌ Non disponible | Nécessite macOS + Xcode |

---

## Limitations connues

- `flame_forge2d` n'est **pas compatible Flutter Web** (conflit `vector_math` / `vector_math_64` au moment de la compilation dart2js). Forge2D est donc utilisé **uniquement** dans le script offline `generate_trajectories.dart` — jamais dans le runtime du jeu.
- Le PATH `C:\flutter\bin` est actif uniquement dans les terminaux ouverts **après** sa configuration. Utiliser **Git CMD** pour toutes les commandes Flutter.
- Pour tester sur device physique iOS ou Android, il faudra compléter l'environnement (Android Studio ou Mac + Xcode).

---

## Commandes de base

```bash
# Vérifier l'installation
flutter doctor

# Installer les dépendances du projet
cd C:\Users\Utilisateur\Projets\Plinko\plinko_app
flutter pub get

# Lancer en mode web (Chrome)
flutter run -d chrome

# Ajouter le support web au projet (une seule fois)
flutter create .

# Lister les devices disponibles
flutter devices
```

---

*Dernière mise à jour : 2026-03-26 — Installation Flutter 3.41.6 + configuration PATH Windows*
