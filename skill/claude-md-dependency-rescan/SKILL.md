---
name: claude-md-dependency-rescan
description: Re-detect this project's tech stack from package.json / requirements.txt / pyproject.toml / go.mod / Cargo.toml and diff it against the Tech Stack section of every CLAUDE.md. Read-only — returns added / removed / renamed dependencies, never edits.
when_to_use: |
  Use when the user asks "is my Tech Stack section up to date?", "what deps changed?",
  "rescan my dependencies", after dependency upgrades, or as part of /sync-claude-md --weekly.
argument-hint: "[manifest-path]"
context: fork
agent: Explore
allowed-tools:
  - Read
  - Glob
  - Grep
  - "Bash(find:*)"
  - "Bash(cat:*)"
disable-model-invocation: false
---

# CLAUDE.md Dependency Rescan (forked, read-only)

Optional explicit manifest: `$ARGUMENTS` (default: auto-detect all five manifest types).

Run these steps in order. Do not modify any file.

1. **Detect manifests.** Look for `package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml` at the repo root and one level deep (workspaces/monorepos).
2. **Extract declared dependencies** from each:
   - `package.json` → keys of `dependencies` and `devDependencies` (skip versions).
   - `requirements.txt` → first token of each non-comment line.
   - `pyproject.toml` → `[project.dependencies]` / `[tool.poetry.dependencies]` keys.
   - `go.mod` → module paths under `require (...)`.
   - `Cargo.toml` → keys under `[dependencies]` / `[dev-dependencies]`.
3. **Inventory documented deps** in every `CLAUDE.md` (and `.claude/rules/*.md`): grep for the Tech Stack / Dependencies sections and the lists under them.
4. **Compute three sets per file:**
   - `added`: in manifest but absent from this CLAUDE.md.
   - `removed`: documented in this CLAUDE.md but absent from manifest.
   - `renamed`: documented and present in manifest but spelled differently (`react-router` vs `react-router-dom`, `pg` vs `psycopg2`).
5. **Return** in this exact shape:

```
## Dependency Rescan

Manifests detected: <list>
Total declared deps: <count>

### Per file
#### <path-to-CLAUDE.md>
- Added (in manifest, not documented): <list or "none">
- Removed (documented, not in manifest): <list or "none">
- Renamed / aliased: <list or "none">
```

6. If every documented set matches its manifest, return exactly `## Dependency Rescan\n\nAll documented deps match manifests. <M> files inspected.`. Do not pad.

**Hard rule**: do not propose specific edits — just surface the diffs. `/sync-claude-md` decides whether to write them.
