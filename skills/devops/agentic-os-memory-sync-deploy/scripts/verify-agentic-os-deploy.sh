#!/usr/bin/env bash
# Verify Agentic OS memory sync and deploy
# Checks that the aggregator has run and live-data.json includes Hermes memory source

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIVE_DATA="$PROJECT_ROOT/src/data/live-data.json"

echo "=== Agentic OS Deploy Verification ==="
echo "Project root: $PROJECT_ROOT"
echo "Live data file: $LIVE_DATA"

if [[ ! -f "$LIVE_DATA" ]]; then
  echo "ERROR: live-data.json not found. Run aggregator first."
  exit 1
fi

# Check for hermes memory source
if grep -q '"kind": "hermes"' "$LIVE_DATA"; then
  echo "✓ Hermes memory source found in live-data.json"
else
  echo "✗ Hermes memory source NOT found in live-data.json"
fi

# Extract memory node count if available
if command -v jq &> /dev/null; then
  NODE_COUNT=$(jq '.memory.nodes // empty | length' "$LIVE_DATA" 2>/dev/null || echo "null")
  if [[ "$NODE_COUNT" != "null" && "$NODE_COUNT" -ge 0 ]]; then
    echo "✓ Memory node count: $NODE_COUNT"
  else
    echo "? Memory node count not available or zero"
  fi
else
  echo "Info: jq not installed, skipping node count extraction"
fi

# Check tmp hermes memory directory
TMP_MEM_DIR="/tmp/hermes-memory"
if [[ -d "$TMP_MEM_DIR" ]]; then
  FILE_COUNT=$(find "$TMP_MEM_DIR" -type f -not -name "*.lock" | wc -l)
  echo "✓ Temporary Hermes memory directory: $TMP_MEM_DIR ($FILE_COUNT files)"
else
  echo "✗ Temporary Hermes memory directory not found: $TMP_MEM_DIR"
fi

echo "Verification complete."