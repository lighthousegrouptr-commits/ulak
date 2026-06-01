# Agentic OS — Full Refresh + Deploy Version Log

## Run History

| Run | Date | Version ID | Files | Build | Errors |
|---|---|---|---|---|---|
| r14 | 2026-06-01 | `27f74434` | 22 | 23.40s | 0 |

## Current State (r14)

- **Version ID**: `27f74434-8c48-4a2d-aa03-ed7f4102d720`
- **URL**: https://tanstack-start-app.lighthousegrouptr.workers.dev
- **Memory**: 22 files / 2 workspaces / 14 events / 0 Pinecone indexes
- **Build**: client 11.97s + SSR 11.43s = 23.40s total
- **Deploy**: 29 uploaded (73 cached), 8696 KiB (1907 KiB gzip), 13ms startup, 53 modules

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
