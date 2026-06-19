# Agentic OS Full Refresh and Deploy Commands (Ulak Deployment)

These are the exact commands used in a successful session to sync Hermes memories, aggregate data, build, and deploy the Agentic OS dashboard.

```bash
# 1. Prepare temporary directory for Hermes memory sync
mkdir -p /tmp/hermes-memory

# 2. Sync Hermes memory files (Ulak stores memories in /root/ulak/memories/)
#    Copy only .md files, ignoring lock files.
HERMES_MEM_DIR="/root/ulak/memories"
find "$HERMES_MEM_DIR" -name "*.md" -type f -exec cp {} /tmp/hermes-memory/ \;
#    Also copy the memories subdirectory if it exists (contains additional .md files)
cp -r "$HERMES_MEM_DIR/memories/" /tmp/hermes-memory/ 2>/dev/null || true

# 3. Verify copied files (should include MEMORY.md, USER.md, and any files under memories/)
echo "Copied files:"
find /tmp/hermes-memory -type f | sort

# 4. Run the Agentic OS aggregator (scans ~/.claude/, ~/.claude/memory, and /tmp/hermes-memory/)
cd /root/code/agentic-os
bun run scripts/aggregate.ts

# 5. Build the dashboard
bun run build

# 6. Deploy to Cloudflare Workers
cd dist/server
# Remove any existing conflicting deploy configuration (if present)
rm -rf ../../.wrangler/deploy
wrangler deploy

# After successful deployment, note the version ID from the output.
```