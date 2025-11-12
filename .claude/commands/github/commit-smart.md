---
title: /commit-smart
description: Create smart commit with quality checks and conventional format
---

# Smart Commit with Quality Gates

You are helping the user create a well-formatted commit with pre-commit validation.

## Workflow

1. **Check Staged Changes**
   ```bash
   git status
   git diff --cached --stat
   ```
   - Show what files are staged
   - If nothing staged, ask user what to add

2. **Pre-Commit Quality Checks**

   Run local quality gates before committing:

   **Python syntax** (if .py files changed):
   ```bash
   flake8 skill/ --count --select=E9,F63,F7,F82 --show-source
   ```

   **Bash syntax** (if .sh files changed):
   ```bash
   bash -n install.sh
   bash -n hooks/pre-commit.sh
   ```

   **Secret scan**:
   ```bash
   git diff --cached | grep -iE "(api_key|api_secret|password|token|AWS_ACCESS)" || echo "No secrets detected"
   ```

3. **Generate Conventional Commit Message**

   Ask user about the change:
   - Type: feat, fix, docs, style, refactor, perf, test, build, ci, chore
   - Scope: installer, skill, command, agent, docs, ci, workflows
   - Description: what changed (imperative mood)
   - Why: reason for change (optional body)
   - Issue: related issue number

   **Format:**
   ```
   <type>(<scope>): <description>

   [optional body explaining why]

   [optional footer: Closes #123]
   ```

4. **Validate Message Format**
   - Check format matches Conventional Commits
   - Ensure subject is imperative mood ("add" not "added")
   - Verify no period at end
   - Check length < 50 characters for subject

5. **Create Commit**
   ```bash
   git commit -m "<generated message>"
   ```

6. **Post-Commit Actions**
   - Show commit hash
   - Show commit in log
   - Ask if user wants to push

## Examples

**Feature commit:**
```bash
git commit -m "feat(installer): add Windows PowerShell support

Adds install.ps1 script with equivalent functionality to
install.sh for Windows users.

Closes #42"
```

**Fix commit:**
```bash
git commit -m "fix(skill): correct Python syntax validation

Fix flake8 configuration to properly detect syntax errors.
Previous config was too permissive.

Fixes #156"
```

**Docs commit:**
```bash
git commit -m "docs: update GitHub workflows documentation

Add troubleshooting section and configuration examples."
```

## Quality Gates

Before committing, ensure:
- ✅ No syntax errors
- ✅ No hardcoded secrets
- ✅ Conventional Commits format
- ✅ Related issue linked (for feat/fix)
- ✅ Files staged are relevant to commit message

## Interactive Flow

1. Show staged changes
2. Run quality checks
3. Ask for commit details (type, scope, description)
4. Generate commit message
5. Show preview
6. Confirm with user
7. Execute commit
8. Display result

Use clear prompts and provide the exact commands for the user to run.
