# TanStack Start 1.167+ — server-entry Removed, SSR Breaks

## Problem

Starting from `@tanstack/react-start` v1.167, the `@tanstack/react-start/server-entry` virtual module was removed. The `createStartHandler` API moved to `@tanstack/start-server-core`. The Vite plugin no longer understands the old `import("@tanstack/react-start/server-entry")` pattern in `src/server.ts`.

**Symptom:** After `bun run build`, `dist/server/index.js` contains:
```js
const index = { fetch: () => new Response("placeholder", { status: 200 }) };
```
The real SSR handler is never pulled in. `curl https://yoursite` returns `"placeholder"`.

## Root Cause

The Vite plugin fails to resolve virtual modules (`#tanstack-router-entry`, `#tanstack-start-entry`) during SSR build when combined with `@cloudflare/vite-plugin`. The plugin silently falls back to a placeholder instead of throwing an error.

## Diagnosis

```bash
grep -n "placeholder" dist/server/index.js
# If this matches, SSR is broken — the real handler was not bundled.
```

## Solution: Static SPA via Inline HTML Worker (Updated 2026-06-02)

Since `env.ASSETS` does NOT work on Workers (only Pages), and Cloudflare Pages project may not exist, the most reliable approach for single-file dashboards is **inline HTML Worker**:

1. Create `scripts/build-worker.mjs`:
```js
import { readFileSync, writeFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(__dirname, "..");

const dashboardHtml = readFileSync(resolve(projectRoot, "dist/client/dashboard.html"), "utf-8");

// Escape </script> tags to prevent premature tag closing in embedded JS
const safeHtml = dashboardHtml.replace(/<\/script>/g, "<\\/script>");

const workerCode = `// Agentic OS — Static dashboard server for Cloudflare Worker
const DASHBOARD_HTML = ${JSON.stringify(safeHtml)};

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    // Serve live-data.json from KV
    if (path === "/data/live-data.json" || path === "/live-data.json") {
      let data = "{}";
      try {
        const kvData = await env.LIVE_DATA.get("live-data", { type: "text" });
        if (kvData) data = kvData;
      } catch (_e) {}
      return new Response(data, {
        headers: { "Content-Type": "application/json", "Cache-Control": "no-store" },
      });
    }

    // Serve dashboard for all other paths
    return new Response(DASHBOARD_HTML, {
      headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-cache" },
    });
  },
};
`;

writeFileSync(resolve(projectRoot, "dist/server/index.js"), workerCode);

// Update dist/server/wrangler.json to include KV binding
const wranglerJsonPath = resolve(projectRoot, "dist/server/wrangler.json");
let wranglerJson;
try { wranglerJson = JSON.parse(readFileSync(wranglerJsonPath, "utf-8")); } catch { wranglerJson = {}; }
if (!wranglerJson.kv_namespaces) wranglerJson.kv_namespaces = [];
const kvExists = wranglerJson.kv_namespaces.some(
  (kv) => kv.binding === "LIVE_DATA" || kv.id === "df2bda58d7bb4abe91569c4c48c5bf5b"
);
if (!kvExists) {
  wranglerJson.kv_namespaces.push({ binding: "LIVE_DATA", id: "df2bda58d7bb4abe91569c4c48c5bf5b" });
}
writeFileSync(wranglerJsonPath, JSON.stringify(wranglerJson, null, 2));

console.log(`Worker built: ${workerCode.length} bytes`);
```

2. Add to `package.json` build script: `"build": "bun run seed:data && vite build && bun run scripts/build-worker.mjs"`

3. Deploy: `wrangler deploy`

4. Write data to KV: `wrangler kv key put --binding=LIVE_DATA --remote "live-data" --path src/data/live-data.json`

**Why this works:** The HTML is baked directly into the Worker as a JS string. No `env.ASSETS`, no Pages project, no Docker container needed. The Worker serves the HTML for all routes and fetches `live-data.json` from KV.

**Limitations:** Only works for single-file HTML dashboards (no JS bundles). For full SPAs with React/Three.js bundles, use Docker+Caddy (Option C) or Cloudflare Pages (Option A).

## KV Data Flow for Dashboard

```
VPS local machine                    Cloudflare
┌─────────────────┐                 ┌──────────────┐
│ aggregate.ts    │  bun run        │ KV Namespace │
│ → live-data.json│  scripts/       │ LIVE_DATA    │
│                 │  aggregate.ts   │              │
│ wrangler kv     │ ──────────────→ │ "live-data"  │
│ key put --remote│                 │ key          │
└─────────────────┘                 └──────┬───────┘
                                           │
                                    Worker reads
                                    env.LIVE_DATA
                                           │
                                    ┌──────▼───────┐
                                    │ Worker serves│
                                    │ /data/live-  │
                                    │ data.json    │
                                    └──────────────┘
```

## The Broken Pattern (DO NOT USE)

The following pattern was previously recommended but does NOT work:

```js
// ❌ WRONG — env.ASSETS does not exist on Workers
const asset = await env.ASSETS.fetch(request);
```

This silently returns 404 on all requests. The deploy appears to succeed but no static files are ever served.

## Critical Pitfalls

1. **`vite build` overwrites `dist/server/index.js`** with the broken "placeholder" bundle. If using static SPA approach, copy `worker.js` over it after build. Add to `package.json` build script: `&& cp src/worker.js dist/server/index.js`

2. **Do NOT add `"assets"` to `wrangler.jsonc`** for Worker-based SPAs. `env.ASSETS` is auto-injected. Adding explicit assets config causes the worker to be treated as a Pages project.

3. **wrangler asset dedup** may skip uploading new assets after a clean rebuild. If site shows old content: `rm -rf .wrangler/state .wrangler/tmp` then redeploy.

## Version History

| Date | react-start | Notes |
|------|------------|-------|
| 2026-06-02 | 1.167.65 | `server-entry` removed, SSR breaks with placeholder |
| Pre-1.167 | < 1.167 | `server-entry` existed, SSR worked with correct config |
