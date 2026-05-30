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

## Pitfalls
1. **`bun` not on PATH** — use `/root/.bun/bin/bun` or export PATH. `which bun` returns nothing by default.
2. **Wrong memory path** — The cron task may mention `/root/ulak/memory/` but that path doesn't exist. Use `/root/ulak/memories/` (plural). `~/.hermes/memories/` also doesn't exist on this system.
3. **Hermes memory already in aggregator** — `scripts/aggregate.ts` already includes `/tmp/hermes-memory`, `/root/ulak/memories`, and `/root/.hermes/memory` as sources in `parseMemory()`. No code patch is needed unless the function is rewritten.
4. **Worker vs Container: Worker wins**. Check `cf-worker` header.
5. **Nixpacks `[start]`**: causes errors. Use `[phases.build]` only.
6. **SSR**: Vite preview catches all requests. Don't fetch `/live-data.json` in prod — use static import.
7. **`$NIXPACKS_SPA_OUTPUT_DIR`**: Railway-only. Hardcode path in Caddyfile.
8. **wrangler version** — run `wrangler --version` to check. Update with `npm i -g wrangler@latest` if needed.
