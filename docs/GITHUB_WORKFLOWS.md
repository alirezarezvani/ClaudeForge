# GitHub Workflows Reference

Complete guide to ClaudeForge's CI/CD automation system.

## Overview

ClaudeForge uses GitHub Actions for automated quality validation, release management, and repository setup. The system is built with:

- **4 Composite Actions** - Reusable components (DRY principle)
- **5 Workflows** - Automated pipelines for different scenarios
- **Standard Branching** - feature/* → dev → main flow
- **Quality Gates** - Python, Markdown, Bash, secret validation

---

## Composite Actions

Reusable building blocks used across workflows.

### 1. setup-python-deps

**Location:** `.github/actions/setup-python-deps/`

**Purpose:** Sets up Python with dependency caching for 90%+ faster workflow runs.

**Inputs:**
- `python-version` (optional, default: `3.11`) - Python version to install

**Outputs:**
- `cache-hit` - Whether the cache was hit (true/false)
- `python-version` - Python version that was installed

**What it does:**
1. Installs specified Python version
2. Caches pip dependencies based on requirements.txt
3. Installs validation tools (flake8, pylint, black, mypy)
4. Installs project dependencies if requirements.txt exists

**Usage in workflows:**
```yaml
- name: Setup Python
  uses: ./.github/actions/setup-python-deps
  with:
    python-version: '3.11'
```

---

### 2. fork-safety

**Location:** `.github/actions/fork-safety/`

**Purpose:** Detects fork PRs and prevents malicious write operations.

**Inputs:**
- `github-token` (optional, default: `${{ github.token }}`) - GitHub token

**Outputs:**
- `is-fork` - Whether this is a fork PR (true/false)
- `should-skip-writes` - Whether to skip write operations (true/false)
- `source-repo` - Full name of source repository
- `base-repo` - Full name of base repository

**Security Features:**
- Automatically detects forked pull requests
- Prevents issue updates, labels, and comments from forks
- Protects against malicious actions in fork workflows

**Usage in workflows:**
```yaml
- name: Check fork status
  id: fork-check
  uses: ./.github/actions/fork-safety
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}

- name: Update issue (skip if fork)
  if: steps.fork-check.outputs.should-skip-writes != 'true'
  run: gh issue comment ${{ github.event.number }} --body "Updated"
```

---

### 3. rate-limit-check

**Location:** `.github/actions/rate-limit-check/`

**Purpose:** Circuit breaker pattern to prevent GitHub API exhaustion.

**Inputs:**
- `github-token` (required) - GitHub token for API access
- `minimum-remaining` (optional, default: `50`) - Minimum calls required to proceed
- `fail-on-limit` (optional, default: `false`) - Fail workflow if below threshold

**Outputs:**
- `can-proceed` - Whether enough API calls remain (true/false)
- `remaining` - Number of API calls remaining
- `limit` - Total API rate limit
- `used` - Number of API calls used
- `reset-time` - Unix timestamp when limit resets
- `reset-time-human` - Human-readable reset time

**What it does:**
1. Queries GitHub API rate limit status
2. Checks if remaining calls exceed minimum threshold
3. Warns or fails if rate limit too low
4. Displays usage statistics and reset time

**Usage in workflows:**
```yaml
- name: Check API rate limit
  uses: ./.github/actions/rate-limit-check
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    minimum-remaining: 100
    fail-on-limit: false
```

---

### 4. quality-gates

**Location:** `.github/actions/quality-gates/`

**Purpose:** Comprehensive quality validation for Python, Markdown, Bash, and secrets.

**Inputs:**
- `python-version` (optional, default: `3.11`) - Python version to use
- `skip-python` (optional, default: `false`) - Skip Python validation
- `skip-markdown` (optional, default: `false`) - Skip Markdown validation
- `skip-bash` (optional, default: `false`) - Skip Bash validation
- `skip-secrets` (optional, default: `false`) - Skip secret scanning

**Outputs:**
- `python-passed` - Whether Python validation passed
- `markdown-passed` - Whether Markdown validation passed
- `bash-passed` - Whether Bash validation passed
- `secrets-passed` - Whether secret scanning passed
- `all-passed` - Whether all gates passed

**Quality Checks:**

**Python Validation:**
- Syntax errors (flake8 E9, F63, F7, F82)
- Code style warnings (complexity, line length)
- Validates all `*.py` files in skill/ directory

**Markdown Validation:**
- Empty file detection
- Broken internal link detection
- Validates all `*.md` files (excluding node_modules, .git)

**Bash Validation:**
- Syntax checking with `bash -n`
- Validates all `*.sh` files

**Secret Scanning:**
- Detects patterns: api_key, api_secret, password, token, AWS keys, GITHUB_TOKEN
- Checks for committed .env files
- Filters out false positives (examples, templates)

**Usage in workflows:**
```yaml
- name: Run quality gates
  uses: ./.github/actions/quality-gates
  with:
    python-version: '3.11'
    skip-python: false
    skip-secrets: false
```

---

## Workflows

### 1. Bootstrap Repository

**File:** `.github/workflows/bootstrap.yml`

**Trigger:** Manual (workflow_dispatch)

**Purpose:** One-time repository setup for labels, milestones, and settings validation.

**Inputs:**
- `create-labels` (boolean, default: true) - Create standard labels
- `create-milestones` (boolean, default: true) - Create initial milestones
- `validate-settings` (boolean, default: true) - Validate repository settings

**What it creates:**

**Labels (23 total):**
- **Type:** bug, enhancement, documentation, refactor, performance, security, test
- **Priority:** critical, high, medium, low
- **Status:** blocked, in progress, review needed, needs discussion
- **Component:** installer, skill, command, agent, docs, ci/cd
- **Other:** good first issue, help wanted, dependencies, breaking change

**Milestones (3 total):**
- v1.1.0 (due: +1 month) - Additional templates, enhanced detection
- v1.2.0 (due: +2 months) - VS Code extension, advanced hooks
- v2.0.0 (due: +4 months) - AI suggestions, multi-language, dashboard

**Settings Validation:**
- Checks if Issues, Wiki, Discussions are enabled
- Validates default branch configuration
- Provides recommendations if settings are non-optimal

**How to run:**
1. Go to Actions → Bootstrap Repository
2. Click "Run workflow"
3. Select options (all enabled by default)
4. Click "Run workflow"

**When to run:**
- Once after initial repository setup
- After cloning to a new repository
- To recreate deleted labels/milestones

---

### 2. Reusable PR Checks

**File:** `.github/workflows/reusable-pr-checks.yml`

**Trigger:** Called by other workflows (workflow_call)

**Purpose:** DRY quality gate orchestrator for pull request validation.

**Inputs:**
- `python-version` (string, default: '3.11')
- `skip-python` (boolean, default: false)
- `skip-markdown` (boolean, default: false)
- `skip-bash` (boolean, default: false)
- `skip-secrets` (boolean, default: false)

**What it does:**
1. Checks out code
2. Runs fork safety check
3. Checks GitHub API rate limit
4. Executes all quality gates
5. Generates summary report
6. Fails if any quality gate fails

**Quality Gates:**
- ✅ Python syntax (flake8)
- ✅ Markdown linting
- ✅ Bash script validation
- ✅ Secret scanning

**Called by:**
- pr-into-dev.yml (feature PRs)
- dev-to-main.yml (release PRs)

**Not called directly** - Use pr-into-dev or dev-to-main workflows instead.

---

### 3. PR into Dev

**File:** `.github/workflows/pr-into-dev.yml`

**Trigger:** Pull request to `dev` branch (opened, reopened, synchronize, ready_for_review)

**Purpose:** Validate feature/fix pull requests before merging to dev.

**Validation Steps:**

**1. PR Structure Validation:**
- ✅ **Branch name** must start with: `feature/`, `fix/`, `hotfix/`, `test/`, `refactor/`, `docs/`
- ✅ **PR title** must follow Conventional Commits format:
  - Format: `type(scope): subject`
  - Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
  - Example: `feat(installer): add Windows PowerShell support`
- ✅ **Linked issues** - PR body should reference at least one issue (warning if missing)
  - Keywords: Closes, Fixes, Resolves, Relates to, Ref, References

**2. Quality Checks:**
- Calls reusable-pr-checks.yml
- Runs all quality gates (Python, Markdown, Bash, secrets)

**Auto-comments on failure:**
If validation fails, bot comments with:
- What failed (branch name, PR title)
- How to fix (examples, instructions)
- Link to CONTRIBUTING.md

**Example flow:**
```
Developer creates PR: feature/add-rust-templates → dev
↓
Workflow runs:
1. ✅ Branch name valid (starts with feature/)
2. ❌ PR title invalid (missing conventional format)
3. Bot comments with fix instructions
↓
Developer updates PR title: "feat(skill): add Rust template support"
↓
Workflow re-runs:
1. ✅ Branch name valid
2. ✅ PR title valid
3. ✅ Quality gates pass
↓
PR ready for review!
```

---

### 4. Dev to Main (Release Gate)

**File:** `.github/workflows/dev-to-main.yml`

**Trigger:** Pull request to `main` branch (opened, reopened, synchronize, ready_for_review)

**Purpose:** Production release gate with strict validation.

**Validation Steps:**

**1. Source Branch Validation:**
- ✅ **Only allowed branches:**
  - `dev` (standard release flow)
  - `release/*` (release branches)
  - `dependabot/*` (dependency updates)
- ❌ **NOT allowed:**
  - `feature/*`, `fix/*`, `test/*` - Must merge to dev first

**Auto-comments if invalid branch:**
- Explains which branches can merge to main
- Provides step-by-step fix instructions
- Links to BRANCHING_STRATEGY.md

**2. CHANGELOG.md Check:**
- Checks if CHANGELOG.md was updated in this PR
- Warns if not updated (doesn't fail)
- Recommends adding release notes

**3. Version Consistency:**
- Checks version in CHANGELOG.md
- Checks version references in install.sh/install.ps1
- Warns on version mismatches

**4. Quality Checks:**
- Calls reusable-pr-checks.yml
- Full quality gate validation

**5. Production Build Validation:**
- ✅ install.sh exists and is executable
- ✅ install.ps1 exists
- ✅ All skill modules exist (5 files)
- ✅ Core documentation exists

**Example flow:**
```
Feature branch tries to merge to main:
↓
❌ Workflow fails:
- feature/new-feature is not allowed
- Must merge to dev first
- Bot comments with instructions
↓
Correct flow:
1. feature/new-feature → dev (PR approved and merged)
2. dev → main (PR created)
↓
✅ Workflow passes:
- dev branch allowed
- CHANGELOG.md updated
- Quality gates pass
- Production build valid
↓
Ready for production!
```

---

### 5. Create Release

**File:** `.github/workflows/release.yml`

**Trigger:** Manual (workflow_dispatch)

**Purpose:** Create GitHub releases with automated release notes.

**Inputs:**
- `version` (required) - Release version (e.g., 1.1.0)
- `prerelease` (boolean, default: false) - Mark as pre-release
- `draft` (boolean, default: false) - Create as draft

**Validation:**
1. ✅ Version format (semantic versioning: X.Y.Z or X.Y.Z-beta.1)
2. ✅ Tag doesn't already exist (v1.1.0)
3. ✅ CHANGELOG.md contains version entry (warning if missing)

**Release Notes Generation:**
1. Extracts notes from CHANGELOG.md for the version
2. Adds installation instructions (one-line install + manual)
3. Lists all commits since last release
4. Includes full changelog link

**Example release notes:**
```markdown
Release v1.1.0

[Content from CHANGELOG.md for v1.1.0]

---

## 📦 Installation

### One-Line Install (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.sh | bash
```

### Manual Install
```bash
wget https://github.com/alirezarezvani/ClaudeForge/archive/refs/tags/v1.1.0.tar.gz
tar -xzf v1.1.0.tar.gz
cd ClaudeForge-1.1.0
./install.sh
```

📚 **Documentation**: https://github.com/alirezarezvani/ClaudeForge/blob/main/docs/INSTALLATION.md

## 📝 Commits

- feat(skill): add Rust template support (a1b2c3d)
- fix(installer): correct Windows path handling (e4f5g6h)
...

---

**Full Changelog**: https://github.com/alirezarezvani/ClaudeForge/blob/main/CHANGELOG.md
```

**How to create a release:**

**Option 1: GitHub UI**
1. Go to Actions → Create Release
2. Click "Run workflow"
3. Enter version (e.g., 1.1.0)
4. Select prerelease/draft if needed
5. Click "Run workflow"

**Option 2: `/release` command** (Phase 4)
- Run `/release` slash command in Claude Code
- Follow interactive prompts

**After release created:**
1. GitHub release published with auto-generated notes
2. Git tag created (v1.1.0)
3. Installable via one-line command
4. Consider:
   - Announcing in Discussions
   - Updating README.md badges
   - Sharing on social media

---

## Workflow Execution Order

**Full Development Lifecycle:**

```
1. Bootstrap (once)
   └─ Creates labels, milestones, validates settings

2. Feature Development
   ├─ Developer creates feature/add-templates branch
   ├─ Makes changes, commits
   └─ Creates PR: feature/add-templates → dev

3. PR into Dev
   ├─ pr-into-dev.yml runs
   ├─ Validates branch name, PR title, linked issues
   ├─ Calls reusable-pr-checks.yml
   ├─ quality-gates validates Python, Markdown, Bash, secrets
   └─ ✅ Passes → Ready for review

4. Merge to Dev
   └─ Feature merged to dev branch

5. Release to Main
   ├─ Create PR: dev → main
   ├─ dev-to-main.yml runs
   ├─ Validates source branch (dev allowed)
   ├─ Checks CHANGELOG.md updated
   ├─ Validates production build
   ├─ Calls reusable-pr-checks.yml
   └─ ✅ Passes → Ready for production

6. Create Release
   ├─ Run release.yml workflow
   ├─ Input version: 1.1.0
   ├─ Validates version format, tag availability
   ├─ Extracts release notes from CHANGELOG.md
   ├─ Creates GitHub release with notes
   └─ ✅ Release published!
```

---

## Quality Gates Summary

All PRs (dev and main) must pass these gates:

| Gate | Check | Tool | Fail Condition |
|------|-------|------|----------------|
| Python Syntax | Syntax errors, style violations | flake8 | Syntax error found |
| Markdown Lint | Empty files, broken links | grep | N/A (warnings only) |
| Bash Scripts | Shell syntax | bash -n | Syntax error found |
| Secret Scan | Hardcoded secrets, .env files | grep patterns | .env file committed |
| Branch Name | Convention (feature/*, fix/*) | bash regex | Invalid prefix |
| PR Title | Conventional Commits format | bash regex | Invalid format |
| Linked Issue | References issue with keywords | grep | Warning only |
| Source Branch | Allowed for main (dev, release/*) | bash | Invalid branch |

---

## Troubleshooting

### Workflow fails with "rate limit exceeded"
**Cause:** Too many GitHub API calls in short time

**Fix:**
1. Wait for rate limit reset (shown in logs)
2. Re-run workflow after reset time
3. If persistent, increase `minimum-remaining` in rate-limit-check

### Python validation fails but code is correct
**Cause:** flake8 is strict about style

**Fix:**
1. Check logs for specific errors
2. Run `flake8 skill/` locally to see issues
3. Fix style issues or add `# noqa` comments for exceptions

### Secret scanning detects false positive
**Cause:** Word "password" or "token" in documentation

**Fix:**
1. Check the pattern detected
2. If it's documentation/example, it's safe (warning only)
3. Real secrets will fail the workflow

### Fork PR can't update issues
**Expected behavior:** Fork PRs are restricted for security

**Explanation:**
- Fork PRs run in read-only mode
- Issue updates, labels, comments are skipped
- This prevents malicious actions from forks
- Maintainer can manually update after review

### Branch validation rejects my PR
**Cause:** Branch name doesn't match convention

**Fix:**
1. Rename branch: `git branch -m feature/my-feature`
2. Force push: `git push -f origin feature/my-feature`
3. Update PR with new branch name

### PR title validation fails
**Cause:** Title doesn't follow Conventional Commits

**Fix:**
Update PR title to format: `type(scope): subject`

Examples:
- `feat(installer): add Windows support`
- `fix(skill): correct template selection`
- `docs: update installation guide`

---

## Configuration

### Customizing Quality Gates

To skip specific checks, modify workflow inputs in `pr-into-dev.yml` or `dev-to-main.yml`:

```yaml
quality-checks:
  uses: ./.github/workflows/reusable-pr-checks.yml
  with:
    skip-python: false      # Set to true to skip Python validation
    skip-markdown: false    # Set to true to skip Markdown linting
    skip-bash: false        # Set to true to skip Bash validation
    skip-secrets: false     # Set to true to skip secret scanning
```

### Adjusting Rate Limit Threshold

In workflows using rate-limit-check, adjust `minimum-remaining`:

```yaml
- name: Rate limit check
  uses: ./.github/actions/rate-limit-check
  with:
    minimum-remaining: 100  # Increase if workflow uses many API calls
    fail-on-limit: false    # Set to true to fail instead of warn
```

### Adding Custom Labels

Edit `bootstrap.yml` to add more labels:

```yaml
gh label create "custom-label" --description "Description" --color "hex-color" --force
```

---

## Related Documentation

- [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md) - Branch flow and protection rules
- [CONTRIBUTING.md](./CONTRIBUTING.md) - How to contribute with PR process
- [INSTALLATION.md](./INSTALLATION.md) - User installation guide
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues and solutions

---

## Support

**Issues:** Report bugs or request features at [GitHub Issues](https://github.com/alirezarezvani/ClaudeForge/issues)

**Discussions:** Ask questions in [GitHub Discussions](https://github.com/alirezarezvani/ClaudeForge/discussions)

**Documentation:** Full docs at [docs/](../docs/)
