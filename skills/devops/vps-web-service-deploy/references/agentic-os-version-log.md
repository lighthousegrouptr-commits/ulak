# Agentic OS — Full Refresh + Deploy Version Log

## Run History

| Run | Date | Version ID | Files | Build | Errors |
|---|---|---|---|---|---|
| r14 | 2026-06-01 | `27f74434` | 22 | 23.40s | 0 |
| r15 | 2026-06-01 | `d9dc598a` | 20 | 18.58s | 0 |

## Current State (r15)

- **Version ID**: `d9dc598a-7259-4ba9-841a-718dfa3eee86`
- **URL**: https://tanstack-start-app.lighthousegrouptr.workers.dev
- **Memory**: 20 files / 2 workspaces / 14 events / 0 Pinecone indexes
- **Build**: client 11.92s + SSR 6.66s = 18.58s total
- **Deploy**: 21 uploaded (54 cached), 6085 KiB (1172 KiB gzip), 15ms startup, 29 modules

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
