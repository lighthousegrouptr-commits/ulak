# Run 35 — Cron Full Refresh + Deploy

**Date**: 2026-06-02
**Version ID**: `6008ef9c-f988-4027-bb71-dfd30fe15164`
**URL**: https://tanstack-start-app.lighthousegrouptr.workers.dev

## Pipeline Summary

| Step | Status | Detail |
|------|--------|--------|
| Memory sync | ✅ | MEMORY.md + USER.md → `/tmp/hermes-memory/` |
| Aggregate | ✅ | 22 files / 4 workspaces / 14 events |
| Build | ✅ | client 11.85s + SSR 313ms |
| Deploy | ✅ | 23 uploaded (54 cached), 323.62 KiB, 21ms startup |

## Key Observations

1. **`bun run deploy` does not exist** — no `deploy` script in `package.json`. First attempt failed with `error: Script not found "deploy"`. Must use `npx wrangler deploy --outdir dist/client` directly.

2. **Bare `wrangler deploy` FAILS** — "Could not detect a directory containing static files". The TanStack Start build output is in `dist/client/`, not the project root. Wrangler can't auto-detect it. The fix: `npx wrangler deploy --outdir dist/client`. This contradicts r34 notes where bare `wrangler deploy` reportedly worked — possible wrangler v4.90 behavior change.

3. **`npx wrangler deploy --outdir dist/client`** — this is the correct, working command for this app going forward.

4. **wrangler v4.90.0** used (at `/usr/bin/wrangler`); `npx wrangler deploy` resolved to v4.90.0.

5. **Build time 11.85s** — faster than r34 (13.27s), consistent with r32-33 speeds.

6. **Memory: 22 files / 4 workspaces** — stable since r34.

## No Errors (after fix)

Clean run end-to-end once the correct deploy command was used.
