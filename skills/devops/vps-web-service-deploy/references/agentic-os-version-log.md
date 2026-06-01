# Agentic OS — Full Refresh + Deploy Version Log

## Run History

| Run | Date | Version ID | Files | Build | Errors |
|---|---|---|---|---|---|
| r16 | 2026-06-01 | `aebc499e` | 20 | 21.84s | 0 |
| r15 | 2026-06-01 | `d9dc598a` | 20 | 18.58s | 0 |
| r14 | 2026-06-01 | `27f74434` | 22 | 23.40s | 0 |

## Current State (r16)

- **Version ID**: `aebc499e-4765-4f9c-91b5-b273398bc8b9`
- **URL**: https://tanstack-start-app.lighthousegrouptr.workers.dev
- **Memory**: 20 files / 2 workspaces / 14 events / 0 Pinecone indexes
- **Build**: client 13.18s + SSR 8.66s = 21.84s total
- **Deploy**: 21 uploaded (54 cached), 6128 KiB (1176 KiB gzip), 15ms startup, 29 modules
- **Aggregator**: 2 Claude projects, 1458 assistant msgs, 8 skills installed, $151.82 value 7d
- **`npx wrangler deploy`** also works (resolves to globally installed wrangler v4.90.0) — but per skill convention, bare `wrangler deploy` is preferred since `wrangler` is on PATH at `/usr/bin/wrangler`

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
