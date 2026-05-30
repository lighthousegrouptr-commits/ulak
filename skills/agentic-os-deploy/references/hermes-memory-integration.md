# Hermes Memory Integration — Reference

## Verified Source Paths (May 2026)

| Path | Exists? | Contents | Notes |
|------|---------|----------|-------|
| `/root/ulak/memories/` | Yes | MEMORY.md, USER.md | Synced from `~/.hermes/` every 30 min via `ulak_sync.sh`. **Use this as the primary source.** |
| `/tmp/hermes-memory/` | If created | MEMORY.md, USER.md | Ephemeral staging dir. Created by the deploy pipeline. |
| `~/.hermes/memory/` | No | — | Does not exist on this system (verified May 2026). |
| `~/.hermes/memories/` | No | — | Does not exist on this system (verified May 2026). |
| `/root/ulak/memory/` | No | — | Singular form doesn't exist. Use `/root/ulak/memories/` (plural). |

## Sync Step

```bash
mkdir -p /tmp/hermes-memory
cp /root/ulak/memories/*.md /tmp/hermes-memory/
```

**DO NOT** use `~/.hermes/memories/` as the source — that path does not exist on this system (verified May 2026). Use `/root/ulak/memories/` which is the live ulak snapshot synced from `~/.hermes/` every 30 minutes.

Skip .lock files (they're empty anyway).

## Aggregate.ts Built-in Hermes Support

The aggregator (`scripts/aggregate.ts`, function `parseMemory()`) already includes these paths in the `hermesMemDirs` array (around line 1460):

```typescript
const hermesMemDirs = [
  "/root/ulak/memories",
  "/root/.hermes/memory",
];
```

**Note**: `/tmp/hermes-memory` was removed as a source in May 2026 because the aggregator now reads `/root/ulak/memories/` directly (synced from `~/.hermes/` every 30 min). The `/tmp/hermes-memory` staging directory is no longer needed.

**No further code patch is required** unless `parseMemory()` is rewritten from scratch.

## Source Kind Bug (Fixed May 31, 2026)

After adding Hermes paths to the aggregator, the Memory page was still missing the "Ulak" filter tab. Root cause: THREE separate hard-coded source lists existed and only two were updated:

1. `aggregate.ts` `MemSource` type — had `"hermes"` added ✓
2. `aggregate.ts` workspace/file source detection — had `"hermes-"` prefix checks ✓
3. `memory.tsx` `SourceId` type, `BASE_SOURCES`, `PINECONE_SOURCES` — **missing** ✗
4. `memory.tsx` `SourceFilter` component pills array — **missing** ✗
5. `memory.tsx` `matchesActive()` function — **missing** ✗
6. `memory-graph-3d.tsx` filter `matches()` function — **missing** ✗

**All six locations must be updated together.** The "Adding a New Source Filter Tab" section in SKILL.md documents the full checklist.

**Verification after deploy:**
- Memory page shows "All / Obsidian / Local Claude / Ulak" buttons
- "Ulak" pill is amber-colored (#F59E0B)
- Clicking "Ulak" shows only Hermes source nodes
- "All" includes Hermes nodes alongside others

## Sources Array Pitfall

When adding the Hermes source to `hermesMemDirs`, a duplicate `/tmp/hermes-memory` entry was already in the array from an earlier session's fix. The aggregator pushes ALL directories from `hermesMemDirs` into `sources`, so duplicates produce duplicate workspace nodes in the graph (same files appear under two workspace nodes). Always check `live-data.json`'s `memory.sources` array for duplicates after modifying `hermesMemDirs`.
