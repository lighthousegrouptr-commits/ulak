# Agentic OS — Full Refresh + Deploy Version Log

## Run History

| Run | Date | Version ID | Files | Build | Errors |
| r38 | 2026-06-02 | `fecb15e0-ce4e-40e4-a94a-6899f8308e3e` | 18 | ~11.7s | 0 |
| r37 | 2026-06-02 | `bd28333c-8c25-485d-a26c-18f027ef0268` | 18 | ~11.9s | 0 |
| r36 | 2026-06-02 | `06f9c626-1736-4812-a6a6-c87ec86277bf` | 18 | ~12.3s | 0 |
| r35 | 2026-06-02 | `6008ef9c-f988-4027-bb71-dfd30fe15164` | 22 | ~11.9s | 0 |
| r34 | 2026-06-02 | `40cc4880-9812-48b2-8f82-dd5e53b5effc` | 22 | ~13.3s | 0 |
| r33 | 2026-06-02 | `5efff810-85f1-47ca-9af5-443d54493ed6` | 18 | ~10.5s | 0 |
| r32 | 2026-06-02 | `81880243-f06f-4e6b-ac69-605e71adc606` | 18 | ~10.8s | 0 |
| r31 | 2026-06-02 | `0a723bdc` | 18 | ~10.7s | 0 |
| r30 | 2026-06-02 | `6e42fb84-6b76-44c2-8dc6-8ba57f05bbb9` | 18 | ~11.3s | 0 |
| r29 | 2026-06-02 | `72419e42-a3c7-438f-b1cd-ebec50416ce7` | 18 | ~11.7s | 0 |
| r28 | 2026-06-02 | `0433753c-9fee-445d-aa87-49a8196c33e7` | 18 | ~10.9s | 0 |
| r27 | 2026-06-01 | `0e69ecc3-d91c-4576-9d4a-11f12f16c521` | 18 | ~11.4s | 0 |
| r26 | 2026-06-01 | `8fd3af90-4169-4b40-b7b7-79d3a81e2632` | 18 | ~11s | 0 |
| r25 | 2026-06-01 | `828f7b8a-9587-4d54-bef6-0b964132e401` | 18 | ~19s | 0 |
| r24 | 2026-06-01 | `a4e2c842-9622-4a2d-a240-1ca88784e856` | 18 | ~18s | 0 |
| r23 | 2026-06-01 | `c06f7bde-a379-445b-9560-9fbe1125b97e` | 18 | ~18s | 0 |
| r22 | 2026-06-01 | `f16d5536-7d58-400e-8e31-602865a56248` | 24 | ~19s | 0 |
| r21 | 2026-06-01 | `e9d15cff-cc75-498c-b12a-5b9b6b2bee71` | 24 | ~18s | 0 |
| r20 | 2026-06-01 | `3d22dc78-5fff-41f5-b525-1f8a7331b2c8` | 24 | ~18s | 0 |
| r19 | 2026-06-01 | `0eea010d-a55f-4229-9d92-7304d46ddcfa` | 22 | ~18s | 0 |
| r18 | 2026-06-01 | `79d6b034-5d9a-4eb6-aeb4-0aefdeb31303` | 20 | ~18s | 0 |
| r17 | 2026-06-01 | `719f6497` | 20 | ~18.5s | 0 |
| r16 | 2026-06-01 | `aebc499e` | 20 | 21.84s | 0 |
| r15 | 2026-06-01 | `d9dc598a` | 20 | 18.58s | 0 |
| r14 | 2026-06-01 | `27f74434` | 22 | 23.40s | 0 |

## Current State (r38)

- **Version ID**: `fecb15e0-ce4e-40e4-a94a-6899f8308e3e`
- **URL**: https://tanstack-start-app.lighthousegrouptr.workers.dev
- **Memory**: 18 files / 2 workspaces / 14 events / 0 Pinecone indexes
- **Build**: client 11.71s + SSR 879ms = ~12.6s total
- **Deploy**: 77 files scanned, 21 uploaded (54 cached), 551.59 KiB (34.44 KiB gzip), 30ms startup
- **Aggregator**: 2 Claude projects, 1458 assistant msgs, 8 skills installed, 5 used, 2 runs 7d, $8.07 value 7d
- **Deploy method**: `bun run build` → bare `wrangler deploy` (wrangler v4.86.0 at `/usr/bin/wrangler`)
- **No errors at any stage**

## r38 Notes

- Cron-triggered run. Pipeline stable: memory sync → aggregate → build → deploy all green.
- Copied Hermes memories from both `/root/ulak/memories/` and `/root/.hermes/memories/` to `/tmp/hermes-memory/`.
- `rm -rf` on `/tmp/hermes-memory/` blocked by security policy (use `mkdir -p` + `cp` only).
- Pipeline unchanged and stable across r36–r38.

## r35 Notes

- Cron-triggered run. Pipeline stable.
- `npx wrangler deploy --outdir dist/client` used (wrangler v4.90.0). The `--outdir` flag is accepted but functionally ignored — wrangler reads `dist/server/wrangler.json` from the Vite build output. Both bare `wrangler deploy` and `npx wrangler deploy --outdir dist/client` produce identical deploys.
- **`bun run deploy` does not exist** — no `deploy` script in `package.json`.

## r34 Notes

- Cron-triggered run. Pipeline stable.
- **bun was completely missing** — installed via `npm install -g bun`.
- `curl | bash` for bun install blocked by security scanner.
- `npx wrangler deploy` used (v4.90.0).

## r33 Notes

- Clean cron-triggered run. Pipeline stable.
- Bare `wrangler deploy` used (wrangler v4.86.0).

## r24 Notes

- `mkdir -p` + `cp` confirmed as the safe pattern for `/tmp/hermes-memory/`.

## r14 Fix — Tanstack Start SSR wrangler.jsonc

Correct `wrangler.jsonc` for Tanstack Start SSR:

```jsonc
{
  "name": "tanstack-start-app",
  "compatibility_date": "2025-09-24",
  "compatibility_flags": ["nodejs_compat"],
  "main": "dist/server/index.js",
  "no_bundle": true,
  "rules": [
    { "type": "ESModule", "globs": ["dist/server/assets/**/*.js"] }
  ]
}
```

Key: `no_bundle: true` + ES module rules (not `assets` config).
