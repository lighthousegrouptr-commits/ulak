# 2026-06-03: Aggregate Skills Path Fix

## Problem

Dashboard showed only 5 skills (from usage logs) instead of 30 (all installed).

## Root Cause

`scanInstalledSkills()` in `scripts/aggregate.ts` only scanned `~/.claude/skills/`.
The VPS has skills in two locations:
- `~/.claude/skills/` — Claude Code skills (few)
- `~/ulak/skills/` — Hermes/Ulak skills (28 skills)

## Fix

Changed `scanInstalledSkills()` from single-dir to multi-dir loop:

```typescript
async function scanInstalledSkills(): Promise<SkillStat[]> {
  const installed: SkillStat[] = [];
  const skillsDirs = [
    join(HOME, ".claude", "skills"),
    join(HOME, "ulak", "skills"),
  ];
  for (const skillsDir of skillsDirs) {
    if (!existsSync(skillsDir)) continue;
    const entries = await readdir(skillsDir, { withFileTypes: true }).catch(() => []);
    for (const entry of entries) {
      if (entry.name.startsWith(".")) continue;
      // ... rest unchanged
    }
  }
  return installed;
}
```

## Result

- Before: 5 skills (log-only)
- After: 30 skills (5 from logs + 25 installed but not recently used)
- Dashboard "Skills" section now shows all 30 with "SHOW ALL 30" button
