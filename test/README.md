# ClaudeForge Testing Scripts

This directory contains validation and rollback scripts for the v2.0.0 migration.

## Scripts

### `validate_migration.sh`

Validates that the ClaudeForge v2.0.0 migration completed successfully.

**Tests:**
1. File existence (skill, command, agent)
2. v2.1.4 syntax validation (`permissions:` fields)
3. Hooks configuration (SessionStart, PreToolUse, PostToolUse)
4. Fork-safe mode enabled
5. Python modules integrity
6. Legacy syntax cleanup
7. Documentation updates
8. Example files unchanged

**Usage:**
```bash
cd /path/to/ClaudeForge
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

[... more tests ...]

===================================
Validation Complete
===================================
Passed: 18
Failed: 0

✅ All tests passed! Migration successful.
```

---

### `rollback.sh`

Rolls back ClaudeForge installation from v2.0.0 to v1.0.0 using automatic backups.

**What it does:**
- Searches for timestamped backups created by the installer
- Restores skill, command, and agent from backups
- Provides alternative manual rollback instructions if no backups found

**Usage:**
```bash
cd /path/to/ClaudeForge
./test/rollback.sh
```

**Expected Output:**
```
=== ClaudeForge Rollback to v1.x ===

Searching for skill backup...
Found backup: claudeforge-skill.backup.20260107_120000
✓ Restored skill from: claudeforge-skill.backup.20260107_120000

[... more restorations ...]

====================================
Rollback Summary
====================================
Components restored: 3

✅ Rollback complete!

Next steps:
1. Restart Claude Code
2. Test with: /enhance-claude-md
```

---

## Testing Workflow

### Before Installation

1. **Backup manually** (extra safety):
   ```bash
   cp -r ~/.claude/skills/claudeforge-skill ~/.claude/skills/claudeforge-skill.manual.backup
   ```

2. **Note your current version**:
   ```bash
   grep "^name:" ~/.claude/skills/claudeforge-skill/SKILL.md
   ```

### After Installation

1. **Run validation**:
   ```bash
   ./test/validate_migration.sh
   ```

2. **Test functionality**:
   ```bash
   claude
   /enhance-claude-md
   ```

3. **Check hooks** (restart Claude Code first):
   - Look for "Guardian: Checking for CLAUDE.md updates..." on startup

### If Something Goes Wrong

1. **Run rollback**:
   ```bash
   ./test/rollback.sh
   ```

2. **Or restore manual backup**:
   ```bash
   rm -rf ~/.claude/skills/claudeforge-skill
   cp -r ~/.claude/skills/claudeforge-skill.manual.backup ~/.claude/skills/claudeforge-skill
   ```

---

## Test Matrix for Installation

| Scenario | Test Steps | Expected Result |
|----------|-----------|-----------------|
| **Fresh Install** | 1. No existing ClaudeForge<br>2. Run `./install.sh`<br>3. Validate | All files installed with v2.1.4 syntax |
| **Upgrade from v1.x** | 1. Have v1.x installed<br>2. Run `./install.sh`<br>3. Validate | Auto-backup created, v2.0 installed |
| **Version Check** | 1. Claude Code 2.1.4+<br>2. Run installer | Version detected, no warnings |
| **Version Check** | 1. Claude Code < 2.1.0<br>2. Run installer | Warning displayed about limited features |
| **Rollback** | 1. Run `./test/rollback.sh`<br>2. Restart Claude | v1.x restored, no hooks |

---

## Continuous Integration

These test scripts can be integrated into CI/CD:

```yaml
# .github/workflows/validate-migration.yml
name: Validate Migration

on:
  push:
    branches: [feature/migrate-v2.1.4-architecture]

jobs:
  test-migration:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run migration validation
        run: |
          # Install to temporary location
          export HOME=/tmp/test-home
          ./install.sh <<< "1"

          # Run validation
          ./test/validate_migration.sh
```

---

## Notes

- Test scripts are designed to be idempotent (can run multiple times)
- All scripts exit with proper codes (0 = success, 1 = failure)
- Scripts provide detailed output for debugging
- Compatible with both macOS and Linux
