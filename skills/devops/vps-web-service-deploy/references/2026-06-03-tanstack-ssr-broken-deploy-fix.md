# TanStack Start SSR Broken — Working Deploy Fix (2026-06-03)

## Problem

TanStack Start's `createStart()` from `@tanstack/react-start` returns an object **without** a `.fetch()` method when deployed to Cloudflare Worker.

Error: `TypeError: startInstance.fetch is not a function`

This is a **framework-level incompatibility** — not a config issue. The SSR path is fundamentally broken for Cloudflare Worker.

## Root Cause

- `src/start.ts` calls `createStart()` which returns `{ getOptions, createMiddleware }` — no `fetch`
- `src/server.ts` calls `startInstance.fetch(request, env, ctx)` — fails
- Build output: `dist/server/server.js` (5.47 kB) — contains the broken handler
- Wrangler expects `index.js` as entry point, not `server.js`

## Working Fix (CONFIRMED 2026-06-03)

```bash
cd /root/code/agentic-os   # or /opt/agentic-os

# 1. Aggregate data
bun run scripts/aggregate.ts

# 2. Build (vite build — do NOT include build-worker.mjs)
bun run build

# 3. Copy server.js → index.js (wrangler expects index.js)
cp dist/server/server.js dist/server/index.js

# 4. Patch wrangler.json with routes + KV namespace
#    (Vite doesn't reliably carry these from wrangler.jsonc)
python3 -c "
import json
with open('dist/server/wrangler.json') as f: d = json.load(f)
d['kv_namespaces'] = [{'binding': 'LIVE_DATA', 'id': 'df2bda58d7bb4abe91569c4c48c5bf5b'}]
d['routes'] = [{'pattern': 'agentic.lighthousegroup.net.tr/*', 'zone_name': 'lighthousegroup.net.tr'}]
with open('dist/server/wrangler.json', 'w') as f: json.dump(d, f, indent=2)
"

# 5. Deploy using --config to bypass wrangler.jsonc conflict
wrangler deploy --config dist/server/wrangler.json
```

## Alternative: Use scripts/deploy.sh

The `scripts/deploy.sh` script handles all steps automatically:
- aggregate → build → copy server.js → patch wrangler.json → rename jsonc → deploy → restore jsonc

```bash
bash scripts/deploy.sh
```

## Key Points

- **Do NOT attempt to fix the SSR handler** — it's a framework incompatibility
- **Do NOT use `build-worker.mjs`** — it overwrites the build output with old static HTML
- **Do NOT `cd dist/server` and deploy** — causes config path conflicts
- **Use `--config` flag** to bypass wrangler.jsonc/json conflict
- **Always patch wrangler.json** after build — Vite doesn't carry KV/routes
- **Always copy server.js → index.js** — wrangler expects index.js

## Cron Deploy Script

The `scripts/cron-agentic-deploy.sh` must be updated to use this pattern.
Old pattern (broken): `wrangler deploy` from root without server.js copy or wrangler.json patch.
New pattern: Use `scripts/deploy.sh` or replicate the steps above.

## Verification

After deploy, check:
```bash
curl -s -o /dev/null -w "%{http_code}" https://agentic.lighthousegroup.net.tr/
# Should return 200 (not 500)
```

If 500: check `wrangler tail tanstack-start-app` for errors.
If "This page didn't load": the SSR handler is still broken — re-deploy with the fix above.
