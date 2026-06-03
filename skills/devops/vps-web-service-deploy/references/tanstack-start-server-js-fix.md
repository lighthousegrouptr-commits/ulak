# TanStack Start SSR Worker Deploy — 2026-06-03 Update

## Critical: `server.js` vs `index.js`

TanStack Start SSR build produces `dist/server/server.js` (5.47 kB) but `wrangler.json` specifies `main: "index.js"`. The file is NOT automatically renamed.

**Fix**: After `bun run build`, copy:
```bash
cp dist/server/server.js dist/server/index.js
```

Without this, the deployed Worker serves stale/missing content.

## Critical: Remove `build-worker.mjs` from build pipeline

The old `scripts/build-worker.mjs` overwrites TanStack Start's SSR output with the old static HTML worker.

**Before** (broken):
```json
"build": "bun run seed:data && vite build && bun run scripts/build-worker.mjs"
```

**After** (working):
```json
"build": "bun run seed:data && vite build"
```

## Working deploy command

When config conflicts exist, use explicit config path:
```bash
wrangler deploy --config dist/server/wrangler.json
```

This bypasses `.wrangler/`, `wrangler.jsonc`, and any other config file.

## Canonical deploy script

Use `bash scripts/deploy.sh` which handles all steps:
1. Aggregate data
2. Build (vite only, no build-worker.mjs)
3. Copy server.js → index.js
4. Patch wrangler.json (name, main, kv_namespaces, routes)
5. Clean .wrangler cache
6. Rename wrangler.jsonc during deploy
7. Deploy with explicit config
8. Restore wrangler.jsonc

## wrangler.json template for dist/server/

```json
{
  "name": "tanstack-start-app",
  "main": "index.js",
  "compatibility_date": "2025-09-24",
  "compatibility_flags": ["nodejs_compat"],
  "no_bundle": true,
  "kv_namespaces": [
    {
      "binding": "LIVE_DATA",
      "id": "df2bda58d7bb4abe91569c4c48c5bf5b"
    }
  ],
  "routes": [
    { "pattern": "agentic.lighthousegroup.net.tr/*", "zone_name": "lighthousegroup.net.tr" }
  ],
  "assets": {
    "directory": "../client"
  }
}
```

## Version history

| Run | Version ID | Notes |
|-----|-----------|-------|
| r64 | `f377874b-d4b9-4a3c-8e04-c15276ecba92` | Fixed: removed build-worker.mjs, added server.js→index.js copy, explicit wrangler.json |
| r63 | `97ccf4d0-1fd8-481a-8e66-8123c0b501f2` | Stale asset hash on 1st attempt, rebuilt + redeployed |
| r58 | `c59b3509-2178-4d73-a170-b8efa5d879b4` | SPA restore from broken minimal worker |
