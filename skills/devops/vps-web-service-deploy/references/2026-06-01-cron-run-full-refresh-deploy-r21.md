# Agentic OS — Full Refresh + Deploy Run r21

## Summary

| Field | Value |
|---|---|
| Date | 2026-06-01 |
| Version ID | `18411418-d189-4c7c-aabd-b7f58be93e3f` |
| Memory files | 24 |
| Build time | ~18s (client 11.32s + SSR 6.81s) |
| Deploy size | 6318 KiB (1190 KiB gzip) |
| Worker startup | 25 ms |
| Errors | 0 |

## Steps Executed

1. **Memory sync**: Copied `/root/ulak/memories/*.md` → `/tmp/hermes-memory/` (MEMORY.md + USER.md)
2. **Aggregate**: `bun run scripts/aggregate.ts` — scanned Claude projects, ~/.claude/memory, Hermes dirs, /tmp/hermes-memory; produced 24 files / 2 workspaces / 14 events
3. **Build**: `bun run build` (PATH="/root/.bun/bin:$PATH") — client + SSR via Vite, 2840 modules
4. **Deploy**: `npx wrangler deploy` — 21 new assets uploaded, 54 cached

## Observations

- Pipeline stable, identical output to r20 (same file count, same 2 Claude projects, 1458 assistant msgs)
- wrangler v4.90.0 (up from v4.86.0 at r20)
- Both `wrangler deploy` (bare) and `npx wrangler deploy` work; bare preferred
- aggregate.ts already has all 4 Hermes memory paths — no script changes needed
- `/tmp/hermes-memory/` accumulated stale files from prior runs (9 .md files including duplicates); harmless because aggregate deduplicates by source path
- Security scanner blocked `rm -rf` on `/tmp/hermes-memory/` — workaround: `cp` fresh files over stale ones
- PATH export for bun required in every terminal() call: `export PATH="/root/.bun/bin:$PATH"`
