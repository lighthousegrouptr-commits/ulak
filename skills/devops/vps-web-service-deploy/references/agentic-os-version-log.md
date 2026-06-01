# Agentic OS — Full Refresh + Deploy Version Log

## Run History

| Run | Date | Version ID | Files | Build | Errors |
|---|---|---|---|---|---|
| r17 | 2026-06-01 | `719f6497` | 20 | ~18.5s | 0 |
| r16 | 2026-06-01 | `aebc499e` | 20 | 21.84s | 0 |
| r15 | 2026-06-01 | `d9dc598a` | 20 | 18.58s | 0 |
| r14 | 2026-06-01 | `27f74434` | 22 | 23.40s | 0 |

## Current State (r17)

- **Version ID**: `719f6497-f383-41c5-9401-38e0dec46eb4`
- **URL**: https://tanstack-start-app.lighthousegrouptr.workers.dev
- **Memory**: 20 files / 2 workspaces / 14 events / 0 Pinecone indexes
- **Build**: client 11.72s + SSR 6.79s = ~18.5s total
- **Deploy**: 21 uploaded (54 cached), 6148.68 KiB (1177.19 KiB gzip), 19ms startup, 29 modules
- **Aggregator**: 2 Claude projects, 1458 assistant msgs, 8 skills installed, $151.82 value 7d
- **Deploy method**: `npx wrangler deploy` (bun PATH export needed; npx resolves wrangler v4.90.0)
- **Task spec path error**: Spec referenced `/root/ulak/memory/` (singular, nonexistent) — corrected to `/root/.hermes/memories/` per SKILL.md pitfall. 5th+ occurrence of this error in cron specs.

## r14 Fix — Tanstack Start SSR wrangler.jsonc

The `wrangler.jsonc` had a stale `main: "src/server.ts"` which caused wrangler auto-config to fail with "Could not detect a directory containing static files". Fixed by updating to:

```jsonc
{
  "name": "tanstack-start-app",
  "compatibility_date": "2025-09-24",
  "compatibility_flags": ["nodejs_compat"],
  "main": "dist/server/index.js",
  "no_bundle": true,
  "rules": [
    { "type": "ESModule", "globs": ["dist/server/assets/**/*.js"] }
  ]
}
```

Key: `no_bundle: true` + ES module rules (not `assets` config — that's for Workers Sites static files, not ES modules). Also removed conflicting `.wrangler/deploy/config.json`.
