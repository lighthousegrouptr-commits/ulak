# 2026-05-31 Cron Run — Full Refresh (Evening)

**Date:** 2026-05-31 (evening)
**Deploy Version ID:** `f6f59b9a-f57b-42d9-97ae-e8d27d72a41a`

## Summary

Full manual pipeline: memory sync → aggregate → build → deploy. Clean run.

## Aggregate Results

- **22 memory files** / **2 workspaces** / 0 Pinecone indexes / 14 events
- 2 Claude projects, 1,458 assistant messages
- Skills: 9 installed, 5 used in logs, 6 runs in last 7d
- Value extracted 7d: **$151.82**
- Claude auth: `api_key` mode

## Memory Source Paths Verified

All three active paths confirmed:
- `/root/ulak/memories/` → USER.md, MEMORY.md (1090 B, 1839 B)
- `/root/.hermes/memories/` → USER.md, MEMORY.md (+ .lock files)
- `/tmp/hermes-memory/` → synced copies (redundant with above two)

The `/root/.hermes/memory/` (singular) path does NOT exist — harmless in aggregator.

## Steady-State Notes

- 22 files and 2 workspaces is the **normal expected output** with all four `hermesMemDirs` active (including the redundant `/tmp` scan)
- Pipeline is stable and idempotent — multiple runs per day all produce the same 22/2 result
- No workaround changes needed since run 6+ (SKILL.md pitfalls all current)

## Build & Deploy

- Build: 2840 modules, ~11s, no errors. Non-critical chunk size warnings (three.module, react-force-graph-3d) are pre-existing
- Deploy: 21 uploaded assets, 54 already cached, 6 MB total. Version `f6f59b9a`
- Wrangler 4.86.0 (4.95.0 available but not blocking)

## What's New This Session

- Confirmed the `/tmp/hermes-memory` sync is functionally redundant (aggregator walks source dirs directly)
- Updated SKILL.md pitfall #6 to clarify 22 files = expected steady state, not an error
