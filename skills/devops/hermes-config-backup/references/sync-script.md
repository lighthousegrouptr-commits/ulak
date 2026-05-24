# ulak_sync.sh — Full Script Reference

Place at `~/.hermes/scripts/ulak_sync.sh` and `chmod +x` it.

```bash
#!/bin/bash
# Ulak tam yedek & sync scripti
# ~/.hermes kritik dosyaları -> /root/ulak -> GitHub lighthousegrouptr-commits/ulak

HERMES="$HOME/.hermes"
ULAK="/root/ulak"

# --- 1. Hermes dosyalarını ulak klasörüne kopyala ---

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

if [ -f "$HERMES/config.yaml" ]; then
  grep -v "api_key\|password\|secret\|token\|TOKEN\|SECRET\|PASSWORD" \
    "$HERMES/config.yaml" > "$ULAK/config/config.yaml" 2>/dev/null || true
fi

if [ -d "$HERMES/hooks" ] && [ "$(ls -A $HERMES/hooks 2>/dev/null)" ]; then
  mkdir -p "$ULAK/hooks"
  cp -r "$HERMES/hooks/." "$ULAK/hooks/"
fi

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
```

## Notes

- HTTPS remote with embedded token: `https://$GITHUB_TOKEN@github.com/OWNER/REPO.git`
- Token read from `~/.hermes/.env` as `GITHUB_TOKEN`
- rsync with `--delete` keeps remote in sync with local deletions
- Secret filter uses grep -v to strip sensitive lines from config.yaml
- no_agent cron: `script='ulak_sync.sh'`, `no_agent=True`, `schedule='every 30m'`
