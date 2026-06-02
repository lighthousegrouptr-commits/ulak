# Configuration notes for agentic-os

## Aggregate memory paths

The `scripts/aggregate.ts` scans multiple memory sources. As of the latest config:

```typescript
// Claude project-scanned memory dirs (~/.claude/projects/*/memory) — existing
// Claude global memory dir (~/.claude/memory/) — added 2026-05-31, may not exist yet
if (existsSync(join(CLAUDE_DIR, "memory"))) {
  sources.push({ root: join(CLAUDE_DIR, "memory"), label: "claude" });
}

const hermesMemDirs = [
  "/root/ulak/memories",       // Ulak agent memory (git mirror, syncs every 30min)
  "/root/.hermes/memories",    // Live Hermes agent memory (MEMORY.md, USER.md)
  "/root/.hermes/memory",      // Legacy Hermes path (singular) — does NOT exist on this VPS
  "/tmp/hermes-memory",        // Staging: combined dump from all sources on each deploy
];
```

**Pitfall -- memory dir naming**: The live Hermes dir is `memories/` (plural) at
`/root/.hermes/memories/`. The legacy path uses `memory/` (singular) — does NOT exist on this VPS,
but the scanner checks it anyway for portability. Similarly, `~/.claude/memory/` doesn't exist
yet but is included for future use.

**Pitfall -- duplicate sources**: If two paths resolve to the same files, duplicate nodes
appear in the memory graph. Keep only one source path per physical directory.

**Pitfall -- workspace source kind**: Hermes workspaces default to `"obsidian"` kind.
Fix: add `"hermes"` to `MemSource` type and `startsWith("hermes-")` check.

## Bun PATH gotcha

`bun` is at `/root/.bun/bin/bun`, NOT on PATH. Every invocation needs:
```bash
export PATH="/root/.bun/bin:$PATH"
```
before `bun run scripts/aggregate.ts`, `bun run build`, `bun run dev`, etc.

## STALE_DAYS tuning

`STALE_DAYS = 30` (set at line ~624). Files older than 30 days are marked stale in the memory graph.
Increase if rarely-updated knowledge files trigger too many stale warnings.

## Deploy

Primary: Cloudflare Worker via bare `wrangler deploy` (no `--outdir` flag needed).

```bash
cd /root/code/agentic-os
export PATH="/root/.bun/bin:$PATH"
bun run build          # produces dist/server/ + dist/client/
wrangler deploy        # uploads to Cloudflare Workers CDN
```

**`CLOUDFLARE_API_TOKEN` check:** Before deploying, verify the token is set (`echo $CLOUDFLARE_API_TOKEN`). If empty, `source /root/.profile 2>/dev/null` first. In sessions where the token is already in the environment (e.g. some cron contexts), `wrangler deploy` works without sourcing.

- wrangler is on PATH at `/usr/bin/wrangler` (v4.86+)
- Auth: `lighthousegrouptr@gmail.com` (stored in `~/.wrangler/`)
- Deploy is immediate — new version goes live globally within ~30s
- No Cloudflare cache purge needed for Worker deploys

**Do NOT use `--outdir dist/client`** — this flag was a previous workaround and is no longer needed (as of r40, 2026-06-02).

Cron: `agentic-wrangler-deploy` (30min) auto-builds + deploys.

## live-data.json

Committed to git (un-ignored) because build container has no ~/.claude/.
Run aggregate locally before each commit for fresh data.

## Nixpacks Caddyfile

`.nixpacks/Caddyfile` (NOT `.nixpacks/assets/`). For runtime: `docker cp` + `docker restart`.
Use `handle` not `handle_path` for exact path matching.
