---
name: claude-md-drift-audit
description: Audit every CLAUDE.md in this project for drift against the last week of git history. Flags sections that reference deleted files, renamed paths, or removed dependencies. Read-only — returns a punch list, never edits.
when_to_use: |
  Use when the user asks "is my CLAUDE.md still accurate?", "audit my docs for staleness",
  "what changed in the last week?", or as part of /sync-claude-md --weekly.
argument-hint: "[days=7]"
context: fork
agent: Explore
allowed-tools:
  - Read
  - Glob
  - Grep
  - "Bash(git log:*)"
  - "Bash(git diff:*)"
  - "Bash(git status:*)"
  - "Bash(find:*)"
disable-model-invocation: false
---

# CLAUDE.md Drift Audit (forked, read-only)

Days window: `$ARGUMENTS` (default `7` if empty).

Perform these steps in order, then return a single punch-list summary. Do not modify any file.

1. **Inventory** every `CLAUDE.md` and `*.claude/rules/*.md` in the tree using `find . -name "CLAUDE.md" -type f -not -path "*/.git/*" -not -path "*/node_modules/*"`. List paths and line counts.
2. **Collect change signal** for the window:
   - `git log --since="$ARGUMENTS days ago" --name-status --no-merges --diff-filter=DR` → deleted and renamed paths.
   - `git diff "@{$ARGUMENTS days ago}" --name-status -- package.json requirements.txt pyproject.toml go.mod Cargo.toml 2>/dev/null` → manifest deltas (removed/added deps).
3. **Cross-reference** each CLAUDE.md against those signals using `grep` / `Read`:
   - Mark any line that names a deleted or renamed path.
   - Mark any line in a Tech Stack / Dependencies section that names a removed dep.
   - Mark any `@path/...` chain import or markdown link whose target was deleted.
4. **Return** the punch list in this exact shape (markdown), nothing else:

```
## Drift Audit (window: <N> days)

Total CLAUDE.md inspected: <count>
Signals examined: <deleted_paths>, <renamed_paths>, <removed_deps>

### Findings
- <path>:<line> — <one-sentence reason> — suggested action
- ... (one bullet per drift; omit section if empty)

### Clean
- <path> (lines unchanged, references valid)
```

5. If no drift is found, return exactly `## Drift Audit\n\nNo drift in <N>-day window. <count> files inspected.`. Do not pad the output.
