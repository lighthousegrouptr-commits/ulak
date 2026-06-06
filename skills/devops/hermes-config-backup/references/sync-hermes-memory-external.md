# Synchronizing Hermes Memory for External Agents

External agents like Agentic OS may need access to Hermes memory files for context and personalization.

## Standard Synchronization Path

Hermes memory files are typically located in:
- `~/.hermes/memories/`
- `~/.hermes/memory/`

For external agents, synchronize to:
- `/tmp/hermes-memory/` (checked by Agentic OS aggregator)
- Or another known location accessible to the external agent

## Synchronization Command

```bash
mkdir -p /tmp/hermes-memory
cp -r ~/.hermes/memories/* /tmp/hermes-memory/
# OR if using Ulak branding:
# cp -r /root/ulak/memories/* /tmp/hermes-memory/
```

## Agentic OS Integration

The Agentic OS aggregator script (`scripts/aggregate.ts`) automatically checks:
- `/root/ulak/memory`
- `/root/ulak/memories` 
- `/root/.hermes/memories`
- `/root/.hermes/memory`
- `/tmp/hermes-memory`

Placing synchronized memory files in `/tmp/hermes-memory` ensures they are picked up during the aggregation process.

## Notes

- Only copy the memory files (`*.md`), not the entire directory structure if not needed
- Ensure proper file permissions for readability
- This synchronization can be automated via cron or deployment scripts