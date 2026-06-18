---
name: agentic-os-refresh-deploy-with-hermes-sync
description: Full refresh and deploy of Agentic OS dashboard with Hermes memory sync from Ulak snapshot.
---

# Agentic OS Full Refresh and Deploy with Hermes Memory Sync

## Trigger Conditions
Run this skill when you need to refresh the Agentic OS dashboard with the latest Hermes memories from the snapshot in `/root/ulak/memories/` (which is synced every 30 minutes from `~/.hermes/memories` via `ulak_sync.sh`).

This skill encapsulates the full procedure:
1. Sync Hermes memory files from the snapshot to a temporary location for the aggregator.
2. Run the Agentic OS aggregator to collect data from `~/.claude/projects`, `~/.claude/memory`, and the synced Hermes memories.
3. Build the dashboard for production.
4. Deploy the dashboard via Wrangler.

## Steps

See also `references/hermes-memory-sync.md` for details on syncing Hermes memory files.

1. **Prepare temporary memory directory**
   ```bash
   mkdir -p /tmp/hermes-memory
   cp /root/ulak/memories/* /tmp/hermes-memory/
   ```
   > This uses the snapshot in `/root/ulak/memories`, updated every 30 minutes by the ulak_sync.sh cron job from the live `~/.hermes/memories`.

2. **Run the aggregator**
   ```bash
   cd /root/code/agentic-os && bun run scripts/aggregate.ts
   ```
   > The aggregator scans `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/` to produce `src/data/live-data.json`.

3. **Build for production**
   ```bash
   cd /root/code/agentic-os && bun run build
   ```
   > This optimizes the frontend and prepares the server bundle.

4. **Deploy via Wrangler**
   ```bash
   cd /root/code/agentic-os && wrangler deploy
   ```
   > Deploys the Worker to Cloudflare, outputting a Version ID.

## Pitfalls
- **Memory sync source**: Always use the snapshot in `/root/ulak/memories/` (not the live `~/.hermes/memories` directly) because the cron job updates the snapshot regularly and the live directory may be locked or inconsistent during sync.
- **Aggregator warnings**: On Linux, the aggregator will skip macOS-only signals (Keychain credentials, exact plan-tier detection). This is expected and noted in the output.
- **Build warnings**: Vite may warn about large chunks (>500 kB). This is non-fatal; the build succeeds anyway.
- **Wrangler warnings**: If `workers_dev` or `preview_urls` are not explicitly set in `wrangler.jsonc`, they will be enabled by default. Override by setting `workers_dev = false` and/or `preview_urls = false` in the Wrangler file if desired.

## Verification\nAfter deployment, the dashboard should be available at the URL shown in the Wrangler output (e.g., `https://<subdomain>.workers.dev`). Check the Version ID in the output to confirm the new deployment.\n\nOptionally, you can verify that the generated `live-data.json` is recent and non-empty:\n```bash\ncd /root/code/agentic-os && ls -l src/data/live-data.json\n```\nEnsure the file size is greater than zero and the timestamp reflects the latest run.

## References
- [Hermes Memory Sync Details](references/hermes-memory-sync.md)
- Agentic OS documentation: See the `README.md` in the agentic-os repository for general setup.
- Ulak/Hermes sync mechanism: Refer to `/root/ulak/CLAUDE.md` for details on the three-way data flow between `~/.hermes/`, `/root/ulak/`, and GitHub.

## Related Skills
- `hermes-agent`: For configuring Hermes Agent itself.
- `agentic-os-deploy`: Alternative deployment procedure (may not include Hermes memory sync).
- `agentic-os-refresh-deploy`: Base refresh skill (this skill extends it with explicit Hermes memory sync from the Ulak snapshot).