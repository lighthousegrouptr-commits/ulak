# Agentic OS — Full Refresh + Deploy Version Log

## Run History

| Run | Date | Version ID | Files | Build | Errors |
|---|---|---|---|---|---|
| r18 | 2026-06-01 | `79d6b034-5d9a-4eb6-aeb4-0aefdeb31303` | 20 | ~18s | 0 |
| r17 | 2026-06-01 | `719f6497` | 20 | ~18.5s | 0 |
| r16 | 2026-06-01 | `aebc499e` | 20 | 21.84s | 0 |
| r15 | 2026-06-01 | `d9dc598a` | 20 | 18.58s | 0 |
| r14 | 2026-06-01 | `27f74434` | 22 | 23.40s | 0 |

## Current State (r18)

- **Version ID**: `79d6b034-5d9a-4eb6-aeb4-0aefdeb31303`
- **URL**: https://tanstack-start-app.lighthousegrouptr.workers.dev
- **Memory**: 20 files / 2 workspaces / 14 events / 0 Pinecone indexes
- **Build**: client 10.94s + SSR 7.10s = ~18s total
- **Deploy**: 21 uploaded (54 cached), 6233 KiB (1184 KiB gzip), 20ms startup, 29 modules
- **Aggregator**: 2 Claude projects, 1458 assistant msgs, 8 skills installed, $148.17 value 7d
- **Deploy method**: `/root/.bun/bin/bun run build` + `wrangler deploy` (bare wrangler on PATH at `/usr/bin/wrangler` v4.86.0)
- **No errors at any stage**

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
