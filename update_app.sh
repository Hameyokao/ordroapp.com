#!/usr/bin/env bash
# Pull the latest code and restart ORDRO. Run from inside the app folder.
set -e
cd "$(dirname "$0")"
git pull
venv/bin/pip install -r requirements.txt
sudo systemctl restart ordro
echo "ORDRO updated and restarted. Your data in ./persist is untouched."
