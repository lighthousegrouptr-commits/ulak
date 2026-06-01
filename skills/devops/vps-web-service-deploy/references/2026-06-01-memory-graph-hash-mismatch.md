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
