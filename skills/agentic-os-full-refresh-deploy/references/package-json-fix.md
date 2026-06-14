# Package.json Fix for Agentic OS Build

## Issue
When running `bun run build` in the Agentic OS project, the command fails with:
```
error: Script not found "build"
```
Even though the package.json appears to contain a "build" script.

## Root Cause
The package.json file has a syntax error: a missing comma between the "dev" and "build" script entries, causing the entire scripts object to be invalid. Bun therefore does not recognize any scripts.

## Fix
1. Open `package.json` in the project root (`/root/code/agentic-os/package.json`).
2. Locate the "scripts" section.
3. Ensure there is a comma after the "dev" script line, before the "build" script line.
   Example correct format:
   ```json
   "dev": "bun run seed:data && vite dev --open",
   "build": "bun run seed:data && vite build",
   ```
4. Save the file.
5. Rerun `bun run build` (or the full deploy sequence).

## Verification
After fixing, run `bun run` to list available scripts; you should see "build" listed.

## Prevention
When editing package.json manually, always validate JSON syntax (e.g., with `jq . package.json > /dev/null` or using a JSON-aware editor).