# r17 — Agentic OS Full Refresh & Deploy

**Date:** 2026-06-01 ~14:40 TZ
**Version ID:** `79d6b034-5d9a-4eb6-aeb4-0aefdeb31303`
**Build time:** 10.94s (client) + 7.10s (SSR) = ~18s total
**Total upload:** 6233 KiB / gzip 1184 KiB

## Memory sources

| Source | Files | Notes |
|--------|-------|-------|
| `/tmp/hermes-memory/` | 4 | Staged: MEMORY.md, USER.md from both `~/.hermes/memories/` and `/root/ulak/memories/` |
| `/root/.hermes/memories/` | 2 | Live Hermes memory |
| `/root/ulak/memories/` | 2 | Ulak snapshot (30-min sync) |
| `~/.claude/projects/*/memory/` | 12 | Per-project memory dirs |

**Total memory files:** 20 across 2 workspaces

## Skills

- 8 installed, 5 used in logs, 6 runs in last 7d

## Usage

- 2 Claude projects, 1,458 assistant messages
- Value extracted 7d: $148.17

## Notes

- `bun` not on PATH — used `/root/.bun/bin/bun` directly
- `aggregate.ts` already has all Hermes paths wired in (lines 1474-1482) — the `/tmp/hermes-memory/` staging step is supplementary, not required
- No errors at any stage
- Wrangler 4.86.0 (update to 4.95.0 available, non-blocking)
