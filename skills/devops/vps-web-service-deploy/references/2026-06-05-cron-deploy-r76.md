# Agentic OS — Cron Deploy r76

**Date:** 2026-06-05
**Version ID:** `ad098804-e137-41ba-9a53-86bd630d0182`
**wrangler:** v4.86.0

## Summary

Cron full-refresh deploy — clean run, zero errors.

## Pipeline Results

| Step | Result |
|------|--------|
| Memory sync | 2 files copied to `/tmp/hermes-memory/` (USER.md, MEMORY.md from `~/.hermes/memories/`) |
| Aggregate | 18 memory files / 2 workspaces / 14 events / 2 projects (1690 assistant msgs) |
| Build | 2840 modules, 10.6s |
| Deploy | 21 new assets uploaded, 54 cached, 9.57s total |

## Memory File Count Breakdown

The aggregate found 18 `.md` files across these sources:
- `~/.claude/projects/` — Claude project memory dirs
- `/root/ulak/memories/` — Ulak snapshot (USER.md, MEMORY.md)
- `/root/.hermes/memories/` — Live Hermes memories (USER.md, MEMORY.md)
- `/tmp/hermes-memory/` — Staging (USER.md, MEMORY.md + .lock files)

Note: The Hermes memory dirs contain the same files (USER.md, MEMORY.md) in both locations, so the 18 count includes duplicates across sources. The aggregate deduplicates by workspace ID.

## Notes

- `export PATH="$PATH:/root/.bun/bin"` prefix used for bun commands (documented pattern)
- `wrangler deploy` from project root — auto-redirects to `dist/server/wrangler.json`
- No `.wrangler` cleanup needed (clean run)
- Lock files (`.lock`) in `/tmp/hermes-memory/` are harmless — walker only picks up `.md` files
- Value extracted last 7d: $9.13
- Skills: 24 installed, 21 used in logs, 21 runs in last 7d
