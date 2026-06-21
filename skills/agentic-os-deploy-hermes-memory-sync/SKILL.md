---
name: agentic-os-deploy-hermes-memory-sync
description: Full refresh and deploy of Agentic OS dashboard with Hermes memory sync.
---

# Agentic OS Full Refresh and Deploy with Hermes Memory Sync

## Description
Perform a full refresh of the Agentic OS dashboard by syncing Hermes memory files, running the aggregator, building the project, and deploying with Wrangler.

## Steps

### 1. Sync Hermes memory files
   - The Hermes memory directory (`/root/ulak/memories/`) contains many memory files (each a `.md` file), including `MEMORY.md` and `USER.md`.
   - Create temporary destination: `mkdir -p /tmp/hermes-memory`
   - Sync memory files, excluding lock files: `rsync -av --exclude='*.lock' /root/ulak/memories/ /tmp/hermes-memory/`
     (Alternatively, use `cp` but note that lock files will be copied; they are harmless zero-byte files.)
   - Verify file count: `find /tmp/hermes-memory -type f -name '*.md' | ! -name '*.lock' | wc -l`  
     (This counts only markdown memory files, excluding lock files.)

### 2. Run the aggregator
   - Change to the Agentic OS project: `cd /root/code/agentic-os`
   - Execute the TypeScript aggregator: `bun run scripts/aggregate.ts`
   - This scans `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/` and writes `src/data/live-data.json`.

### 3. Build the project
   - Run: `bun run build`
   - This triggers `seed:data` (copies example live-data if missing) and Vite build.

### 4. Deploy with Wrangler
   - Run: `wrangler deploy`
   - Note: Wrangler may enable `workers_dev` and `preview_urls` by default if not explicitly set in the wrangler config; these warnings are non‑fatal.

### 5. Report
   - Capture the deployed version ID from the output (look for `Current Version ID:`).
   - Report total memory files count from step 1 (the count of synced memory files).
   - Note any errors from the sync, aggregate, build, or deploy steps.

## Pitfalls

- The Hermes memory directory is `memories`, not `memory`. Using `/root/ulak/memory/` will fail with “No such file or directory”.
- Temporary lock files (*.md.lock) may appear in the source directory. These are harmless but can be excluded from sync to keep the temporary directory cleaner.
- The aggregator script is located at `scripts/aggregate.ts` relative to the project root; ensure you are in `/root/code/agentic-os` before running.
- If the `.env.local` file is missing required API keys (PINECONE_API_KEY, OPENROUTER_API_KEY, etc.), the aggregator will skip those services but still succeed.
- Wrangler warnings about `workers_dev` and `preview_urls` are expected if not explicitly disabled in `wrangler.jsonc`; they do not affect deployment success.

## Verification

- After deployment, the Worker URL will be printed (e.g., `https://tanstack-start-app.lighthousegrouptr.workers.dev`).
- The version ID is a UUID-like string (e.g., `e102abeb-a3a1-4d43-97fb-0326760dc6e5`).

## Example Output

```
[aggregate] platform: linux — some macOS-only signals ...
[aggregate] scanning ~/.claude/projects ...
[aggregate] 3 projects, 5731 assistant msgs
...
[aggregate] wrote /root/code/agentic-os/src/data/live-data.json
...
$ bun run seed:data && vite build
...
✓ built in 12.74s
...
⛅️ wrangler 4.86.0
...
Uploaded 21 of 21 assets
...
Current Version ID: e102abeb-a3a1-4d43-97fb-0326760dc6e5
```

## Required Tools
- `rsync` (or `cp`)
- `bun` (with `vite` and `wrangler` available via project dependencies)
- Access to `/root/ulak/memories/` and `/root/code/agentic-os`