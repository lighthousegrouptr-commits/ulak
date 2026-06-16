---
name: agentic-os-full-refresh-deploy
description: Sync Hermes memory files, run the Agentic OS aggregator, build, and deploy the dashboard.
category: devops
---

# Agentic OS Full Refresh and Deploy

Sync Hermes memory files, run the aggregator, build, and deploy the Agentic OS dashboard.

## When to Use
- After updating Hermes memories or Claude Code data.
- Periodically to keep the dashboard in sync.
- When deploying changes to the Agentic OS dashboard.

## Steps
 \n1. **Sync Hermes memory files**  \n   ```bash \n   mkdir -p /tmp/hermes-memory \n# Prefer live Hermes memories; fallback to ulak memories directory if needed \nif [ -d \\\"/root/.hermes/memories\\\" ]; then \n  cp -av /root/.hermes/memories/* /tmp/hermes-memory/ \nelif [ -d \\\"/root/ulak/memories\\\" ]; then \n  cp -av /root/ulak/memories/* /tmp/hermes-memory/ \nelse \n  echo \\\"No Hermes memory source found\\\" >&2 \n  exit 1 \nfi\n   ``` \n\n2. **Count synced memory files (optional verification)**  \n   ```bash \n   find /tmp/hermes-memory -type f | wc -l \n   ``` \n\n3. **Run the aggregator**\n   ```bash\n   cd /root/code/agentic-os\n   bun run scripts/aggregate.ts\n    - Note: Check for /root/.hermes/memories first, then fallback to /root/ulak/memories (as seen in Ulak repo).\n   ```\n   - This reads `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/`.\n   - Outputs `src/data/live-data.json`.\n\n4. **Build the dashboard**\\n   ```bash\\n   # Option A: use the convenient build alias (runs seed:data + vite build)\\n   bun run build\\n   # Option B: run steps separately\\n   # bun run seed:data\\n   # bun run vite build\\n   ```\\n   - Produces production assets in `dist/`.\\n   - The `bun run build` script is defined in package.json and runs `bun run seed:data` then `vite build`.\\n\n5. **Deploy via Wrangler**\\\\n   ```bash\\\\n   # Remove any conflicting wrangler deploy config if present to avoid:\\\\n   # \"Found both a user configuration file at \"wrangler.json\"\\\\n   #  and a deploy configuration file at \".../config.json\".\\\\n   #  But these do not share the same base path so it is not clear which should be used.\\\\n   rm -f ~/.wrangler/deploy/config.json\\\\n   # Deploy using the built worker and specific wrangler config\\\\n   # In CI/non-interactive settings, prefix with CI=true to avoid prompts\\\\n   CI=true wrangler deploy\\\\n   ```\\\\n   - Deploys the Cloudflare Worker using the configuration in `dist/server/wrangler.json` (redirected by the build).\\\\n   - Outputs the deployed version ID.\\\\n   - Note: The `--yes` flag is not recognized; use `CI=true` for non-interactive deployment.\n\n## Verification
- After deployment, check the version ID in the wrangler output.
- Ensure the dashboard loads at the workers.dev URL.\n\n## Pitfalls
- If `/root/.hermes/memories` does not exist, the script falls back to `/root/ulak/memories` (the Ulak snapshot). Ensure at least one source is present.
- Ensure you copy from the correct directory name: use `memories` (plural) not `memory` (singular); the Ulak snapshot stores memories in `/root/ulak/memories/`.
- The aggregator may warn about missing macOS-only signals on Linux; this is expected and does not affect functionality.
- If `bun run build` fails due to missing dependencies, ensure the bun lockfile is up to date and run `bun install` first.
- Wrangler deployment may require authentication; ensure `wrangler login` has been run.
- When running `wrangler deploy` in non-interactive environments (e.g., cron jobs), prefix with `CI=true` to avoid prompts; the `--yes` flag is not recognized.\n\n## References\n- See `references/agentic-os-memory-sync.md` for details on memory synchronization.\n- See `references/references/agentic-os-aggregator.md` for notes on the aggregate.ts script.\n- See `references/deploy-2026-06-16.md` for the latest deployment log (2026-06-16).\n- See `references/deploy-2026-06-15b.md` for the latest deployment log (2026-06-15).\n- See `references/session-2026-06-16-agentic-os-deploy.md` for detailed session notes from 2026-06-16.