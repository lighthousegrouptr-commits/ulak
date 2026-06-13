#!/usr/bin/env bash
# Agentic OS Full Refresh and Deploy Helper Script
# Automates syncing Hermes memories, aggregating, building, and deploying.

set -euo pipefail

echo "=== Agentic OS Full Refresh and Deploy ==="

# 1. Sync Hermes memory files
MEMORY_SRC="/root/ulak/memories/"
MEMORY_DST="/tmp/hermes-memory/"
if [[ ! -d "$MEMORY_SRC" ]]; then
  echo "Error: Source directory $MEMORY_SRC does not exist." >&2
  exit 1
fi
echo "Syncing memories from $MEMORY_SRC to $MEMORY_DST"
mkdir -p "$MEMORY_DST"
# Use rsync to copy contents, preserving files, ignoring lock files if desired
rsync -av --ignore-existing "$MEMORY_SRC/" "$MEMORY_DST/"
echo "Memory sync complete."

# 2. Run aggregator
cd /root/code/agentic-os
echo "Running aggregator..."
bun run scripts/aggregate.ts

# 3. Build
echo "Building project..."
bun run build

# 4. Deploy
echo "Deploying via Wrangler..."
wrangler deploy

echo "=== Done ==="