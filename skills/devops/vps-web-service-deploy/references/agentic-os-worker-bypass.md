# Cloudflare Worker Bypass — agentic-os debugging notes

## The problem

`agentic.lighthousegroup.net.tr` had TWO deploys running simultaneously:

1. **Dokploy container** (Nixpacks + Vite preview on port 3000) — the "real" deploy we were fixing
2. **Cloudflare Worker** (`tanstack-start-app`, `wrangler.jsonc` in repo root) — deployed manually via Wrangler, configured as a custom domain route in Cloudflare

The Cloudflare Worker was挡 in front of the Dokploy container. Every request hit the Worker first, which served its own (stale) bundle — the Dokploy container was never reached. All our Nixpacks/Dokploy fixes had no effect because the Worker was intercepting traffic.

## Diagnosis clues

- `cf-ray` + `server-timing: cfEdge;dur=X,cfOrigin;dur=0,cfWorker;dur=Y` headers — `cfWorker` > 0 means a Worker executed
- `content-encoding: zstd` — Cloudflare's compression (not origin's)
- Status 200 with stale content despite origin being fixed
- Response time ~300ms (90ms Worker + 294ms edge) vs origin-only ~10ms

## Fix options

1. **Remove the Worker route** (Cloudflare dashboard → Workers Routes → delete `agentic.lighthousegroup.net.tr/*`)
2. **Re-deploy the Worker** with current code (`wrangler deploy` from the repo)
3. **Restrict Worker to specific paths** (e.g. only `sitemap.xml*`)

## Key lesson

When debugging "why aren't my changes showing up?" on `*.lighthousegroup.net.tr`:
1. First check Cloudflare Workers dashboard for active Workers on that domain
2. Check Workers Routes for catch-all `/*` routes
3. A Worker in front of origin will bypass ALL origin-side fixes until the Worker itself is updated or removed
4. `wrangler.jsonc` in repo root = Cloudflare Worker deploy target (not Nixpacks)

## wrangler.jsonc location

```
agentic-os/
  wrangler.jsonc     # Cloudflare Worker config (name: tanstack-start-app)
  nixpacks.toml      # Nixpaks/Dokploy config (separate deploy)
  src/server.ts      # Worker entry point
```

Both deploy targets exist in the same repo. Know which one is actually serving traffic before debugging.
