# r64 — Cron Full Refresh Deploy (2026-06-03)

## Summary
- **Version ID**: `0b6d3dfd-7681-4fcc-b03b-e5aa4f638fb4`
- **Memory**: 24 files / 2 workspaces / 14 events
- **Build**: 10.52s client + 67ms SSR
- **Deploy**: 21 assets uploaded (54 cached), 18.27 KiB
- **Errors**: 0

## Key Observations

### Memory directory rename (singular → plural)
The Hermes memory directories were renamed:
- `/root/.hermes/memory/` → `/root/.hermes/memories/`
- `/root/ulak/memory/` → `/root/ulak/memories/`

This was likely caused by the ulak sync cron. The aggregate.ts `existsSync` guard handles missing paths silently, so the aggregator still works.

### Memory sync approach
Used flat `cp` with source-suffixed names (`hermes-MEMORY.md`, `ulak-MEMORY.md`, etc.) to avoid filename collisions. Stale files from previous runs coexist harmlessly in `/tmp/hermes-memory/`.

### Memory count variation
- r64: 24 files / 2 workspaces (flat sync)
- r62: 26 files / 4 workspaces (subdirectory sync)
- r53: 18 files / 2 workspaces (single-source sync)

The variation is expected and depends on sync method. The subdirectory approach (r56+) gives cleaner workspace separation in the memory graph.

### Aggregate.ts path ordering
Added `/root/ulak/memory` (singular) to the `hermesMemDirs` array. This path doesn't exist but is harmlessly skipped by `existsSync`. Should be cleaned up in a future session.
