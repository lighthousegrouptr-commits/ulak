# Agentic OS — Hermes Skills + Memory Tab Integration (2026-05-31)

## What Changed

### Memory Graph: "Ulak" Filter Tab Added
- `src/routes/memory.tsx`: Added `"hermes"` to `SourceId` type, `BASE_SOURCES`, `PINECONE_SOURCES`, `matchesActive()`, and `SourceFilter` pills (display name: "Ulak")
- `scripts/aggregate.ts`: Source kind, file source, and workspace source now check `wsId.startsWith("hermes-")`; `MemSource` type union includes `"hermes"`
- `src/components/memory-graph-3d.tsx`: Filter matches function includes `if (allowedCats.has("hermes") && n.source === "hermes")`

### Skills: Hermes Skills Scanning
- `scripts/aggregate.ts`: `scanInstalledSkills()` now scans both `~/.claude/skills/` and `/root/.hermes/skills/`
- `src/lib/time-saved.ts`: `DEFAULT_RATE` changed from 120 to 50; `DEFAULT_MINUTES` map includes Hermes skills:
  - `/dream`: 30, `/vps-contact-form`: 20, `/lighthouse-group-project`: 25, `/claude-whatsapp-bridge`: 15, `/maintain-dashboard`: 15
  - `/agentic-os-deploy`: 25, `/dogfood`: 15, `/seo-audit`: 30, `/yuanbao`: 10
- `src/routes/skills.tsx`: Input fields enlarged (`flex-1 min-w-[60px]`, `fontSize: 16px`) for mobile tappability

### User Preferences Captured
- Hourly rate: $50/hr (was $120)
- Skills input must work on mobile (tappable, readable)
- Memory tab display name: "Ulak" (not "Hermes")

## Verification Checklist
- After deploy: Memory page shows "All / Obsidian / Local Claude / Ulak" filter pills
- Ulak tab click shows `source === "hermes"` nodes only
- Skills page shows "9 capabilities" (5 Claude + 4 Hermes)
- TIME SAVED reflects default minutes × usage counts
- Hero hourly rate displays "$50 / HOUR"
