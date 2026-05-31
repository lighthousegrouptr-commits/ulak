# Configuration notes for agentic-os

## Aggregate memory paths

The `scripts/aggregate.ts` scans multiple memory sources. As of the latest config:

```typescript
const hermesMemDirs = [
  "/root/ulak/memories",       // Ulak agent memory (git mirror, syncs every 30min)
  "/root/.hermes/memories",    // Live Hermes agent memory (MEMORY.md, USER.md)
  "/root/.hermes/memory",      // Legacy Hermes path (singular)
  "/tmp/hermes-memory",        // Staging: combined dump from all sources on each deploy
];
```

**Pitfall -- memory dir naming**: The live Hermes dir is `memories/` (plural) at
`/root/.hermes/memories/`. The legacy path uses `memory/` (singular). Don't mix them up.

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

Default is 10 days. Increase to 30 for less stale noise on rarely-updated files.

## Deploy

Primary: Cloudflare Worker via `npx wrangler deploy`. No cache purge needed.
Cron: `agentic-wrangler-deploy` (30min) auto-builds + deploys.

## live-data.json

Committed to git (un-ignored) because build container has no ~/.claude/.
Run aggregate locally before each commit for fresh data.

## Nixpacks Caddyfile

`.nixpacks/Caddyfile` (NOT `.nixpacks/assets/`). For runtime: `docker cp` + `docker restart`.
Use `handle` not `handle_path` for exact path matching.
