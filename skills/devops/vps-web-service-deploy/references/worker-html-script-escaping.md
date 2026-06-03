# Cloudflare Worker: Serving HTML with Inline JS — The `</script>` Problem

## Problem

When baking an HTML dashboard into a Cloudflare Worker as an inline JS string, `JSON.stringify(html)` does **not** escape `</script>` or `</style>` tags. These appear literally inside the JS string, and when the Worker outputs the HTML to the browser, the browser's HTML parser sees them as closing tags — prematurely terminating the `<script>` or `<style>` block.

Symptoms:
- Dashboard HTML renders, but all JS values stay at their default placeholders ("—")
- Browser JS appears to not run at all

## What Does NOT Work

| Attempt | Result |
|---------|--------|
| `<\/script>` in JS string | Still recognized by HTML parser |
| `` ${_s} `` where `_s = '</script>'` | Still outputs literal `</script>` |
| `<scr"+"ipt>` | Not valid JS in template literals |
| `eval(XHR.responseText)` | Fails silently in browser/CF contexts |
| `JSON.stringify(html).replace('</script>', '<\\/script>')` | Backslash is not a valid HTML escape |

## Correct Fix: External JS Endpoint + `<script src="">`

**The ONLY reliable pattern is `<script src="/endpoint">`:**

```js
// Worker code (dist/server/index.js)
const HTML = `<!DOCTYPE html>
<html>
<head><title>Dashboard</title></head>
<body>
  <div id="status"></div>
  <script src="/app.js"></script>
</body>
</html>`;

const APP_JS = `function loadData(){
  var xhr=new XMLHttpRequest();
  xhr.open('GET','/data/live-data.json?t='+Date.now(),false);
  xhr.send();
  if(xhr.status!==200){document.getElementById('status').textContent='HTTP '+xhr.status;return}
  var d=JSON.parse(xhr.responseText);
  if(!d||!d.meta){document.getElementById('status').textContent='No data';return}
  // ... populate DOM ...
}
loadData();
setInterval(loadData,60000);`;

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (url.pathname === "/app.js") {
      return new Response(APP_JS, {
        headers: { "Content-Type": "application/javascript; charset=utf-8", "Cache-Control": "no-cache" },
      });
    }
    if (url.pathname === "/data/live-data.json") {
      let data = "{}";
      try { const kv = await env.LIVE_DATA.get("live-data", { type: "text" }); if (kv) data = kv; } catch(e) {}
      return new Response(data, { headers: { "Content-Type": "application/json", "Cache-Control": "no-store" } });
    }
    return new Response(HTML, {
      headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store, no-cache, must-revalidate, max-age=0" },
    });
  },
};
```

## Cloudflare Zaraz Injection Issue

When a custom domain is routed through Cloudflare, **Zaraz** may inject scripts that blank out your scripts. Fix: Disable Zaraz for the subdomain in Cloudflare Dashboard.

## Cloudflare Edge Cache

If dashboard works in agent browser but NOT user browser, it is ALWAYS edge cache. Fix: Cloudflare Dashboard -> Caching -> Cache Rules -> Bypass.
