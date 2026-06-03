# Deploy Script with wrangler.jsonc Rename Pattern

## Problem

When deploying the TanStack SPA from `/opt/agentic-os`, wrangler fails with:
```
ERROR: Found both a user configuration file at "wrangler.json"
  and a deploy configuration file at "../../.wrangler/deploy/config.json".
```

This happens because:
1. `wrangler.jsonc` exists in the project root (user config)
2. `dist/server/wrangler.json` exists from the Vite build (deploy config)
3. Wrangler can't decide which to use

## Solution

Temporarily rename `wrangler.jsonc` during deployment:

```bash
cd /opt/agentic-os

# Clean cache
rm -rf .wrangler /root/.wrangler

# Rename wrangler.jsonc to avoid config conflict
mv wrangler.jsonc wrangler.jsonc.bak

# Deploy from project root (auto-redirects to dist/server/wrangler.json)
npx wrangler deploy

# Restore wrangler.jsonc
mv wrangler.jsonc.bak wrangler.jsonc
```

## Full Deploy Pipeline

```bash
#!/usr/bin/env bash
set -e

cd /opt/agentic-os

# 1. Refresh data
bun run aggregate

# 2. Build SPA
bun run build

# 3. Fix wrangler.json (Vite doesn't carry kv_namespaces/routes)
python3 -c "
import json
with open('dist/server/wrangler.json', 'r') as f:
    d = json.load(f)
d['main'] = 'index.js'
d['kv_namespaces'] = [{'binding': 'LIVE_DATA', 'id': 'df2bda58d7bb4abe91569c4c48c5bf5b'}]
d['routes'] = [{'pattern': 'agentic.lighthousegroup.net.tr/*', 'zone_name': 'lighthousegroup.net.tr'}]
with open('dist/server/wrangler.json', 'w') as f:
    json.dump(d, f, indent=2)
print('wrangler.json fixed')
"

# 4. Clean + rename wrangler.jsonc
rm -rf .wrangler /root/.wrangler
mv wrangler.jsonc wrangler.jsonc.bak

# 5. Deploy
npx wrangler deploy

# 6. Restore
mv wrangler.jsonc.bak wrangler.jsonc

echo "Done!"
```

Save as `scripts/deploy.sh` for reuse.
