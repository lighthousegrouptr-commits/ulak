# Configuration notes for agentic-os

## Aggregate memory paths

The `scripts/aggregate.ts` scans multiple memory sources. For the Ulak/Hermes agent
memory to appear in the dashboard, these paths are configured:

```typescript
const hermesMemDirs = [
  "/root/ulak/memories",      // Ulak agent memory (primary)
  "/root/.hermes/memory",     // Legacy Hermes path
];
```

**Pitfall -- duplicate sources**: If two paths resolve to the same files, duplicate nodes
appear in the memory graph. Keep only one source path per physical directory.

**Pitfall -- workspace source kind**: Hermes workspaces default to `"obsidian"` kind.
Fix: add `"hermes"` to `MemSource` type and `startsWith("hermes-")` check.

## STALE_DAYS tuning

Default is 10 days. Increase to 30 for less stale noise on rarely-updated files.

## Deploy

Primary: Cloudflare Worker via `wrangler deploy`. No cache purge needed.
Cron: `agentic-wrangler-deploy` (30min) auto-builds + deploys.

## listen-data.json

Committed to git (un-ignored) because build container has no ~/.claude/.
Run aggregate locally before each commit for fresh data.

## Nixpaks Caddyfile

`.nixpacks/Caddyfile` (NOT `.nixpacks/assets/`). For runtime: `docker cp` + `docker restart`.
Use `handle` not `handle_path` for exact path matching.
