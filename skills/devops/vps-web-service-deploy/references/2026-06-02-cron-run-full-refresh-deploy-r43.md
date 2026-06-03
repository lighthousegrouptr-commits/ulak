# Cron Run — Full Refresh & Deploy (r43)

**Date:** 2026-06-02 23:46
**Trigger:** Scheduled cron job
**Result:** ✅ Success

## Deploy Version
`7ef10c24-9242-4bc2-9212-f67e357e64a2`

## What Changed from Prior Runs

### wrangler deploy now requires `--config` flag
Bare `wrangler deploy` failed with:
```
ERROR: Found both a user configuration file at "wrangler.json"
  and a deploy configuration file at "../../.wrangler/deploy/config.json".
  But these do not share the same base path so it is not clear which should be used.
```

This happens because `wrangler.jsonc` at the project root AND `.wrangler/deploy/config.json` (persisted from previous runs) conflict.

**Fix:** Use explicit config flag:
```bash
cd /root/code/agentic-os && wrangler deploy --config dist/server/wrangler.json
```

### Memory stats
- 23 memory files / 2 workspaces / 14 events
- Source: `~/.hermes/memories/` copied to `/tmp/hermes-memory/`
- `/root/ulak/memory/` (singular) does NOT exist — correct path is `/root/ulak/memories/` (plural)

### Build output
- Vite 7.3.3, client build 10.82s, SSR 66ms
- Worker built: 15,822 bytes; 21 new/modified static assets uploaded (54 already uploaded)
