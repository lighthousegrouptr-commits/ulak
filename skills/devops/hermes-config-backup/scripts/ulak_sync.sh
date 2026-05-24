#!/bin/bash
# Ulak / Hermes config backup sync script
# ~/.hermes critical files -> /root/ulak -> GitHub
#
# Usage: bash ~/.hermes/scripts/ulak_sync.sh
# Schedule: cronjob(no_agent=True, schedule='every 30m', script='ulak_sync.sh')

HERMES="$HOME/.hermes"
ULAK="/root/ulak"   # adjust to your local repo path

# --- 1. Copy Hermes files into backup repo ---

cp "$HERMES/SOUL.md" "$ULAK/SOUL.md"

mkdir -p "$ULAK/memories"
cp "$HERMES/memories/MEMORY.md" "$ULAK/memories/MEMORY.md" 2>/dev/null || true
cp "$HERMES/memories/USER.md"   "$ULAK/memories/USER.md"   2>/dev/null || true

mkdir -p "$ULAK/skills"
rsync -a --delete \
  --exclude "*.lock" \
  --exclude "__pycache__" \
  --exclude ".usage.json" \
  "$HERMES/skills/" "$ULAK/skills/" 2>/dev/null || \
  cp -r "$HERMES/skills/." "$ULAK/skills/"

mkdir -p "$ULAK/cron"
cp "$HERMES/cron/jobs.json" "$ULAK/cron/jobs.json" 2>/dev/null || true

# Config without secrets
mkdir -p "$ULAK/config"
if [ -f "$HERMES/config.yaml" ]; then
  grep -v "api_key\|password\|secret\|token\|TOKEN\|SECRET\|PASSWORD" \
    "$HERMES/config.yaml" > "$ULAK/config/config.yaml" 2>/dev/null || true
fi

# Hooks (if any)
if [ -d "$HERMES/hooks" ] && [ "$(ls -A "$HERMES/hooks" 2>/dev/null)" ]; then
  mkdir -p "$ULAK/hooks"
  cp -r "$HERMES/hooks/." "$ULAK/hooks/"
fi

# This script itself
mkdir -p "$ULAK/scripts"
cp "$HERMES/scripts/ulak_sync.sh" "$ULAK/scripts/ulak_sync.sh" 2>/dev/null || true

# --- 2. Git commit & push ---
cd "$ULAK" || exit 1

STATUS=$(git status --porcelain)

if [ -z "$STATUS" ]; then
  git fetch origin --quiet 2>&1
  LOCAL=$(git rev-parse HEAD)
  REMOTE=$(git rev-parse origin/main 2>/dev/null)
  if [ "$LOCAL" = "$REMOTE" ]; then
    echo "Ulak guncel, degisiklik yok."
    exit 0
  else
    echo "Remote'da yeni commit, pull yapiliyor..."
    git pull origin main
  fi
else
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
  git add -A
  git commit -m "sync: $TIMESTAMP"
  git push origin main
  echo "Ulak senkronize edildi: $TIMESTAMP"
  echo "$STATUS"
fi
