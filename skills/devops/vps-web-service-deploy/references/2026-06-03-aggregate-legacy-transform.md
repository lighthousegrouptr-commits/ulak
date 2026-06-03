# Aggregate → Legacy Data Transform (2026-06-03)

## Problem

`scripts/aggregate.ts` produces a **new-format** `live-data.json` (arrays, nested objects), but the Worker's inline `APP_JS` (in `dist/server/index.js`) expects a **legacy format** (flat objects keyed by name/date). Mismatch causes all dashboard fields to show "—".

## Data format comparison

| Field | New format (aggregate.ts) | Legacy format (APP_JS expects) |
|---|---|---|
| `modelUsage` | `[{model, messages, input_tokens, ...}]` | `{"claude-opus-4-7": {messages, input_tokens, ...}}` |
| `daily` | `[{day, tokens, messages, cost}]` | `{"2026-05-25": {tokens, messages, cost}}` |
| `recentProjects` | `[{key, displayName, sessions, messages, lastActiveMs}]` | `{"-root": {sessions, messages, lastActiveMs}}` |
| `skills.active` | `[{name, uses7d, ...}]` | `skills.installed: string[]`, `skills.invoked: string[]` |
| `memory.stats` | `{totalFiles, totalWorkspaces, totalVectors, stale}` | `memory.fileCount`, `memory.workspaceCount`, `memory.pineconeVectorCount` |
| `summary` | `{totalAssistantMessages, messagesLast5h, ...}` | `usage.assistantTurnsLast5h`, `usage.totalAssistant`, etc. |
| `detection` | `{apps: {name: {detected: bool}}, envKeysPresent: [], envKeysNeeded: []}` | `apps: string[]`, `envKeys: {present, needed, missing}` |

## Solution

`scripts/transform-live-data.ts` reads `src/data/live-data.json` and writes `src/data/live-data-legacy.json` in the format APP_JS expects.

### Full deploy pipeline

```bash
cd /root/code/agentic-os
export PATH="/root/.bun/bin:$PATH"

# 1. Aggregate fresh data
bun run scripts/aggregate.ts

# 2. Transform to legacy format
bun run scripts/transform-live-data.ts

# 3. Upload legacy data to KV
LEGACY=$(cat src/data/live-data-legacy.json)
wrangler kv key put --binding=LIVE_DATA --remote "live-data" "$LEGACY"

# 4. Deploy worker (includes updated APP_JS)
wrangler deploy
```

### KV verification

```bash
wrangler kv key get --binding=LIVE_DATA --remote "live-data" | head -20
```

## APP_JS uses XHR, not fetch

The inline `APP_JS` in `dist/server/index.js` uses **synchronous XHR** (`XMLHttpRequest` with `open(..., false)`) to fetch `/data/live-data.json`, NOT `fetch()`. This is intentional — `fetch()` was observed to never resolve/reject when called from the Worker-served page, while XHR works reliably.

If you modify APP_JS, keep the XHR pattern:
```js
var xhr = new XMLHttpRequest();
xhr.open('GET', '/data/live-data.json?_=' + Date.now(), false);
xhr.send();
if (xhr.status !== 200) throw new Error('HTTP ' + xhr.status);
var d = JSON.parse(xhr.responseText);
```

## APP_JS delivery pattern

APP_JS is NOT embedded inline in HTML. Instead:
1. HTML contains: `var _r=new XMLHttpRequest();_r.open('GET','/__app_js',false);_r.send();eval(_r.responseText);`
2. Worker handles `/__app_js` endpoint, returns APP_JS as `application/javascript`
3. This avoids `</script>` escaping issues

## Pitfall: dist/server/wrangler.json override

`wrangler deploy` uses `dist/server/wrangler.json` (Vite-generated), NOT `wrangler.jsonc`. The Vite config has `"main": "index.js"` with assets. To deploy a custom worker, either overwrite `dist/server/index.js` or patch `dist/server/wrangler.json`.
