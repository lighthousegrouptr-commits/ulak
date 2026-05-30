# Hermes Memory Integration for Agentic OS Aggregate

## Source Paths

| Source | Path | Notes |
|--------|------|-------|
| Hermes live memories | `~/.hermes/memories/` | MEMORY.md, USER.md (+ .lock files) |
| Ulak synced snapshot | `/root/ulak/memories/` | Same files, synced every 30 min via cron |

**Do NOT use `/root/ulak/memory/`** — that directory does not exist.

## Sync Step

```bash
mkdir -p /tmp/hermes-memory
cp ~/.hermes/memories/MEMORY.md ~/.hermes/memories/USER.md /tmp/hermes-memory/
```

Skip .lock files (they're empty anyway).

## Aggregate.ts Patch

In `scripts/aggregate.ts`, inside the `parseMemory()` function, add after the Claude project memory dirs loop and before the `// Aggregate` comment:

```typescript
  // Hermes agent memory files
  const hermesMemDir = "/tmp/hermes-memory";
  if (existsSync(hermesMemDir)) sources.push({ root: hermesMemDir, label: "hermes" });
```

This makes the aggregator scan `/tmp/hermes-memory/` as a `hermes`-labeled workspace.

## Verification

After running `bun run scripts/aggregate.ts`, check:
- Log output includes `hermes` workspace
- `src/data/live-data.json` contains node with `"id": "ws-hermes-root"` and kind `"workspace"`
- File count increased by ~2-3 (MEMORY.md, USER.md, plus any extra .md files)

## Historical Note

This patch was first applied 2026-05-30. If `aggregate.ts` is ever rewritten (e.g. after a dependency update), re-add this source block in the same location.
