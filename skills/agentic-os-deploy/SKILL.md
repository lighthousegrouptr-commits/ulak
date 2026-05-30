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

Memory files live in two places on this machine. Both must be synced into `/tmp/hermes-memory/` for the aggregator to pick them up. Use **prefixed filenames** to avoid collisions when both sources have files with the same name (e.g. both have `MEMORY.md` and `USER.md`).

```bash
mkdir -p /tmp/hermes-memory
rm -f /tmp/hermes-memory/*.md   # clear stale files from previous runs

# Sync from both sources with collision-avoidance prefixes
for f in /root/ulak/memories/*.md; do
  [ -f "$f" ] && cp "$f" "/tmp/hermes-memory/ulak-$(basename "$f")"
done
for f in /root/.hermes/memories/*.md; do
  [ -f "$f" ] && cp "$f" "/tmp/hermes-memory/hermes-$(basename "$f")"
done
```

**Source paths** (verified as of May 2026):
- `/root/ulak/memories/` — ulak snapshot (MEMORY.md, USER.md). Always copy from here.
- `/root/.hermes/memories/` (plural, WITH trailing 's') — also exists with identical copies of MEMORY.md and USER.md. Copy from here too, with `hermes-` prefix.
- `/root/.hermes/memory/` (singular, NO trailing 's') — does **NOT** exist as a real directory (even though old versions of aggregate.ts listed it). The code was patched in May 2026 to also scan `/root/.hermes/memories` (plural).
- `/root/ulak/memory/` (singular) — does **NOT** exist.
- Skip `.lock` files — the `*.md` glob above handles this automatically.
- After sync, expect ~4 files in `/tmp/hermes-memory/`: `ulak-MEMORY.md`, `ulak-USER.md`, `hermes-MEMORY.md`, `hermes-USER.md`.

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

## Hermes Agent Skills Integration

The dashboard now also scans Hermes agent skills from `/root/.hermes/skills/` alongside `~/.claude/skills/`.

**How it works:**
- `aggregate.ts` `scanInstalledSkills()` calls `scanSkillsFromDir("/root/.hermes/skills")` alongside `~/.claude/skills/`
- Each subdirectory with a `SKILL.md` becomes an installed skill (e.g. `/agentic-os-deploy`, `/seo-audit`)
- Hermes skills get `uses7d: 0` since usage is tracked by Hermes platform, not Claude Code logs
- Default minutes are defined in `src/lib/time-saved.ts` `DEFAULT_MINUTES` for both Claude and Hermes skills
- Hourly rate default is $50/hr (changed from $120)

**Key difference:**
- Claude Code skills (`~/.claude/skills/`): slash commands like `/dream`, tracked via JSONL logs
- Hermes skills (`/root/.hermes/skills/`): agent capabilities, no slash command, usage count stays 0

## Reference Files

- `references/2026-05-31-hermes-skills-memory-tab.md` — Session notes: Hermes skills scanning, Ulak memory tab, default minutes ($50/hr), mobile input fix

## Pitfalls

1. **`bun` not on PATH** — use `/root/.bun/bin/bun` or export PATH. `which bun` returns nothing by default.
2. **Wrong memory path** — Use `/root/ulak/memories/` (plural). `/root/ulak/memory/` (singular) does NOT exist. NOTE: `~/.hermes/memories/` (plural, WITH the trailing 's') DOES exist and contains the same files as `/root/ulak/memories/`. Only copy from `/root/ulak/memories/` — do NOT also copy from `~/.hermes/memories/` to avoid duplicates.
3. **Hermes memory already in aggregator** — `scripts/aggregate.ts` already includes `/root/ulak/memories` and `/root/.hermes/memory` (note: singular 'memory') in `hermesMemDirs`. Add `/tmp/hermes-memory` to the list ONLY if it's populated from sources NOT already in the list. If `/tmp/hermes-memory` is copied from `/root/ulak/memories/` AND `/root/ulak/memories/` is already scanned, you'll get duplicate nodes in the memory graph. See pitfall #6.
4. **Cron script skips aggregate** — `cron-agentic-deploy.sh` does NOT run `aggregate.ts`. Run full pipeline manually.
5. **Missing source kind entry** — `src/routes/memory.tsx` has THREE places that enumerate sources (SourceId type, BASE_SOURCES, and the SourceFilter pillar). All three must be updated or the filter tab won't appear on the dashboard.
6. **Duplicate source from /tmp/hermes-memory** — If `/tmp/hermes-memory` is added to `hermesMemDirs` AND `/root/ulak/memories` is also in the list, the aggregate will index the same files twice (once under each path), producing duplicate nodes in the memory graph. Either: (a) remove `/root/ulak/memories` from the list if using `/tmp/hermes-memory`, or (b) verify `live-data.json` memory node count is sane after running the aggregator. A healthy single-source run shows ~2 Hermes memory nodes; duplicates will show 4+.
7. **Worker vs Container: Worker wins**. Check `cf-worker` header.
8. **Nixpacks `[start]`**: causes errors. Use `[phases.build]` only.
9. **SSR**: Vite preview catches all requests. Don't fetch `/live-data.json` in prod — use static import.
10. **`$NIXPACKS_SPA_OUTPUT_DIR`**: Railway-only. Hardcode path in Caddyfile.
11. **wrangler + Node.js** — `wrangler deploy` requires Node >= 22. VPS ships Node 20. wrangler v4.86.0 happens to work on Node 20 (no error), but this is not guaranteed. If deploy fails with Node version error, update wrangler: `npm i -g wrangler@latest` or use nvm to install Node 22.

12. **Skills page input too small for mobile** — The `minutes saved per run` input on the Skills page used `w-12` (48px) which is untappable on mobile. Fixed by replacing with `flex-1 min-w-[60px]` and setting `fontSize: "16px"` (inline style) to prevent iOS Safari zoom. Also added `WebkitAppearance: "none"` to prevent default mobile spinbutton styling that can obscure the value. Always test skill input forms on mobile viewport.

13. **Hermes skills show "installed" as lastUsed** — Skills from `/root/.hermes/skills/` have no usage logs, so `lastUsed` displays as "installed" instead of a relative timestamp. This is expected and correct. Do NOT try to derive usage from Hermes platform logs — the aggregate only reads Claude Code JSONL logs. If you need to distinguish Hermes from Claude skills in the UI, check for `lastUsed === "installed"` as a heuristic.
