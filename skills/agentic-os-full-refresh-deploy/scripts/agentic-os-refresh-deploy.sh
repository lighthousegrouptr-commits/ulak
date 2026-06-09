#!/usr/bin/env bash
set -euo pipefail

echo "=== Agentic OS Full Refresh and Deploy ==="

# 1. Prepare memory sync directory
MEMORY_DIR="/tmp/hermes-memory"
mkdir -p "$MEMORY_DIR"

# 2. Sync Hermes memory files
SOURCE_DIR="/root/ulak/memories"
echo "Syncing memories from $SOURCE_DIR to $MEMORY_DIR"
cp -r "$SOURCE_DIR"/* "$MEMORY_DIR"/ 2>/dev/null || true

# 3. Count synced memory files
FILE_COUNT=$(find "$MEMORY_DIR" -type f | wc -l)
echo "Synced memory files: $FILE_COUNT"

# 4. Run the aggregator
cd /root/code/agentic-os
echo "Running aggregator..."
if ! bun run scripts/aggregate.ts; then
    echo "ERROR: Aggregator failed"
    exit 1
fi

# 5. Build the project
echo "Building project..."
if ! bun run build; then
    echo "ERROR: Build failed"
    exit 1
fi

# 6. Deploy via Wrangler
echo "Deploying via Wrangler..."
DEPLOY_OUTPUT=$(wrangler deploy 2>&1)
echo "$DEPLOY_OUTPUT"
VERSION_ID=$(echo "$DEPLOY_OUTPUT" | grep -oP 'Current Version ID: \K\S+' || true)
if [[ -z "$VERSION_ID" ]]; then
    echo "WARNING: Could not extract Version ID from output"
fi

# 7. Report
echo "=== Deployment Complete ==="
echo "Version ID: ${VERSION_ID:-<not found>}"
echo "Memory files count: $FILE_COUNT"
echo "Check above output for any errors."
