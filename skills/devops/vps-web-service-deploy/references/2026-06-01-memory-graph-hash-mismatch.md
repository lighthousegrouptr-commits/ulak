# Memory Graph Hash Mismatch — 2026-06-01

## Problem
Memory page at `agentic.lighthousegroup.net.tr/memory` showed stat tiles correctly (22 files, 22 active, 6 activated) but the 3D graph was stuck on "Loading memory graph" with no canvas rendering.

## Root Cause
Vite/TanStack Start build produced **different chunk hashes** for client and server bundles:

- Server manifest referenced: `memory-graph-3d-CkAuc5B5-C1oC2O2O-...js`
- Client bundle contained: `memory-graph-3d-x5E0NbAC.js`

The server-rendered HTML requested the server-side hash, which returned 404 from the Cloudflare Worker (file didn't exist in the asset store). The dynamic `import("react-force-graph-3d")` failed silently, so the canvas never initialized.

## Diagnosis Steps
1. Browser: `document.querySelector('canvas')` → `null` (no canvas)
2. Browser: fetch the server-referenced chunk URL → 404
3. Browser: fetch the client-side chunk URL → 200 OK
4. Compare `dist/server/assets/memory-graph-3d-*` vs `dist/client/assets/memory-graph-3d-*` → different hashes

## Fix
```bash
cd /root/code/agentic-os
rm -rf dist
export PATH="/root/.bun/bin:$PATH"
bun run build
wrangler deploy
```

Clean rebuild re-synchronizes client/server hashes.

## Why Wrangler Didn't Catch It
Wrangler reported "No updated asset files to upload" because it compared against the previous deployment's asset manifest. The server module hash hadn't changed (it was already uploaded), but the client asset hash was new and wasn't force-uploaded. This is a wrangler asset dedup limitation — it doesn't verify cross-referential integrity between server module imports and client asset files.

## Additional Finding: live-data.example.json vs live-data.json
The `live-data.example.json` has `memory.nodes: [], memory.links: [], memory.stats.totalFiles: 0` while `live-data.json` has 27 nodes, 68 links, and real stats. Worker serves from the committed example file if live-data.json is not properly included. The aggregate runs correctly on the VPS (24 files, 2 workspaces) — the issue was purely a build/deploy artifact.

---

## Update 2026-06-01 Session 2: Wrangler Asset Dedup Cache

### Problem
After `rm -rf dist && bun run build && wrangler deploy`, the worker still served stale content (`"building..."` / `"placeholder"`) instead of the new SSR app. Wrangler reported "No updated asset files to upload" every time despite the local build being correct.

### Root Cause
Wrangler's asset upload logic compares **content hashes** of local `dist/client/assets/` against the **currently-deployed version's manifest**. If hashes match (deterministic build from unchanged sources), wrangler skips upload. This is problematic because:

1. After `rm -rf dist`, the old deployment's manifest still lives in Cloudflare KV
2. Wrangler re-uploads the **worker script** (small `index.js` or `worker-entry.js`) but NOT the client assets
3. The new worker entry references assets that either (a) exist with old hashes only, or (b) don't exist at all
4. Result: worker boots but can't load its own chunks → returns fallback/error

### Additional Issue: Cloudflare Vite Plugin Config Hook
The `@cloudflare/vite-plugin` validates `wrangler.jsonc`'s `main` field (`dist/server/index.js`) during the config phase, BEFORE build output is written. On a clean `rm -rf dist`, this file doesn't exist, causing:

```
Error: The provided Wrangler config main field (.../dist/server/index.js) doesn't point to an existing file
```

**Workaround:** Create a placeholder before build:
```bash
mkdir -p dist/server
echo 'export default { fetch: () => new Response("placeholder") };' > dist/server/index.js
bun run build   # overwrites with real bundle
```

### Attempted Fixes (ordered by desperation)

| Approach | Result |
|----------|--------|
| `wrangler deploy` after rebuild | "No updated asset files to upload" — skipped |
| `wrangler deploy --old-asset-ttl 0` | Same — flag only affects TTL of old assets, not dedup |
| Modify `src/server.ts` (add comment) | Same hash produced — wrangler still skips |
| Change `wrangler.jsonc` name to `*-v2` | Deployed to new name, same asset dedup behavior |
| `rm -rf .wrangler/state .wrangler/tmp` | Blocked by security scanner |
| Place placeholder `dist/server/index.js` before build | Build succeeds but wrangler still skips assets |

### What Finally Needs to Happen
The wrangler asset dedup cache must be invalidated at the Cloudflare infrastructure level. Options:
1. **Delete the worker via Cloudflare dashboard** (Workers & Pages → select → Delete), then `wrangler deploy` fresh
2. **Deploy via Cloudflare API** directly (PUT with `--force` equivalent)
3. **Change worker name permanently**, update DNS/routes, then never rename back

### Verification Pattern
After EVERY `wrangler deploy`, verify the worker is serving fresh content:
```bash
# Check homepage renders (not placeholder)
curl -s https://agentic.lighthousegroup.net.tr/ | head -5

# Check a known chunk loads (200 not 404)
curl -s -o /dev/null -w "%{http_code}" https://agentic.lighthousegroup.net.tr/assets/index-*.js

# Check memory page specifically
curl -s -o /dev/null -w "%{http_code}" https://agentic.lighthousegroup.net.tr/memory
```
