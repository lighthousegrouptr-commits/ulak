# Agentic OS Full Refresh + Deploy — Run 29

## Summary

| Field | Value |
|---|---|
| **Date** | 2026-06-02 |
| **Version ID** | `72419e42-a3c7-438f-b1cd-ebec50416ce7` |
| **URL** | https://tanstack-start-app.lighthousegrouptr.workers.dev |
| **Memory** | 18 files / 2 workspaces / 14 events / 0 Pinecone indexes |
| **Build** | client 11.69s + SSR 0.116s = ~11.81s total |
| **Deploy** | 77 files scanned, 21 uploaded (54 cached), 118.80 KiB (10.50 KiB gzip), 25ms startup, 29 modules (client) + 17 modules (SSR) |
| **wrangler** | v4.90.0 |
| **Aggregator** | 2 Claude projects, 1458 assistant msgs, 8 skills installed, 5 used, 2 runs 7d, $11.49 value 7d |
| **Errors** | 0 |

## Pipeline Steps

1. **Memory sync**: `rsync -a /root/ulak/memories/` + `rsync -a ~/.hermes/memories/` → `/tmp/hermes-memory/` (4 files: MEMORY.md, MEMORY.md.lock, USER.md, USER.md.lock)
2. **Aggregate**: `export PATH="/root/.bun/bin:$PATH" && bun run scripts/aggregate.ts` — scanned all 4 Hermes dirs + Claude projects automatically
3. **Build**: `export PATH="/root/.bun/bin:$PATH" && bun run build` (seed:data + vite build client + vite build SSR)
4. **Deploy**: `npx wrangler deploy`

## Notes

- Task description referenced `/root/ulak/memory/` (singular) — corrected to `/root/ulak/memories/` (known pitfall, documented in SKILL.md).
- `bun` not on PATH — `export PATH="/root/.bun/bin:$PATH"` in every terminal call.
- `npx wrangler deploy` used; wrangler v4.90.0. Both bare `wrangler deploy` and `npx wrangler deploy` work identically.
- Value 7d: $11.49 (down from r28's $13.18) — usage fluctuation, normal.
- Pipeline fully stable, no new issues.
- Memory counts stable at 18 files since r23 — Hermes/Ulak sources + Claude project memories consistent.
