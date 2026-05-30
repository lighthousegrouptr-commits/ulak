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
cp ~/.hermes/memories/*.md /tmp/hermes-memory/
```

**Source paths** (not `/root/ulak/memory/` — that path does not exist):
- `~/.hermes/memories/` — live Hermes memory (MEMORY.md, USER.md)
- `/root/ulak/memories/` — synced ulak snapshot (also has MEMORY.md, USER.md)
- One file will be `MEMORY.md.lock` / `USER.md.lock` (empty lock files, harmless)

### 2. Ensure Aggregate Includes Hermes Memory

The aggregator (`scripts/aggregate.ts`) scans `~/.claude/projects/*/memory/` and Obsidian vaults natively.
For Hermes memories, add this source block in `parseMemory()` (between the Claude project dirs and the `// Aggregate` comment):

```typescript
  // Hermes agent memory files
  const hermesMemDir = "/tmp/hermes-memory";
  if (existsSync(hermesMemDir)) sources.push({ root: hermesMemDir, label: "hermes" });
```

See [references/hermes-memory-integration.md](references/hermes-memory-integration.md) for source paths, verification steps, and the patch location diagram.

### 3. Run Aggregator

```bash
cd /root/code/agentic-os && bun run scripts/aggregate.ts
```

Expected output includes: `memory: N files / M workspaces` — verify `hermes` workspace appears.

### 4. Build

```bash
bun run build
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
2. **Wrong memory path** — Hermes memories are at `~/.hermes/memories/`, not `/root/ulak/memory/`.
3. **Worker vs Container: Worker wins**. Check `cf-worker` header.
4. **Nixpacks `[start]`**: causes errors. Use `[phases.build]` only.
5. **SSR**: Vite preview catches all requests. Don't fetch `/live-data.json` in prod — use static import.
6. **`$NIXPACKS_SPA_OUTPUT_DIR`**: Railway-only. Hardcode path in Caddyfile.
7. **Aggregate `parseMemory()` patch** — if the function is rewritten, the Hermes source block must be re-added at the same location (after Claude project dirs, before `// Aggregate`).
8. **wrangler version** — run `wrangler --version` to check. Update with `npm i -g wrangler@latest` if needed.
