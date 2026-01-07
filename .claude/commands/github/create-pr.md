---
title: /create-pr
description: Create pull request with proper validation
---

# Create Pull Request

You are helping the user create a pull request that follows ClaudeForge conventions.

## Workflow

1. **Detect Current Branch**
   ```bash
   CURRENT_BRANCH=$(git branch --show-current)
   echo "Current branch: $CURRENT_BRANCH"
   ```

2. **Determine Target Branch**
   - If current branch starts with `feature/`, `fix/`, `hotfix/`, `test/`, `refactor/`, `docs/`:
     - Target: `dev`
   - If current branch is `dev`:
     - Target: `main` (release PR)
   - Otherwise: Ask user

3. **Validate Branch Name**
   - Check if branch follows convention
   - If not, suggest renaming:
     ```bash
     git branch -m feature/new-name
     ```

4. **Check for Uncommitted Changes**
   ```bash
   git status --short
   ```
   - If changes exist, suggest committing first

5. **Push Branch** (if needed)
   ```bash
   git push -u origin $CURRENT_BRANCH
   ```

6. **Generate PR Title**
   - Based on commits since target branch
   - Must follow Conventional Commits format
   - Examples:
     - `feat(installer): add Windows PowerShell support`
     - `fix(skill): correct template selection logic`
     - `docs: update installation guide`

7. **Generate PR Description**

   Use PR template format:
   ```markdown
   ## Description
   [Describe changes]

   ## Type of Change
   - [x] [Selected type]

   ## Related Issues
   Closes #[issue number]

   ## Changes Made
   - Change 1
   - Change 2

   ## Testing Performed
   - [x] Tested installation
   - [x] Tested slash command
   ...
   ```

8. **Create PR**
   ```bash
   gh pr create \
     --base [target branch] \
     --title "[PR title]" \
     --body "[PR description]"
   ```

   Or for draft:
   ```bash
   gh pr create --draft \
     --base [target branch] \
     --title "[PR title]" \
     --body "[PR description]"
   ```

9. **Post-Creation**
   - Show PR URL
   - Explain what workflows will run:
     - For PR to dev: `pr-into-dev.yml`
     - For PR to main: `dev-to-main.yml`
   - Link to workflow documentation

## Validation Checklist

Before creating PR, verify:
- ✅ Branch name follows convention
- ✅ PR title follows Conventional Commits
- ✅ At least one issue referenced
- ✅ All changes committed and pushed
- ✅ Target branch is correct

## Examples

**Feature PR to dev:**
```bash
gh pr create \
  --base dev \
  --title "feat(skill): add Rust template support" \
  --body "## Description

Adds Rust project template with Cargo.toml detection and
appropriate CLAUDE.md generation.

## Type of Change
- [x] New feature

## Related Issues
Closes #42

## Changes Made
- Add Rust template in skill/examples/
- Update template_selector.py with Rust detection
- Add Rust-specific validation rules

## Testing Performed
- [x] Tested on sample Rust project
- [x] Validated template output
- [x] Python syntax checks pass"
```

**Release PR (dev to main):**
```bash
gh pr create \
  --base main \
  --title "release: v1.1.0" \
  --body "## Description

Release version 1.1.0 with new features and bug fixes.

## Changes in This Release
- feat(skill): Rust template support
- feat(installer): Windows improvements
- fix(skill): Template selection bugs
- docs: Updated installation guide

## Related Issues
Closes #42, #45, #48

## CHANGELOG
See CHANGELOG.md for full details.

## Testing
- [x] All quality gates pass
- [x] Tested installation on macOS, Linux, Windows
- [x] Tested all new features"
```

## Workflow Triggers

**PR to dev:**
- Validates branch name (must be feature/*, fix/*, etc.)
- Validates PR title (Conventional Commits)
- Checks for linked issues
- Runs quality gates (Python, Markdown, Bash, secrets)

**PR to main:**
- Validates source branch (must be dev, release/*, or dependabot/*)
- Checks CHANGELOG.md updated
- Validates production build
- Runs full quality gates

## Success Output

Show user:
1. PR URL
2. Workflow status link
3. Next steps (wait for CI, request review)
4. Link to relevant docs (GITHUB_WORKFLOWS.md, BRANCHING_STRATEGY.md)

Provide clear guidance and actual commands user can run.
