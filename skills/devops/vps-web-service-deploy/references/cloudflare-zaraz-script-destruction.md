# Cloudflare Zaraz Script Destruction — Debugging Reference

**Date**: 2026-06-03
**Domain**: agentic.lighthousegroup.net.tr
**Worker**: tanstack-start-app
**Zone ID**: 6d59ce28d0fc5cdb1a71b401d7e5f366

## Problem

Zaraz (Cloudflare Web Analytics) injects `<script src="/cdn-cgi/zaraz/s.js?z=...">` and in the process **empties the textContent of other scripts on the page**. Both inline and `<script src="...">` external scripts are affected.

## Observed behavior

| Script type | textContent.length | Executed? |
|---|---|---|
| Inline `<script>var xhr=...<\/script>` | 0 | No |
| External `<script src="/app.js">` | 0 | No |
| Zaraz `/cdn-cgi/zaraz/s.js` | 0 (external) | Yes |

`fetch('/app.js')` returns correct JS (length 2713), but `<script src="/app.js">` in DOM has empty content — Zaraz intercepted and destroyed it.

## Root cause

Cloudflare Zaraz rewrites the page DOM during injection. It appears to strip or empty non-Zaraz `<script>` tags as part of its analytics bootstrapping. This is a Cloudflare platform behavior, not a worker bug.

## Solutions tried (in order)

| Approach | Result | Why |
|---|---|---|
| Inline JS in `<script>` tag | Failed | Zaraz empties textContent |
| `<script src="/app.js">` external | Failed | Zaraz blocks loading (contentLen=0 in DOM) |
| `${_s}` with `_s='</script>'` | Failed | Still outputs literal `</script>` |
| `eval(atob(base64))` | **Pending deploy** | Zaraz cannot see/modify base64 payload |
| Zaraz exclude in dashboard | **Pending user action** | Requires Cloudflare dashboard access |

## Recommended fix

1. **Immediate (code)**: Use `eval(atob(base64EncodedJS))` pattern in Worker:
   ```js
   const b64 = Buffer.from(appJS).toString('base64');
   // In HTML: <script>eval(atob("${b64}"))<\/script>
   ```
   The `<\/script>` escape prevents HTML parser from prematurely closing the tag.

2. **Permanent (dashboard)**: Cloudflare Dashboard → lighthousegroup.net.tr → Speed → Web Analytics → Exclude `agentic.lighthousegroup.net.tr/*`

## Diagnostic commands

```js
// In browser console on the dashboard page:
var scripts = document.querySelectorAll('script');
for (var i = 0; i < scripts.length; i++) {
  console.log(scripts[i].src || '(inline)', 'len:', scripts[i].textContent.length);
}
// If your script has len 0 and /cdn-cgi/zaraz/ scripts exist → Zaraz issue

// Verify JS endpoint works independently:
fetch('/app.js').then(r => r.text()).then(t => console.log('len:', t.length))
```

## Worker pattern (eval+atob)

```js
// In worker-new.js
function buildAppJS() {
  return `
var xhr = new XMLHttpRequest();
xhr.open('GET', '/data/live-data.json', false);
xhr.setRequestHeader('Cache-Control', 'no-store');
try {
  xhr.send();
  if (xhr.status === 200) {
    var data = JSON.parse(xhr.responseText);
    // ... render logic ...
  }
} catch(e) {
  document.getElementById('status').textContent = 'Error: ' + e.message;
}`;
}

function buildDashboardHTML() {
  const b64 = Buffer.from(buildAppJS()).toString('base64');
  return `<!DOCTYPE html>
<html>
<head>...</head>
<body>
<div id="root"></div>
<script>eval(atob("${b64}"))<\/script>
</body>
</html>`;
}
```

## wrangler-minimal.jsonc pattern

When deploying a standalone worker (bypassing TanStack build):
```json
{
  "name": "tanstack-start-app",
  "compatibility_date": "2025-09-24",
  "compatibility_flags": ["nodejs_compat"],
  "main": "worker-new.js",
  "routes": [
    { "pattern": "agentic.lighthousegroup.net.tr/*", "zone_name": "lighthousegroup.net.tr" }
  ],
  "kv_namespaces": [
    { "binding": "LIVE_DATA", "id": "df2bda58d7bb4abe91569c4c48c5bf5b" }
  ]
}
```

Deploy with: `npx wrangler deploy --config wrangler-minimal.jsonc`
