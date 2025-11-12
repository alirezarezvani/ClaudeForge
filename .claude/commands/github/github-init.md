---
title: /github-init
description: Initialize ClaudeForge CI/CD system
---

# GitHub CI/CD Initialization

You are helping the user initialize the ClaudeForge CI/CD system.

## Workflow

1. **Check Current State**
   - Verify `.github/workflows/` directory exists
   - Check if bootstrap workflow has been run (look for labels/milestones)
   - Check if dev branch exists
   - Check branch protection status

2. **Run Bootstrap Workflow**
   - If not yet run, guide user to run bootstrap workflow:
     - Go to Actions → Bootstrap Repository → Run workflow
     - Enable all options (create labels, milestones, validate settings)
   - Explain what will be created (23 labels, 3 milestones)

3. **Create Dev Branch** (if not exists)
   ```bash
   git checkout -b dev
   git push -u origin dev
   ```

4. **Configure Branch Protection**

   Guide user step-by-step:

   **For main branch:**
   - Go to Settings → Branches → Add rule
   - Pattern: `main`
   - Enable:
     - Require PR before merging
     - Require status checks: `quality-gates`, `production-build`, `validate-release-pr`
     - Require linear history
     - Block force pushes
     - Restrict deletions

   **For dev branch:**
   - Pattern: `dev`
   - Enable:
     - Require PR before merging
     - Require status checks: `quality-gates`, `validate-pr`
     - Require linear history
     - Block force pushes
     - Restrict deletions

5. **Set Default Branch**
   - Settings → General → Default branch → Change to `dev`
   - This ensures new PRs target dev by default

6. **Verification**
   - Show current branch protection rules
   - Verify workflows are present
   - Confirm setup is complete

7. **Next Steps**
   - Point to docs/GITHUB_WORKFLOWS.md for workflow reference
   - Point to docs/BRANCHING_STRATEGY.md for branch flow
   - Suggest creating first feature branch to test

## Commands to provide

```bash
# Check current setup
gh repo view --json name,defaultBranchRef,hasIssuesEnabled

# List workflows
ls -la .github/workflows/

# Check labels
gh label list

# Check milestones
gh api repos/:owner/:repo/milestones

# Check branch protection
gh api repos/:owner/:repo/branches/main/protection 2>/dev/null || echo "Not protected"
gh api repos/:owner/:repo/branches/dev/protection 2>/dev/null || echo "Not protected"
```

## Success Criteria

✅ Bootstrap workflow run successfully
✅ Dev branch created and pushed
✅ Branch protection configured for main and dev
✅ Default branch set to dev
✅ User understands next steps

Provide clear, step-by-step guidance with actual commands the user can copy-paste.
