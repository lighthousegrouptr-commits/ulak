# Session r58: SPA Restore from Broken Minimal Worker

**Date**: 2026-06-03
**Result**: TanStack SPA restored as primary dashboard; minimal worker approach abandoned

## Timeline

1. User reported "bizde veri yok göremiyoruz browser dan" — no data visible in browser
2. `browser_navigate` to `agentic.lighthousegroup.net.tr` returned "Page not found" — Worker was gone
3. Multiple attempts to fix minimal HTML worker:
   - `</script>` escaping in template literals (failed — HTML parser closes script tag)
   - `<\/script>` escape (failed — same issue)
   - `<scr"+"ipt>` string concat (failed — template literal, not JS expression)
   - `${_s}` variable injection (failed — script content still 0)
   - External `<script src="/app.js">` (failed — Zaraz nullified the loaded content)
   - Base64 `eval(atob("..."))` (deployed but failed — Zaraz still broke execution)
4. Root cause: **Cloudflare Zaraz injects `/cdn-cgi/zaraz/s.js`** which blanks out all other script content (`textContent.length === 0`)
5. User said "Çözüm zor" — rejected the workaround approach
6. Offered two options: (1) Zaraz exclude, (2) restore TanStack SPA
7. User chose option 2: restore SPA
8. `bun run build` succeeded — full SPA with memory 3D, react-force-graph-3d, three.module
9. Had to patch `dist/server/wrangler.json` — Vite did NOT carry `kv_namespaces` or `routes`
10. `wrangler deploy` — config conflict with `.wrangler/` directory (deleted it, redeployed)
11. Dashboard loaded correctly with all data from build-time `live-data.json`
12. Data was stale (9 days old) — ran `bun run aggregate` to refresh, then rebuild + redeploy
13. **KV upload with `--remote` flag** — without it, data goes to local dev KV only

## Key Lessons

- **Vite does NOT reliably propagate `kv_namespaces`/`routes`** from `wrangler.jsonc` to `dist/server/wrangler.json`. Always verify post-build.
- **`rm -rf .wrangler` required** before deploy to avoid "Found both a user configuration file..." error
- **Zaraz breaks ALL inline/external script patterns** — only bundled SPA scripts survive
- **User prefers the original SPA over workarounds** when given the choice
- **KV namespace ID**: `df2bda58d7bb4abe91569c4c48c5bf5b` (LIVE_DATA)
- **Zone ID**: `6d59ce28d0fc5cdb1a71b401d7e5f366`
- **Account ID**: `32eb17ead96931c13af8500327096aaf`

## Post-deploy verification

```
https://agentic.lighthousegroup.net.tr → "Home — Agentic OS" ✅
https://agentic.lighthousegroup.net.tr/memory → "Memory — Agentic OS" ✅ (11 files indexed, 3D graph)
```
