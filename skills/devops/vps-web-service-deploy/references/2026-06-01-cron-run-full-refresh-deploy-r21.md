# Agentic OS — Full Refresh + Deploy Run r21

## Summary

| Field | Value |
|---|---|
| Date | 2026-06-01 |
| Version ID | `e9d15cff-cc75-498c-b12a-5b9b6b2bee71` |
| Memory files | 24 |
| Build time | ~17.6s (client 10.88s + SSR 6.76s) |
| Deploy size | 6297 KiB (1188 KiB gzip) |
| Errors | 0 |

## Steps Executed

1. **Memory sync**: Copied `~/.hermes/memories/*.md` → `/tmp/hermes-memory/` (8 .md files including Hermes + Ulak snapshots)
2. **Aggregate**: `bun run scripts/aggregate.ts` — scanned 4 sources (claude projects/-root/memory, ulak/memories, hermes/memories, tmp/hermes-memory), produced 24 files / 2 workspaces / 14 events
3. **Build**: `bun run build` — client + SSR via Vite, 2840 modules transformed
4. **Deploy**: `npx wrangler deploy` — 21 new assets uploaded, 54 cached

## Observations

- Pipeline stable, identical output to r20
- wrangler v4.90.0 (up from v4.86.0 at r20)
- Task spec path `/root/ulak/memory/` (singular) still wrong — corrected to `/root/ulak/memories/` at execution (known pitfall, documented in skill)
- Both `wrangler deploy` (bare) and `npx wrangler deploy` work; bare preferred
