---
title: /release
description: Create GitHub release with automated notes
---

# Create GitHub Release

You are helping the user create a GitHub release for ClaudeForge.

## Prerequisites Check

1. **Verify on main branch**
   ```bash
   git branch --show-current
   ```
   - Should be `main`
   - If not, `git checkout main && git pull`

2. **Check for uncommitted changes**
   ```bash
   git status
   ```
   - Should be clean

3. **Verify CHANGELOG.md updated**
   ```bash
   grep -A 10 "## \[" CHANGELOG.md | head -15
   ```
   - Should have entry for new version

## Workflow

1. **Determine Version**
   - Ask user for version number
   - Validate semantic versioning format (X.Y.Z)
   - Examples: 1.1.0, 1.0.1, 2.0.0-beta.1

2. **Check Tag Doesn't Exist**
   ```bash
   git tag -l "v1.1.0"
   ```
   - Should return nothing
   - If tag exists, ask user to choose different version

3. **Verify CHANGELOG.md**
   - Check if version is documented
   - Extract release notes for this version
   - Show preview to user

4. **Run Release Workflow**

   **Option 1: Via GitHub CLI**
   ```bash
   gh workflow run release.yml \
     -f version=1.1.0 \
     -f prerelease=false \
     -f draft=false
   ```

   **Option 2: Via GitHub UI**
   - Go to Actions → Create Release
   - Click "Run workflow"
   - Enter version: 1.1.0
   - Select options (prerelease, draft)
   - Click "Run workflow"

5. **Monitor Workflow**
   ```bash
   gh run list --workflow=release.yml --limit 1
   gh run watch
   ```

6. **Verify Release Created**
   ```bash
   gh release list
   gh release view v1.1.0
   ```

## Release Types

**Stable Release:**
- Version: X.Y.Z (e.g., 1.1.0)
- Prerelease: false
- Draft: false
- Published immediately

**Pre-Release:**
- Version: X.Y.Z-beta.N (e.g., 1.2.0-beta.1)
- Prerelease: true
- Draft: false
- Marked as pre-release on GitHub

**Draft Release:**
- Version: X.Y.Z
- Draft: true
- Not published until manually approved

## Release Notes Generation

The release workflow automatically:
1. Extracts notes from CHANGELOG.md
2. Adds installation instructions
3. Lists commits since last release
4. Includes full changelog link

**Example output:**
```markdown
Release v1.1.0

[Content from CHANGELOG.md]

---

## 📦 Installation

### One-Line Install
```bash
curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.sh | bash
```

## 📝 Commits
- feat(skill): add Rust template (a1b2c3d)
- fix(installer): Windows path fix (e4f5g6h)

**Full Changelog**: https://github.com/alirezarezvani/ClaudeForge/blob/main/CHANGELOG.md
```

## Post-Release Actions

After release is created:

1. **Verify on GitHub**
   - Go to Releases page
   - Check release notes are correct
   - Test one-line installation command

2. **Update References** (if needed)
   - install.sh version reference
   - install.ps1 version reference
   - README.md version badge

3. **Announce Release**
   - Create Discussion post
   - Share on social media
   - Update documentation site

4. **Sync Dev Branch** (recommended)
   ```bash
   git checkout dev
   git merge main
   git push origin dev
   ```

## Example: Creating v1.1.0 Release

```bash
# 1. Ensure on main and up to date
git checkout main
git pull origin main

# 2. Verify CHANGELOG.md
cat CHANGELOG.md | grep -A 20 "\[1.1.0\]"

# 3. Run release workflow
gh workflow run release.yml \
  -f version=1.1.0 \
  -f prerelease=false \
  -f draft=false

# 4. Monitor workflow
gh run watch

# 5. Verify release
gh release view v1.1.0

# 6. Test installation
curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/v1.1.0/install.sh | bash

# 7. Sync dev
git checkout dev
git merge main
git push origin dev
```

## Troubleshooting

**"Tag already exists":**
- Check existing tags: `git tag -l`
- Either delete old tag or use different version

**"Version not in CHANGELOG":**
- Edit CHANGELOG.md
- Add section for new version
- Commit and push to main

**"Workflow failed":**
- Check workflow logs: `gh run view`
- Common issues:
  - Invalid version format
  - Tag conflicts
  - Missing CHANGELOG entry

## Validation

Before creating release, ensure:
- ✅ On main branch, clean working tree
- ✅ CHANGELOG.md has entry for version
- ✅ All tests passing on main
- ✅ PR from dev to main was merged
- ✅ Version number follows semantic versioning
- ✅ Tag v<version> doesn't already exist

## Success Criteria

✅ GitHub release created with auto-generated notes
✅ Git tag created (v1.1.0)
✅ Release appears on Releases page
✅ Installation command works
✅ Dev branch synced with main

Guide user through the process with clear steps and commands they can copy-paste.
