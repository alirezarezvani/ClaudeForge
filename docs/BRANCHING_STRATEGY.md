# Branching Strategy

ClaudeForge uses a **Standard Branching Strategy** with protected branches and automated quality gates.

## Overview

```
feature/*, fix/*, hotfix/* → dev → main
         ↓                    ↓      ↓
    Development          Testing  Production
```

**Three permanent branches:**
- `main` - Production-ready code, always deployable
- `dev` - Integration branch for features
- *(temporary)* - Feature, fix, and hotfix branches

**Branch protection:**
- ✅ No direct commits to main or dev
- ✅ All changes via pull requests
- ✅ Automated quality gates required
- ✅ Conventional Commits enforced
- ✅ Linear history (squash merges)

---

## Branch Types

### Main Branch

**Purpose:** Production-ready releases only

**Protection Rules:**
- ✅ Require pull request before merging
- ✅ Require status checks to pass: `quality-gates`, `production-build`
- ✅ Require linear history (squash merges only)
- ✅ No force pushes
- ✅ No deletions
- ✅ Require review from CODEOWNERS

**Who can merge:**
- Only `dev`, `release/*`, or `dependabot/*` branches
- After passing dev-to-main.yml workflow

**Triggers:**
- dev-to-main.yml workflow on PR
- release.yml workflow for GitHub releases

**Typical state:**
- Always matches latest GitHub release
- Only updated when releasing new version
- Every commit corresponds to a version tag (v1.0.0, v1.1.0, etc.)

---

### Dev Branch

**Purpose:** Integration branch for all features

**Protection Rules:**
- ✅ Require pull request before merging
- ✅ Require status checks to pass: `quality-gates`, `validate-pr`
- ✅ Require linear history (squash merges only)
- ✅ No force pushes
- ✅ No deletions

**Who can merge:**
- Feature branches (`feature/*`)
- Fix branches (`fix/*`)
- Hotfix branches (`hotfix/*`)
- Test branches (`test/*`)
- Refactor branches (`refactor/*`)
- Docs branches (`docs/*`)

**Triggers:**
- pr-into-dev.yml workflow on PR

**Typical state:**
- Contains completed features awaiting release
- Ahead of main by several commits
- Reset to main only after release (via merge)

---

### Feature Branches

**Naming Convention:** `feature/<description>`

**Purpose:** New features or enhancements

**Examples:**
- `feature/add-rust-templates`
- `feature/vscode-extension`
- `feature/ai-suggestions`

**Lifecycle:**
1. Create from latest `dev`: `git checkout dev && git pull && git checkout -b feature/my-feature`
2. Make changes, commit with Conventional Commits
3. Push to origin: `git push -u origin feature/my-feature`
4. Create PR to `dev`
5. Pass quality gates and code review
6. Squash merge to `dev`
7. Delete feature branch

**PR Requirements:**
- ✅ Title must follow Conventional Commits: `feat(scope): description`
- ✅ At least one linked issue (recommended)
- ✅ All quality gates pass
- ✅ Code review approved (if CODEOWNERS configured)

---

### Fix Branches

**Naming Convention:** `fix/<description>`

**Purpose:** Bug fixes

**Examples:**
- `fix/installer-windows-path`
- `fix/python-syntax-validation`
- `fix/broken-markdown-links`

**Lifecycle:**
Same as feature branches, but:
- PR title prefix: `fix(scope): description`
- Link to bug issue with `Fixes #123` or `Closes #123`

**PR Requirements:**
- ✅ Title: `fix(scope): description`
- ✅ Linked to bug issue
- ✅ Quality gates pass
- ✅ Test fix if applicable

---

### Hotfix Branches

**Naming Convention:** `hotfix/<description>`

**Purpose:** Urgent fixes for production issues

**Examples:**
- `hotfix/critical-installer-bug`
- `hotfix/security-patch`

**Lifecycle:**
1. Create from `dev`: `git checkout dev && git pull && git checkout -b hotfix/issue-name`
2. Make minimal fix
3. Create PR to `dev`
4. After merge to dev, immediately create PR dev → main
5. Fast-track review and merge

**PR Requirements:**
- ✅ Title: `fix(scope): description` or `hotfix(scope): description`
- ✅ Link to critical issue
- ✅ Quality gates pass (can be expedited)
- ✅ Fast-track review

**Special considerations:**
- Prioritize speed over perfection
- Minimal changes only
- Document reason for hotfix in PR description

---

### Test Branches

**Naming Convention:** `test/<description>`

**Purpose:** Testing experiments or validations

**Examples:**
- `test/new-quality-gate`
- `test/workflow-validation`

**Lifecycle:**
- Same as feature branches
- PR title: `test(scope): description`
- May not require linked issue

---

### Refactor Branches

**Naming Convention:** `refactor/<description>`

**Purpose:** Code improvements without changing functionality

**Examples:**
- `refactor/simplify-analyzer`
- `refactor/improve-error-handling`

**Lifecycle:**
- Same as feature branches
- PR title: `refactor(scope): description`
- Should not change external behavior

---

### Docs Branches

**Naming Convention:** `docs/<description>`

**Purpose:** Documentation-only changes

**Examples:**
- `docs/update-installation-guide`
- `docs/add-troubleshooting-section`

**Lifecycle:**
- Same as feature branches
- PR title: `docs: description` or `docs(scope): description`
- Can skip some quality gates (Python, Bash)

---

## Workflow Diagrams

### Standard Feature Flow

```
Developer's machine:
git checkout dev
git pull origin dev
git checkout -b feature/add-templates
# Make changes
git add .
git commit -m "feat(skill): add Rust template support"
git push -u origin feature/add-templates

GitHub:
Create PR: feature/add-templates → dev
↓
pr-into-dev.yml runs:
├─ Branch name validation ✅
├─ PR title validation ✅
├─ Linked issue check ⚠️
├─ Quality gates ✅
└─ Ready for review

Code review + approval
↓
Squash and merge to dev
↓
Delete feature branch
```

### Release Flow

```
Dev branch ready for release:
├─ All features merged
├─ CHANGELOG.md updated
└─ Version bumped

GitHub:
Create PR: dev → main
↓
dev-to-main.yml runs:
├─ Source branch validation ✅ (dev allowed)
├─ CHANGELOG.md check ✅
├─ Version consistency ✅
├─ Quality gates ✅
├─ Production build validation ✅
└─ Ready for production

Approval + merge to main
↓
Run release.yml workflow:
├─ Input version: 1.1.0
├─ Validate version format ✅
├─ Extract CHANGELOG notes ✅
├─ Create GitHub release ✅
└─ Tag created: v1.1.0

Result:
├─ main branch updated
├─ GitHub release published
├─ Installable via one-line command
└─ Ready for announcements
```

### Hotfix Flow

```
Critical production bug discovered:

Developer's machine:
git checkout dev
git pull origin dev
git checkout -b hotfix/critical-installer-bug
# Make minimal fix
git commit -m "fix(installer): resolve critical Windows path issue"
git push -u origin hotfix/critical-installer-bug

GitHub:
Create PR: hotfix/critical-installer-bug → dev
↓
pr-into-dev.yml runs (expedited review)
↓
Merge to dev
↓
Immediately create PR: dev → main
↓
dev-to-main.yml runs (fast-track)
↓
Merge to main
↓
Create hotfix release: v1.0.1
```

---

## Branch Protection Configuration

### Configure Main Branch Protection

1. Go to Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require a pull request before merging
     - ✅ Require approvals: 1 (if team)
     - ✅ Dismiss stale reviews
     - ✅ Require review from Code Owners
   - ✅ Require status checks to pass before merging
     - ✅ Require branches to be up to date
     - Add required checks:
       - `quality-gates`
       - `production-build`
       - `validate-release-pr`
   - ✅ Require conversation resolution before merging
   - ✅ Require linear history
   - ✅ Do not allow bypassing the above settings
4. Under "Rules applied to everyone including administrators":
   - ✅ Restrict deletions
   - ✅ Block force pushes
5. Save changes

### Configure Dev Branch Protection

1. Go to Settings → Branches → Add rule
2. Branch name pattern: `dev`
3. Enable:
   - ✅ Require a pull request before merging
     - Require approvals: 0 (can be 1 if team)
   - ✅ Require status checks to pass before merging
     - Add required checks:
       - `quality-gates`
       - `validate-pr`
   - ✅ Require linear history
   - ✅ Do not allow bypassing the above settings
4. Under "Rules applied to everyone including administrators":
   - ✅ Restrict deletions
   - ✅ Block force pushes
5. Save changes

---

## Commit Message Guidelines

ClaudeForge uses **Conventional Commits** format.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type (Required)

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Code style (formatting, semicolons)
- `refactor` - Code change (neither fix nor feature)
- `perf` - Performance improvement
- `test` - Add/update tests
- `build` - Build system or dependencies
- `ci` - CI/CD configuration
- `chore` - Other changes (no src/test changes)
- `revert` - Revert previous commit

### Scope (Optional but Recommended)

- `installer` - Installation scripts
- `skill` - Python skill modules
- `command` - Slash commands
- `agent` - Guardian agent
- `docs` - Documentation
- `ci` - CI/CD workflows
- `workflows` - GitHub Actions

### Subject (Required)

- Use imperative mood: "add" not "added" or "adds"
- Don't capitalize first letter
- No period at the end
- Maximum 50 characters

### Body (Optional)

- Explain what and why vs. how
- Wrap at 72 characters
- Separate from subject with blank line

### Footer (Optional)

- Reference issues: `Closes #123`, `Fixes #456`
- Breaking changes: `BREAKING CHANGE: description`

### Examples

**Good:**
```
feat(installer): add Windows PowerShell support

Add install.ps1 script for Windows users with equivalent
functionality to install.sh bash script.

Closes #42
```

**Good:**
```
fix(skill): correct template selection logic

Fix bug where wrong template was selected for TypeScript
projects. The analyzer was not correctly detecting tsconfig.json.

Fixes #156
```

**Good:**
```
docs: update installation troubleshooting guide

Add common installation issues based on user feedback
from issues #78, #82, and #91.
```

**Bad:**
```
Added new feature
```
- Missing type and scope
- Wrong tense (should be "add")
- Vague subject

**Bad:**
```
fix: Fixed the bug
```
- Capitalized subject
- Unnecessary word "the"
- No details on what bug

---

## PR Title Requirements

PR titles MUST follow Conventional Commits format.

**Valid examples:**
- `feat(installer): add Windows PowerShell support`
- `fix(skill): correct Python syntax validation`
- `docs: update installation guide`
- `refactor(analyzer): simplify project detection`
- `ci: add Python dependency updates to dependabot`

**Invalid examples:**
- `Add new feature` ❌ Missing type/scope
- `Fixed bug` ❌ Wrong tense, no scope
- `Update docs` ❌ Missing colon
- `FEAT: Add feature` ❌ Uppercase type
- `feat: Add feature.` ❌ Period at end

**Validation:**
- pr-into-dev.yml workflow validates PR title format
- Fails if format is incorrect
- Auto-comments with fix instructions

---

## Merge Strategies

ClaudeForge uses **Squash and Merge** exclusively.

### Why Squash?

✅ **Linear history** - Easy to understand and navigate
✅ **Clean log** - One commit per feature/fix
✅ **Easy revert** - Revert entire feature with one command
✅ **Better releases** - Clear association between features and versions

### How it Works

When merging PR with multiple commits:

**Before merge (feature branch):**
```
feat: add template A
fix: correct typo
feat: add template B
refactor: simplify code
test: add unit tests
```

**After merge (dev branch):**
```
feat(skill): add Rust templates (#42)

- Add Rust template A
- Add Rust template B
- Simplify template selection
- Add unit tests

Co-authored-by: Developer <dev@example.com>
```

### Merge Commit Message

Automatically generated:
- **Title:** From PR title (Conventional Commits format)
- **Body:** From PR description
- **Footer:** PR number, co-authors

---

## Git Commands Cheat Sheet

### Start New Feature

```bash
# Update dev
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "feat(scope): add feature"

# Push to GitHub
git push -u origin feature/my-feature
```

### Update Feature Branch with Latest Dev

```bash
# While on feature branch
git checkout dev
git pull origin dev
git checkout feature/my-feature
git rebase dev

# If conflicts, resolve and continue
git rebase --continue

# Force push (rebase rewrites history)
git push --force-with-lease origin feature/my-feature
```

### Sync Fork (if contributing from fork)

```bash
# Add upstream remote (once)
git remote add upstream https://github.com/alirezarezvani/ClaudeForge.git

# Update from upstream
git fetch upstream
git checkout dev
git merge upstream/dev
git push origin dev
```

### Rename Branch

```bash
# Rename current branch
git branch -m new-branch-name

# Push with new name
git push -u origin new-branch-name

# Delete old branch on remote
git push origin --delete old-branch-name
```

### Delete Merged Branches

```bash
# Delete local branch after merge
git branch -d feature/my-feature

# Delete remote branch
git push origin --delete feature/my-feature

# Prune deleted remote branches
git fetch --prune
```

---

## Common Scenarios

### Scenario 1: Feature PR Rejected by Workflow

**Problem:** PR validation fails with "Invalid branch name"

**Solution:**
```bash
# Rename branch
git branch -m feature/correct-name

# Force push
git push --force-with-lease origin feature/correct-name

# Update PR with new branch
```

### Scenario 2: Need to Update PR Title

**Problem:** PR title doesn't follow Conventional Commits

**Solution:**
1. Go to PR page on GitHub
2. Click "Edit" next to PR title
3. Update to format: `type(scope): description`
4. Save
5. Workflow re-runs automatically

### Scenario 3: Forgot to Update CHANGELOG.md

**Problem:** dev-to-main warns CHANGELOG.md not updated

**Solution:**
```bash
# On dev branch
git checkout dev
git pull origin dev

# Edit CHANGELOG.md
# Add version entry under [Unreleased] or create new [1.1.0] section

git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for v1.1.0"
git push origin dev

# PR to main will now pass CHANGELOG check
```

### Scenario 4: Emergency Hotfix Needed

**Problem:** Critical bug in production (main)

**Solution:**
```bash
# Create hotfix from dev (not main)
git checkout dev
git pull origin dev
git checkout -b hotfix/critical-bug

# Make minimal fix
git add .
git commit -m "fix(installer): resolve critical security issue"
git push -u origin hotfix/critical-bug

# Create PR to dev, get fast-track approval
# After merge to dev, immediately create PR dev → main
# After merge to main, create hotfix release v1.0.1
```

### Scenario 5: Multiple Features in Development

**Problem:** Need to work on feature B while feature A is in review

**Solution:**
```bash
# Feature A already in PR
git checkout dev
git pull origin dev

# Start feature B from latest dev
git checkout -b feature/feature-b

# Work independently
# Both PRs can be reviewed in parallel
# Merge order doesn't matter (both target dev)
```

---

## Best Practices

### ✅ Do

- ✅ Create descriptive branch names
- ✅ Follow Conventional Commits format
- ✅ Link issues in PR description
- ✅ Update CHANGELOG.md for releases
- ✅ Keep feature branches short-lived (< 1 week)
- ✅ Sync with dev frequently
- ✅ Write clear commit messages
- ✅ Test locally before pushing
- ✅ Respond to review comments
- ✅ Delete merged branches

### ❌ Don't

- ❌ Commit directly to main or dev
- ❌ Force push to main or dev
- ❌ Merge without quality gates passing
- ❌ Use vague commit messages
- ❌ Include unrelated changes in PR
- ❌ Commit secrets or sensitive data
- ❌ Leave stale branches unmerged
- ❌ Skip code review
- ❌ Bypass branch protection (even admins)
- ❌ Merge without linked issue (for features/fixes)

---

## Related Documentation

- [GITHUB_WORKFLOWS.md](./GITHUB_WORKFLOWS.md) - Workflow details and automation
- [CONTRIBUTING.md](./CONTRIBUTING.md) - How to contribute
- [CHANGELOG.md](../CHANGELOG.md) - Version history

---

## Questions?

**Issues:** Report at [GitHub Issues](https://github.com/alirezarezvani/ClaudeForge/issues)

**Discussions:** Ask in [GitHub Discussions](https://github.com/alirezarezvani/ClaudeForge/discussions)
