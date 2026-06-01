# Agentic OS Full Refresh + Deploy — Run 25

## Summary

| Field | Value |
|---|---|
| **Date** | 2026-06-01 |
| **Version ID** | `828f7b8a-9587-4d54-bef6-0b964132e401` |
| **URL** | https://tanstack-start-app.lighthousegrouptr.workers.dev |
| **Memory** | 18 files / 2 workspaces / 14 events / 0 Pinecone indexes |
| **Build** | client 11.53s + SSR 7.77s = ~19.3s total |
| **Deploy** | 77 files scanned, 21 uploaded (54 already cached), 6510 KiB (1204 KiB gzip), 29ms startup, 29 modules |
| **wrangler** | v4.86.0 (update available: v4.96.0) |
| **Aggregator** | 2 Claude projects, 1458 assistant msgs, 8 skills installed, 5 used, 6 runs 7d, $36.77 value 7d |
| **Errors** | 0 |

## Pipeline Steps

1. **Memory sync**: Copied `/root/ulak/memories/` → `/tmp/hermes-memory/` (2 .md files). Note: cron task instructions incorrectly specified `/root/ulak/memory/` (singular) — actual path is `/root/ulak/memories/` (plural). `~/.hermes/memories/` already scanned directly by aggregate, so staging step is supplementary.
2. **Aggregate**: `export PATH="/root/.bun/bin:$PATH" && bun run scripts/aggregate.ts`
3. **Build**: `bun run build` (seed:data + vite build client + vite build SSR)
4. **Deploy**: `wrangler deploy` (bare, on PATH at `/usr/bin/wrangler`)

## Notes

- Memory files stable at 18 (same as r23, r24) — pipeline is consistent.
- `bun` again not found in PATH (cron environment). Workaround: `export PATH="/root/.bun/bin:$PATH"` — already established pattern.
- Value 7d: $36.77 (lower than r24's $124.39 — likely a quiet week).
- Pipeline fully stable, no new issues.

## Memory Sources (confirmed this run)

| Path | Exists | Files |
|------|--------|-------|
| `/root/ulak/memories/` | ✅ | 2 (.md) |
| `/root/.hermes/memories/` | ✅ | 2 (.md) |
| `/tmp/hermes-memory/` (staging) | ✅ | 2 (.md) |
| `/root/.hermes/memory/` (singular) | ❌ | Does NOT exist |
| `/root/ulak/memory/` (singular) | ❌ | Does NOT exist — common mistake in task descriptions |
| `~/.claude/memory/` | ❌ | Does NOT exist |
| `~/.claude/projects/-root/memory/` | ✅ | 12 (.md) |
