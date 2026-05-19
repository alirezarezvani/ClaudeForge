---
description: Walk every CLAUDE.md in the project, prune stale references, enforce the 150-line cap, and re-chain root ↔ subdirectory files.
permissions:
  allow:
    - Bash(ls:*)
    - Bash(find:*)
    - Bash(git status:*)
    - Bash(git diff:*)
    - Bash(wc:*)
    - Bash(grep:*)
    - Bash(cat:*)
    - Bash(test:*)
    - Read
    - Edit
    - Write
    - Glob
    - Grep
    - Skill
hooks:
  - matcher: ""
    once: true
    commands:
      - echo "Starting CLAUDE.md sync workflow"
---

# /sync-claude-md — CLAUDE.md Sync & Cleanup

This command keeps every CLAUDE.md in the project current, lean, and chained. Apply the Karpathy behavioural guidelines (`~/.claude/skills/karpathy-guidelines/SKILL.md`) while running it: state assumptions, keep changes surgical, define verification per step.

---

## Phase 1: Inventory

Discover every CLAUDE.md in the project (skipping vendor directories) and report sizes.

!`find . -name "CLAUDE.md" -type f -not -path "./node_modules/*" -not -path "./.git/*" -not -path "./vendor/*" -not -path "./dist/*" -not -path "./build/*" -print -exec wc -l {} \;`

Then capture the project signal that drives staleness checks:

!`ls -la package.json requirements.txt pyproject.toml go.mod Cargo.toml 2>/dev/null || true`
!`git status --short 2>/dev/null || echo "Not a git repository"`
!`git diff --name-status HEAD~10 -- . 2>/dev/null | head -50 || true`

---

## Phase 2: Per-File Audit

For each CLAUDE.md found, run the `claude-md-enhancer` skill's analyzer to compute:

- Current line count (hard cap: **150 lines**)
- Sections present and their freshness
- Anti-patterns (TODO/placeholder text, hardcoded secrets, generic content)
- References to files, directories, packages, or scripts that may be stale

Stale references to flag and remove unless the user objects:

1. **Dependency references** — packages mentioned in CLAUDE.md but absent from `package.json` / `requirements.txt` / `pyproject.toml` / `go.mod` / `Cargo.toml`.
2. **File / directory references** — paths in the project structure section that no longer exist on disk.
3. **Script references** — commands in Quick Reference / Common Operations that point to removed npm scripts or Makefile targets.
4. **Modular link targets** — `[Backend Guidelines](backend/CLAUDE.md)` or `@backend/CLAUDE.md` imports where the target file no longer exists.
5. **Version drift** — version numbers / "What's New in vX.Y" sections referencing releases older than what `CHANGELOG.md` shows as current.

For each finding, show the offending line(s) with file:line references before editing.

---

## Phase 3: Enforce the 150-Line Cap

Any CLAUDE.md exceeding 150 lines must be split. Prefer this order:

1. **Move detail to existing sub-files.** If `backend/CLAUDE.md` exists, push backend-specific content there.
2. **Create a new sub-file** in the appropriate directory (e.g. `database/CLAUDE.md`) using `claude-md-enhancer.generate_context_file()`. The generator automatically prepends a back-link to the root.
3. **Update the root file's navigation** — both the human-readable bullets and the `@path/to/CLAUDE.md` chain imports — using `claude-md-enhancer`.

After splitting, re-validate every modified file with `BestPracticesValidator` and confirm line count ≤ 150.

---

## Phase 4: Re-chain Root ↔ Sub Files

Verify the bidirectional chain:

- Root CLAUDE.md must contain a `Quick Navigation` block listing every existing sub-CLAUDE.md, plus a `@<relative-path>` import line for each.
- Every sub-CLAUDE.md must contain a back-link at the top pointing to `../CLAUDE.md` (or the correct relative path) with both a markdown link and a `@../CLAUDE.md` import.

Repair any missing or broken chain links. Remove chain entries for sub-files that have been deleted.

---

## Phase 5: Cleanup & Report

After edits, regenerate validator output for each file and show:

- Files modified
- Lines removed (stale content)
- Sections added / split / removed
- Final line count per file (must all be ≤ 150)
- Remaining warnings the user should review manually

Do not commit. Leave the diff staged-but-uncommitted so the user can review with `git diff` and choose when to commit.

---

## When to Run

- After completing a feature, major refactor, or dependency change.
- When `claude-md-guardian` flags drift on session start.
- Whenever any single CLAUDE.md grows past ~120 lines (warning threshold).
- Before cutting a release — keeps documentation truthful at the tag boundary.

## Companion Tools

- `/enhance-claude-md` — initialise or upgrade a CLAUDE.md when one is missing or thin.
- `claude-md-guardian` agent — runs sync automatically on session start when changes are detected.
- `karpathy-guidelines` skill — behavioural rules applied to every edit this command makes.
