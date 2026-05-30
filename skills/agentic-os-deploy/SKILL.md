---
name: agentic-os-deploy
title: Agentic OS Dashboard Deployment
description: Deploy and manage the Agentic OS dashboard (Tanstack Start SSR) on VPS with Cloudflare Worker or Nixpacks/Dokploy
---

# Agentic OS Dashboard Deployment

## Architecture

- **Framework**: Tanstack Start (SSR) + @cloudflare/vite-plugin
- **Build**: `bun run build` → dist/client/ (static) + dist/server/ (SSR)
- **No static index.html** — every request is server-rendered
- **Data**: `src/data/live-data.json` embedded in JS bundle at build time
- **Repo**: `/root/code/agentic-os`

## Prerequisites

- `bun` is at `/root/.bun/bin/bun` — **not** on default `$PATH`. Always use full path or export:
  ```bash
  export PATH="/root/.bun/bin:$PATH"
  ```

## Full Refresh Pipeline (Cron / Manual)

The full refresh syncs Hermes agent memories into the aggregate and deploys:

### 1. Sync Hermes Memory Files

```bash
mkdir -p /tmp/hermes-memory
cp /root/ulak/memories/*.md /tmp/hermes-memory/
```

**Source paths** (verified):
- `/root/ulak/memories/` — synced ulak snapshot (MEMORY.md, USER.md). **This is the correct source path.**
- `~/.hermes/memory/` and `~/.hermes/memories/` — do NOT exist on this system (verified May 2026).
- `/root/ulak/memory/` (singular) does NOT exist — the correct directory is `/root/ulak/memories/` (plural).
- The aggregator already has Hermes paths built in. **No code patch needed.**
- One file may be `MEMORY.md.lock` / `USER.md.lock` (empty lock files, harmless).

### 2. Hermes Memory Already in Aggregator

The aggregator (`scripts/aggregate.ts`) already scans these Hermes paths in `parseMemory()`:
```typescript
const hermesMemDirs = [
  "/tmp/hermes-memory",
  "/root/ulak/memories",
  "/root/.hermes/memory",
];
```
**No code modification needed** unless `parseMemory()` is rewritten from scratch.

### 3. Run Aggregator

```bash
cd /root/code/agentic-os && export PATH="$PATH:/root/.bun/bin" && bun run scripts/aggregate.ts
```

Expected output includes: `memory: N files / M workspaces` — verify `hermes` workspace appears.

### 4. Build

```bash
export PATH="$PATH:/root/.bun/bin" && bun run build
```

Produces `dist/client/` and `dist/server/`.

### 5. Deploy

```bash
wrangler deploy
```

Capture the `Current Version ID:` from output — this is the deploy handle for verification.

## Deployment

### Cloudflare Worker (preferred)
- `wrangler deploy` from repo root
- `wrangler.jsonc` config: `main: "src/server.ts"`
- Domain via Workers Routes
- **Bypasses any Dokploy container**

### Dokploy + Nixpacks
- `nixpacks.toml`: `[phases.build]` only, no `[start]` section
- Start: `bun --bun node_modules/.bin/vite preview --port 3000 --host 0.0.0.0`
- Override Caddyfile: `.nixpacks/Caddyfile` with `root * /app/dist/client`

## Automation / Cron Script

The file `scripts/cron-agentic-deploy.sh` is the scheduled deployment script. As of May 2026 it only does `git pull`, `build`, and `deploy` — it skips the Hermes memory sync and the `aggregate.ts` run.

**For a full refresh** (what the cron job description actually requests), run the full pipeline manually (steps 1–5 above) or update `cron-agentic-deploy.sh` to include the memory sync and aggregate steps:

```bash
# Add to cron-agentic-deploy.sh before the build step:
# Sync Hermes memories
mkdir -p /tmp/hermes-memory
cp /root/ulak/memories/*.md /tmp/hermes-memory/

# Run aggregator
export PATH="$PATH:/root/.bun/bin"
bun run scripts/aggregate.ts 2>> "$LOG" || echo "$(date): aggregate failed" >> "$LOG"
```

## Stale detection

`scripts/aggregate.ts` line 624: `const STALE_DAYS = 30`

## Adding a New Source Filter Tab to the Memory Graph

When a new memory source (e.g. `hermes` for the Ulak/Hermes agent) is added to the aggregator, the UI won't automatically show a filter tab. Three files need coordinated changes:

### Files to modify

1. **`scripts/aggregate.ts`** — ensure the source is detected and tagged:
   - Source list builder (~line 1600): `const kind` must recognize the new source label prefix
   - File node builder (~line 1546): `const fSource` must check `workspaceId.startsWith("new-source-")`
   - Workspace node builder (~line 1507-1511): `const wsSource` must check workspace ID prefix
   - `MemSource` type (~line 628): add the new source string literal

2. **`src/components/memory-graph-3d.tsx`** — add filter support:
   - In the `matches` function inside the `useMemo` data filter (~line 382-383):
     ```typescript
     if (allowedCats.has("new-source") && n.source === "new-source") return true;
     ```

3. **`src/routes/memory.tsx`** — add the UI pill/tab:
   - `type SourceId` (~line 38): add `"new-source"` to the union
   - `BASE_SOURCES` (~line 36) and `PINECONE_SOURCES` (~line 37): add the new source
   - `matchesActive()` (~line 68-76): add `if (sourceTag === "new-source" && activeSet.has("new-source")) return true;`
   - `SourceFilter` component pills array (~line 329-356): add a conditional pill entry. Use `liveData?.memory?.nodes?.some((n: any) => n.source === "new-source")` to conditionally show:
     ```typescript
     ...(liveData?.memory?.nodes?.some((n: any) => n.source === "new-source")
       ? [{
           id: "new-source" as const,
           label: "Display Name",
           color: "#HEX",
           tooltip: "Description",
         }]
       : []),
     ```

### Verification
- After deploy, check the Memory page for the new filter button
- Clicking it should show only nodes with `source === "new-source"`
- "All" filter should include the new source alongside existing ones

## Pitfalls

1. **`bun` not on PATH** — use `/root/.bun/bin/bun` or export PATH. `which bun` returns nothing by default.
2. **Wrong memory path** — Use `/root/ulak/memories/` (plural). `/root/ulak/memory/` (singular) and `~/.hermes/memories/` do NOT exist on this system.
3. **Hermes memory already in aggregator** — `scripts/aggregate.ts` already includes Hermes sources. No patch needed unless rewritten.
4. **Cron script skips aggregate** — `cron-agentic-deploy.sh` does NOT run `aggregate.ts`. Run full pipeline manually.
5. **Missing source kind entry** — `src/routes/memory.tsx` has THREE places that enumerate sources (SourceId type, BASE_SOURCES, and the SourceFilter pillar). All three must be updated or the filter tab won't appear on the dashboard.
6. **Duplicate source fix didn't deploy** — A patch to aggregate.ts that removes `/tmp/hermes-memory` from `hermesMemDirs` may appear fine in code but `/tmp/hermes-memory` can still exist on disk from a previous run. Always verify live-data.json for duplicate sources after deploy.
7. **Worker vs Container: Worker wins**. Check `cf-worker` header.
8. **Nixpacks `[start]`**: causes errors. Use `[phases.build]` only.
9. **SSR**: Vite preview catches all requests. Don't fetch `/live-data.json` in prod — use static import.
10. **`$NIXPACKS_SPA_OUTPUT_DIR`**: Railway-only. Hardcode path in Caddyfile.
11. **wrangler + Node.js** — `wrangler deploy` requires Node >= 22. VPS ships Node 20. wrangler v4.86.0 happens to work on Node 20 (no error), but this is not guaranteed. If deploy fails with Node version error, update wrangler: `npm i -g wrangler@latest` or use nvm to install Node 22.

12. **Skills page input too small for mobile** — The `minutes saved per run` input on the Skills page used `w-12` (48px) which is untappable on mobile. Fixed by replacing with `flex-1 min-w-[60px]` and setting `fontSize: "16px"` (inline style) to prevent iOS Safari zoom. Also added `WebkitAppearance: "none"` to prevent default mobile spinbutton styling that can obscure the value. Always test skill input forms on mobile viewport.
