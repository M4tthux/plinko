---
name: plinko-mobile-preview
description: >
  Lance un serveur local pour tester le projet Plinko sur un téléphone du même réseau WiFi,
  sans passer par un push GitHub / gh-pages. Build Flutter web prod + serveur Python
  sur `0.0.0.0:8082`, renvoie l'URL LAN à ouvrir sur le mobile.
  Déclencher sur : "test mobile", "test iPhone", "test tél", "voir sur mon téléphone",
  "preview mobile", "lance le serveur mobile", "je veux tester sur mon tél",
  "serve le build", "build + serve", "preview LAN", "montre-moi sur mobile".
  À utiliser en alternative à `flutter run -d chrome` quand l'utilisateur veut tester
  sur iPhone/Android (le mode dev Flutter web est trop lourd pour Safari iOS,
  d'où le besoin d'un build release).
---

# Plinko Mobile Preview — Balleck Team

Permet à Matthieu de tester le projet Plinko sur son iPhone (ou tout mobile du même WiFi)
sans committer ni pousser. Build web release + serveur HTTP Python sur le port `8082`.

> **Pourquoi prod et pas dev ?** `flutter run -d chrome` sert un bundle debug (~20+ Mo)
> que Safari iOS coupe → page blanche. Un `flutter build web --release` produit un bundle
> tree-shaké (~2 Mo) qui passe sur iPhone.

---

## Étapes

### 1. Vérifier qu'on est bien dans le projet

```bash
pwd
# doit contenir /Plinko (sinon s'arrêter et demander à Matthieu)
```

### 2. Récupérer l'IP locale du PC

```bash
ipconfig | grep "IPv4"
```

Prendre la première IP `192.168.x.y` ou `10.x.y.z`. Si plusieurs interfaces actives
(Ethernet + WiFi), prendre celle qui est sur le même subnet que la box du mobile.
Si doute → demander à Matthieu sur quel réseau est son tél.

### 3. Vérifier si le port 8082 est déjà occupé

```bash
netstat -ano | grep ":8082"
```

- Si un process écoute déjà → skill déjà lancé dans cette session, donner directement l'URL
  et stopper ici.
- Sinon → continuer.

### 4. Build Flutter web release

```bash
cd plinko_app
flutter build web --release
```

- Timeout : 300 000 ms (3 min, le build prend ~30–60 s)
- Vérifier `√ Built build\web` dans la sortie. Si erreur → remonter à Matthieu, ne pas servir.

### 5. Lancer le serveur Python en background

```bash
cd plinko_app/build/web
python -m http.server 8082 --bind 0.0.0.0
```

- Lancer **en background** (`run_in_background: true`)
- Attendre 2 s puis vérifier que le port écoute : `netstat -ano | grep ":8082"`
  doit montrer `0.0.0.0:8082 LISTENING`.

### 6. Communiquer l'URL à Matthieu

Format de réponse attendu :

```
Serveur prêt : http://<IP>:8082

Sur ton mobile (même WiFi que le PC) → ouvre cette URL.
Si ça ne charge pas → pare-feu Windows. Lance en PowerShell admin :
  netsh advfirewall firewall add rule name="Plinko 8082" dir=in action=allow protocol=TCP localport=8082
```

### 7. Laisser tourner

Le serveur Python tourne en background — ne pas l'arrêter automatiquement.
À la fin de la session (ou quand Matthieu le demande), proposer de le kill.

---

## Règles

- **Toujours release, jamais debug** — Safari iOS ne digère pas le bundle dev
- **Port fixe 8082** — différent du `8081` de `flutter run` pour pouvoir cohabiter
- **Ne pas toucher au `flutter run` actif** — ce skill est additif
- **Pas de commit / push** — c'est justement l'intérêt du skill vs CI gh-pages
- **Rebuild à chaque changement de code** : le serveur Python sert des fichiers
  statiques, il faut relancer `flutter build web` après toute modif. Si Matthieu
  change le code et veut re-tester → relancer uniquement l'étape 4 (le serveur
  Python n'a pas besoin de redémarrer, il relit les fichiers à chaque requête).
