---
name: agentic-os-full-refresh-deploy
description: Refresh Agentic OS dashboard by syncing Hermes memories and deploying the dashboard.
---
# Agentic OS Full Refresh and Deploy

Refresh the Agentic OS dashboard by syncing Hermes memories and deploying the updated dashboard.

## When to Use

Use this skill when you want to update the Agentic OS dashboard with the latest Hermes memories
and deploy the changes.

## Steps

1. **Prepare the temporary Hermes memory directory**:\n   - Remove any existing content in `/tmp/hermes-memory` to avoid stale files, then recreate the directory.\n   - Copy Hermes memory files from known locations to this temporary directory.\n     The aggregator script checks multiple sources, but we copy to ensure consistency.\n\n   ```bash\n   rm -rf /tmp/hermes-memory\n   mkdir -p /tmp/hermes-memory\n   # Copy from Ulak project memories (if exists)\n   cp -r /root/ulak/memories/* /tmp/hermes-memory/ 2>/dev/null || true\n   # Copy from Hermes memories (if exists)\n   cp -r /root/.hermes/memories/* /tmp/hermes-memory/ 2>/dev/null || true\n   # Also check the non-pluralized directory names (just in case)\n   cp -r /root/ulak/memory/* /tmp/hermes-memory/ 2>/dev/null || true\n   cp -r /root/.hermes/memory/* /tmp/hermes-memory/ 2>/dev/null || true\n   # Remove lock files to avoid confusion\n   find /tmp/hermes-memory -name '*.lock' -delete 2>/dev/null || true\n   # Count copied files for verification\n   echo \"Copied $(find /tmp/hermes-memory -type f ! -name '*.lock' | wc -l) Hermes memory files to /tmp/hermes-memory\"\n   ```\n\n2. **Run the aggregator** to scan `~/.claude/`, `~/.claude/memory`, and `/tmp/hermes-memory/`:\n   ```bash\n   cd /root/code/agentic-os\n   bun run scripts/aggregate.ts\n   ```\n\n3. **Build and deploy**:\n   ```bash\n   bun run build\n   wrangler deploy\n   ```\n\n## Pitfalls\n\n- **Source directory may not exist**: The directory `/root/ulak/memory` might not exist. \n  Instead, look for memories in `/root/ulak/memories` and `/root/.hermes/memories` (and their singular forms).\n  The copy commands above use `|| true` to avoid errors if the source is missing.\n\n- **Stale files in temporary directory**: If `/tmp/hermes-memory` is not cleaned before copying, outdated memory files may remain and confuse the aggregator.\n  The step now removes the directory entirely before recreating it.\n\n- **Lock files**: Copying may bring over `*.lock` files; these are removed after copying to avoid confusion.\n\n- **Verify the aggregator output**: After running the aggregator, check the output for the number of memory files\n  processed to ensure the sync worked.\n\n## Verification\n\nAfter deployment, check the version ID from the `wrangler deploy` output and confirm the dashboard is updated.\n\n## Required Tools\n\n- bun\n- wrangler\n- Access to the Agentic OS source code at `/root/code/agentic-os`\n- Hermes memories in `/root/ulak/memories` and/or `/root/.hermes/memories`\n