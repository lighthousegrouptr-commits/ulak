# Agentic OS Dashboard Debug Session — 2026-06-03 (r63)

## Problem
User reported dashboard showing no data, widgets empty, AI Spend $20 instead of expected ~$200.

## Root Cause
No Claude Code usage in last 7 days — all 1458 assistant messages are 7-30 days old. $0 cost is correct.

## Key Findings

### dist/server/index.js not overwritten by build
After `bun run build`, old static HTML (32KB) persists. Build reports "Worker built: 15822 bytes" for client bundle only. **Always verify**: `head -3 dist/server/index.js` should NOT show "Static dashboard server".

### KV not updated after aggregate
Aggregate writes to `src/data/live-data.json` but NOT to KV. Worker serves from KV. Must explicitly upload:
```
wrangler kv key put --namespace-id df2bda58d7bb4abe91569c4c48c5bf5b "live-data" --path src/data/live-data.json --remote
```

### $20 is subscription fee, not usage
`subscriptions.claude.monthlyPrice: 20` = Claude Pro plan cost. Not usage-based cost.

### Browser bot detection
Headless browser gets blank HTML from TanStack SPA. Old static HTML renders fine. Blank page ≠ broken dashboard.

## Fixes Applied
1. Memory graph: Added "hermes" to source filter buttons
2. Aggregate: Fixed Hermes workspace source labeling ("hermes" not "obsidian")
3. Deployed updated SPA
