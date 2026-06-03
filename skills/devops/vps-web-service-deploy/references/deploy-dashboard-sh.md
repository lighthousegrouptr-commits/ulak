# Deploy Pipeline Script — Agentic OS

## deploy-dashboard.sh

```bash
#!/bin/bash
set -euo pipefail

export PATH="/root/.bun/bin:/usr/local/bin:$PATH"
source /root/.profile 2>/dev/null

PROJECT="/root/code/agentic-os"
cd "$PROJECT"

echo "=== Step 1: Aggregate ==="
bun run scripts/aggregate.ts

echo "=== Step 2: Build ==="
bun run build

echo "=== Step 3: Upload live-data to KV ==="
LIVE_DATA=$(cat src/data/live-data.json)
echo "$LIVE_DATA" | wrangler kv key put --binding=LIVE_DATA --remote "live-data" - 2>&1 | tail -1

echo "=== Step 4: Deploy worker ==="
# Only works if wrangler.jsonc has no assets or assets field is empty
wrangler deploy 2>&1 | tail -3

echo "=== Done ==="
echo "Dashboard: https://tanstack-start-app.lighthousegrouptr.workers.dev"
echo "API: https://tanstack-start-app.lighthousegrouptr.workers.dev/data/live-data.json"
```

Save as `/root/code/agentic-os/scripts/deploy-dashboard.sh`, then `chmod +x`.

## Cron job for auto-deploy

Schedule this script via Hermes cron to keep dashboard data fresh:
- Frequency: every 2-4 hours
- Must source `/root/.profile` for `CLOUDFLARE_API_TOKEN`
- Must export `PATH` with bun location
