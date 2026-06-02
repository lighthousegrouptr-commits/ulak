# Cloudflare Worker: Serving HTML with Inline JS — The `</script>` Problem

## Problem

When baking an HTML dashboard into a Cloudflare Worker as an inline JS string, `JSON.stringify(html)` does **not** escape `</script>` or `</style>` tags. These appear literally inside the JS string, and when the Worker outputs the HTML to the browser, the browser's HTML parser sees them as closing tags — prematurely terminating the `<script>` or `<style>` block.

Symptoms:
- Dashboard HTML renders, but all JS values stay at their default placeholders ("—")
- Browser JS appears to not run at all

## Why `<\\/script>` Does NOT Work

Replacing `</script>` with `<\\/script>` in the JSON string does NOT work. The HTML parser still recognizes the closing tag. The only reliable fix is to keep `</script>` out of the HTML response entirely.

## Correct Fix: Separate JS Endpoint

Serve JS from a separate Worker endpoint (`/__app_js`) and load via synchronous XHR + `eval()`. Since the JS is a separate plain-text response (not inside a `<script>` HTML block), `</script>` in it is just text.

**`scripts/build-worker.mjs` pattern:**

```js
const scriptMatch = html.match(/<script>([\s\S]+?)<\/script>/);
const jsCode = scriptMatch[1].trim();

// Replace inline script with XHR loader
html = html.replace(
  /<script>[\s\S]+?<\/script>/,
  '<script>var _r=new XMLHttpRequest();_r.open("GET","/__app_js",false);_r.send();eval(_r.responseText);<\/script>'
);
writeFileSync("dist/client/dashboard.html", html);
const dashboardHtml = readFileSync("dist/client/dashboard.html", "utf-8");

const workerCode = `const DASHBOARD_HTML = ${JSON.stringify(dashboardHtml)};
const APP_JS = ${JSON.stringify(jsCode)};
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (url.pathname === "/__app_js") return new Response(APP_JS, { headers: {"Content-Type":"application/javascript"} });
    if (url.pathname === "/data/live-data.json") { /* KV fetch */ }
    return new Response(DASHBOARD_HTML, { headers: {"Content-Type":"text/html"} });
  },
};
`;
writeFileSync("dist/server/index.js", workerCode);

// Patch wrangler.json with KV binding
const wj = JSON.parse(readFileSync("dist/server/wrangler.json","utf-8"));
if (!wj.kv_namespaces) wj.kv_namespaces = [];
wj.kv_namespaces.push({ binding: "LIVE_DATA", id: "<KV_ID>" });
writeFileSync("dist/server/wrangler.json", JSON.stringify(wj, null, 2));
```

Verified working (2026-06-02).

## KV Namespace Binding

Vite-generated `dist/server/wrangler.json` does NOT include `kv_namespaces`. Build script must patch it.

## KV Writes: `--remote` Required

`wrangler kv key put` without `--remote` writes to local dev KV, not production.
