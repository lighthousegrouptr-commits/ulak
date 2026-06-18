## Memory Sync Detail (observed session)

During the Agentic OS refresh, the following memory files were present:

- Source Hermes memories: `/root/.hermes/memories/`
  - `MEMORY.md`
  - `USER.md`
  - plus lock files `.lock`

- Source Ulak memories: `/root/ulak/memories/`
  - `MEMORY.md`
  - `USER.md`

After copying to `/tmp/hermes-memory/`, the aggregator reported:
```
memory: 20 files / 2 workspaces / 0 Pinecone indexes / 0 vectors / 8 events
```
The 20 files include:
- 2 from Hermes memories (MEMORY.md, USER.md)
- 2 from Ulak memories (MEMORY.md, USER.md)
- ~16 from `~/.claude/projects/*/memory/` (markdown files per project)
- Possibly others from Obsidian vaults (none present in this session).

The aggregator treats each `.md` file as a memory node, grouping by workspace label derived from the folder hierarchy.

**Note**: Lock files (`*.md.lock`) are ignored by the `walkMd` function (they lack `.md` extension after filtering) and thus not counted.
