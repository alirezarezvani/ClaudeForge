# Local Testing Guide for ClaudeForge v2.0.0

This guide walks you through testing the v2.1.4 migration on your local machine before creating a PR.

---

## Prerequisites

- Claude Code 2.1.0+ installed
- Current working directory: `/Users/rezarezvani/projects/ClaudeForge`
- Feature branch checked out: `feature/migrate-v2.1.4-architecture`

---

## Testing Workflow

### Step 1: Backup Your Current ClaudeForge Installation

If you have ClaudeForge installed, back it up first:

```bash
# Check if you have existing installation
ls -la ~/.claude/skills/claudeforge-skill 2>/dev/null && echo "Found existing installation"

# Backup (if exists)
cp -r ~/.claude/skills/claudeforge-skill ~/.claude/skills/claudeforge-skill.pre-v2-test 2>/dev/null
cp -r ~/.claude/commands/enhance-claude-md ~/.claude/commands/enhance-claude-md.pre-v2-test 2>/dev/null
cp ~/.claude/agents/claude-md-guardian.md ~/.claude/agents/claude-md-guardian.md.pre-v2-test 2>/dev/null

echo "✓ Backup complete (if installation existed)"
```

---

### Step 2: Test Fresh Installation

Test installing from scratch:

```bash
# Remove any existing installation
rm -rf ~/.claude/skills/claudeforge-skill
rm -rf ~/.claude/commands/enhance-claude-md
rm ~/.claude/agents/claude-md-guardian.md

# Run the new installer
./install.sh

# Choose option 1 (user-level)
# Press Y to confirm installation
# Press N for quality hooks (we're just testing core features)
```

**Expected Output:**
```
ℹ  Checking Claude Code version...
✓  Claude Code version 2.1.4 detected
ℹ  Where would you like to install ClaudeForge?
...
ℹ  Validating v2.1.4 compatibility...
✓  Guardian agent hooks configured
✓  v2.1.4 compatibility validated
✓  Installation completed successfully!
```

---

### Step 3: Run Validation Script

Verify the installation is correct:

```bash
# Run automated validation
./test/validate_migration.sh
```

**Expected Output:**
```
=== ClaudeForge v2.1.4 Migration Validation ===

Test 1: File Existence
----------------------
✓ Skill file exists
✓ Command file exists
✓ Agent file exists

Test 2: v2.1.4 Syntax Validation
---------------------------------
✓ Skill uses permissions syntax
✓ Command uses permissions syntax
✓ Agent uses permissions syntax

Test 3: Hooks Configuration
---------------------------
✓ Agent has hooks configured
✓ SessionStart hook present
✓ PreToolUse hook present
✓ PostToolUse hook present

Test 4: Fork-Safe Mode
----------------------
✓ Fork-safe mode enabled

Test 5: Python Modules Integrity
--------------------------------
✓ analyzer.py present
✓ validator.py present
✓ generator.py present
✓ template_selector.py present
✓ workflow.py present

Test 6: Legacy Syntax Cleanup
-----------------------------
✓ Agent has no legacy 'tools:' field
✓ Command has no legacy 'allowed-tools:' field

Test 7: Documentation
--------------------
✓ Migration guide exists
✓ CHANGELOG has v2.0.0 entry
✓ README references v2.1.4

Test 8: Example Files Unchanged
-------------------------------
✓ Example files present

===================================
Validation Complete
===================================
Passed: 18
Failed: 0

✅ All tests passed! Migration successful.
```

---

### Step 4: Test Functionality

Test that the skill/command still works:

```bash
# Start Claude Code
claude

# Test the slash command
/enhance-claude-md
```

**What to expect:**
1. Hook message appears: `"Starting CLAUDE.md enhancement workflow"`
2. 3-phase workflow runs normally (Discovery → Analysis → Task)
3. Skill is invoked and works correctly

**Exit Claude Code** when done testing:
```
exit
```

---

### Step 5: Test SessionStart Hook

Test that the guardian agent SessionStart hook fires:

```bash
# Start a new Claude Code session
claude
```

**Expected on startup:**
You should see:
```
Guardian: Checking for CLAUDE.md updates...
```

This confirms the SessionStart hook is working.

**Exit when done:**
```
exit
```

---

### Step 6: Manually Verify Files

Double-check the installed files have correct syntax:

```bash
# Check skill frontmatter
head -20 ~/.claude/skills/claudeforge-skill/SKILL.md

# Should see:
# ---
# name: claude-md-enhancer
# permissions:
#   allow:
#     - Read
#     - Write
#     ...

# Check agent frontmatter
head -30 ~/.claude/agents/claude-md-guardian.md

# Should see:
# ---
# name: claude-md-guardian
# permissions:
#   allow:
#     - Bash
#     - Read
#     ...
# hooks:
#   - event: SessionStart
#     ...
```

---

### Step 7: Test Migration from v1.x (Optional)

If you want to test the migration logic:

```bash
# Create a mock v1.x installation
mkdir -p ~/.claude/skills/claudeforge-skill-mock
cat > ~/.claude/skills/claudeforge-skill-mock/SKILL.md <<'EOF'
---
name: claude-md-enhancer
tools: Bash, Read, Write
---
Old v1.x syntax
EOF

# Temporarily rename to simulate v1.x
mv ~/.claude/skills/claudeforge-skill ~/.claude/skills/claudeforge-skill-real
mv ~/.claude/skills/claudeforge-skill-mock ~/.claude/skills/claudeforge-skill

# Run installer (should detect and backup v1.x)
./install.sh

# Check backup was created
ls ~/.claude/skills/claudeforge-skill.v1_backup* || ls ~/.claude/skills/claudeforge-skill.backup.*

# Verify new syntax
grep "permissions:" ~/.claude/skills/claudeforge-skill/SKILL.md

# Restore real installation
rm -rf ~/.claude/skills/claudeforge-skill
mv ~/.claude/skills/claudeforge-skill-real ~/.claude/skills/claudeforge-skill
```

---

### Step 8: Test Rollback Script

Test that rollback works (using the backup from Step 7):

```bash
# If you have backups from Step 7
./test/rollback.sh

# Verify it restored v1.x syntax
head -10 ~/.claude/skills/claudeforge-skill/SKILL.md

# Then reinstall v2.0 for continued testing
./install.sh
```

---

### Step 9: Test Python Modules Still Work

Verify Python modules weren't accidentally broken:

```bash
# Test Python compilation
python3 -m py_compile skill/analyzer.py
python3 -m py_compile skill/validator.py
python3 -m py_compile skill/generator.py
python3 -m py_compile skill/template_selector.py
python3 -m py_compile skill/workflow.py

echo "✓ All Python modules compile successfully"

# Test imports (from skill directory)
cd skill
python3 -c "from analyzer import CLAUDEMDAnalyzer; print('✓ analyzer.py imports')"
python3 -c "from validator import BestPracticesValidator; print('✓ validator.py imports')"
python3 -c "from generator import ContentGenerator; print('✓ generator.py imports')"
python3 -c "from template_selector import TemplateSelector; print('✓ template_selector.py imports')"
python3 -c "from workflow import InitializationWorkflow; print('✓ workflow.py imports')"
cd ..
```

---

### Step 10: Test in a Real Project

Test the skill on an actual project:

```bash
# Create a test project
mkdir -p /tmp/test-claude-project
cd /tmp/test-claude-project
git init
npm init -y  # Or create any project

# Start Claude Code
claude

# Test the enhancement command
/enhance-claude-md

# Follow the workflow and verify:
# 1. Discovery phase works
# 2. Analysis runs correctly
# 3. CLAUDE.md is generated with correct format
# 4. No errors or warnings

# Exit and clean up
exit
cd /Users/rezarezvani/projects/ClaudeForge
rm -rf /tmp/test-claude-project
```

---

## Quick Test Checklist

Use this checklist for rapid validation:

- [ ] `./install.sh` runs without errors
- [ ] Version detection works (shows your Claude Code version)
- [ ] `./test/validate_migration.sh` shows all tests passing (18/18)
- [ ] `/enhance-claude-md` command works in Claude Code
- [ ] SessionStart hook fires (see "Guardian: Checking..." on startup)
- [ ] Python modules compile without errors
- [ ] `./test/rollback.sh` successfully restores backups
- [ ] Documentation renders correctly (`docs/MIGRATION_V2.md`)

---

## Troubleshooting Local Tests

### "Command not found: claude"

```bash
# Check if Claude Code is installed
which claude

# If not found, install Claude Code first
# Then retry testing
```

### "Permission denied" when running scripts

```bash
# Make scripts executable
chmod +x test/validate_migration.sh
chmod +x test/rollback.sh
chmod +x install.sh
```

### "Python module import failed"

```bash
# Ensure you're in the skill directory
cd skill
python3 -c "import sys; print(sys.path)"
cd ..
```

### Hooks don't fire

- Hooks require Claude Code 2.1.0+
- Check version: `claude --version`
- Restart Claude Code completely (not just exit/claude)
- Close terminal and open a new one

---

## After Testing Successfully

Once all tests pass:

1. **Restore your original installation** (if you want to keep using v1.x):
   ```bash
   ./test/rollback.sh
   # Or manually restore from .pre-v2-test backups
   ```

2. **Keep v2.0 installed** (if you want to use the new version):
   ```bash
   # Already installed, just use it!
   claude
   /enhance-claude-md
   ```

3. **Create the PR**:
   ```bash
   gh pr create --base dev --title "feat(v2.0.0): migrate to Claude Code v2.1.4+ architecture"
   ```

---

## Test Results Log

Keep track of your test results:

| Test | Result | Notes |
|------|--------|-------|
| Fresh install | ☐ Pass ☐ Fail | |
| Validation script | ☐ Pass ☐ Fail | |
| /enhance-claude-md command | ☐ Pass ☐ Fail | |
| SessionStart hook | ☐ Pass ☐ Fail | |
| Python modules | ☐ Pass ☐ Fail | |
| Real project test | ☐ Pass ☐ Fail | |
| Rollback script | ☐ Pass ☐ Fail | |

---

## Getting Help

If you encounter issues during testing:

1. Check the validation script output for specific failures
2. Review `docs/MIGRATION_V2.md` troubleshooting section
3. Check Claude Code version: `claude --version`
4. Verify branch: `git branch` (should show `feature/migrate-v2.1.4-architecture`)

---

## Pro Tip: Test in a Docker Container

For completely isolated testing:

```bash
# Use a Docker container with Claude Code installed
docker run -it -v $(pwd):/workspace ubuntu:latest bash

# Inside container:
cd /workspace
# Install Claude Code
# Run ./install.sh
# Run ./test/validate_migration.sh
```

This ensures no interference from your existing setup.
