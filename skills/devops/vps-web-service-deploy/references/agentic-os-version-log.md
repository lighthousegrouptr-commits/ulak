# Agentic OS — Version History & Deploy Log

| Date | Version ID | Files | Workspaces | Build Time | Worker Startup | Notes |
|------|-----------|-------|------------|------------|----------------|-------|
| 2026-05-31 | `ebfaf653-29e0-4124-8568-e61ae68a8e83` | 36 | 2 | 12.6s client / 12.8s SSR | 15 ms | Second error-free run; pipeline stable; wrangler v4.86.0 |
| 2026-05-31 | `9d184325-5f97-48b3-bef9-424ab5367a52` | 36 | 2 | ~22s combined | 13 ms | First error-free run; confirmed 36-file aggregator |

## wrangler Version Notes
- As of 2026-05-31: v4.86.0 installed, v4.95.0 available
- Located at `/usr/bin/wrangler` — directly on PATH
- Update: `npm install -g wrangler` (may require approval gate)