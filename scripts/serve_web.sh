#!/usr/bin/env bash
# serve_web.sh — Build Flutter web + serveur local pour test mobile
# Usage : bash scripts/serve_web.sh
# Puis ouvrir http://<IP_PC>:8080 sur le téléphone (même Wi-Fi)

set -e

PORT=${1:-8080}

echo "=== Build Flutter web (release) ==="
cd plinko_app
flutter build web --release
cd ..

echo ""
echo "=== Adresses disponibles ==="
# Afficher les IP locales (Windows ipconfig via Git Bash)
if command -v ipconfig.exe &>/dev/null; then
  ipconfig.exe | grep -i "IPv4" | sed 's/.*: /  http:\/\//' | sed "s/$/:$PORT/"
else
  echo "  http://localhost:$PORT"
fi

echo ""
echo "=== Serveur démarré sur le port $PORT ==="
echo "  Ctrl+C pour arrêter"
echo ""

cd plinko_app/build/web
python -m http.server "$PORT" --bind 0.0.0.0
