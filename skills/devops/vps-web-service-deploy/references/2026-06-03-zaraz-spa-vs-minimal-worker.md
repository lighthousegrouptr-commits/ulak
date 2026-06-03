# Zaraz vs Minimal Worker vs TanStack SPA (2026-06-03)

## Problem
`agentic.lighthousegroup.net.tr` showed "Agentic Dashboard" heading but no data — empty cards, no models, no KPIs.

## Root Cause
Cloudflare Zaraz (Web Analytics) injects `<script src="/cdn-cgi/zaraz/s.js">` into the page and **destroys the content of existing script tags**. Both inline and external (`<script src="/app.js">`) scripts end up with `textContent.length === 0` in the DOM.

## Failed Workarounds (do NOT repeat)

| Approach | Why it fails |
|----------|-------------|
| Inline `<script>code</script>` | Zaraz blanks the script content |
| `<script src="/app.js">` | Zaraz blocks loading — `contentLen=0` in DOM even though `fetch('/app.js')` returns correct JS |
| `eval(atob(base64Encoded))` | Zaraz still somehow interferes, `eval` throws exception with empty message |
| `${_s}` where `_s = '</script>'` | HTML parser still closes the script tag |
| Synchronous XHR for data | Works in isolation but Zaraz kills the script before it runs |

User explicitly rejected this complexity: **"Çözüm zor"**

## Correct Solution

Deploy the **original TanStack SPA** (`bun run build` + `wrangler deploy`). React SSR generates HTML with bundled script references (`<script type="module" src="/assets/entry-XXXX.js">`) that Zaraz doesn't destroy. The SPA includes memory 3D visualizations, full dashboard UI, and all original features.

Key: after `bun run build`, patch `dist/server/wrangler.json` to add KV binding and route (Vite doesn't carry these from `wrangler.jsonc`).

## Zaraz Exclude (alternative / additional)

If Zaraz still causes issues with the SPA, exclude the subdomain:
- Cloudflare Dashboard → lighthousegroup.net.tr → Speed → Optimization → Web Analytics (Zaraz) → Settings → **Exclude Pages**: `agentic.lighthousegroup.net.tr/*`
- This does NOT affect the main domain or other subdomains.

## Diagnostic

```js
// In browser console
var scripts = document.querySelectorAll('script');
for (var i = 0; i < scripts.length; i++) {
  console.log(scripts[i].src || '(inline)', 'len:', scripts[i].textContent?.length || 0);
}
// If your script has length 0 and /cdn-cgi/zaraz/s.js is present → Zaraz injection
```

## Zone IDs
- lighthousegroup.net.tr: `6d59ce28d0fc5cdb1a71b401d7e5f366`

## KV Namespace
- Binding: `LIVE_DATA`
- ID: `df2bda58d7bb4abe91569c4c48c5bf5b`
