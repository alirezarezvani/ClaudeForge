# Migrating to ClaudeForge v2.0 (Claude Code v2.1.4+)

## Overview

ClaudeForge v2.0 adds support for Claude Code v2.1.4+ features including hooks, modern permission syntax, and hot-reload capabilities.

## What Changed

### Permissions Syntax

**Before (v1.x):**
```yaml
tools: Bash, Read, Write
allowed-tools: Bash(ls:*), Read, Glob
```

**After (v2.0):**
```yaml
permissions:
  allow:
    - Bash
    - Read
    - Write
    - Glob
```

### Guardian Agent Hooks

The guardian agent now responds to lifecycle events:

- **SessionStart**: Checks for CLAUDE.md updates when Claude Code starts
- **PreToolUse/PostToolUse**: Validates changes before/after writing

Example hook configuration:
```yaml
hooks:
  - event: SessionStart
    commands:
      - echo "Guardian: Checking for CLAUDE.md updates..."
    once: false
```

### Hot-Reload

Skills now reload automatically when modified in Claude Code 2.1.0+ (no restart needed).

### Fork-Safe Mode

Guardian agent now includes `fork_safe: true` to run independently without blocking other operations.

---

## Migration Steps

### 1. Backup Your Existing Installation

```bash
# macOS/Linux
cp -r ~/.claude/skills/claudeforge-skill ~/.claude/skills/claudeforge-skill.backup
cp -r ~/.claude/commands/enhance-claude-md ~/.claude/commands/enhance-claude-md.backup
cp ~/.claude/agents/claude-md-guardian.md ~/.claude/agents/claude-md-guardian.md.backup
```

```powershell
# Windows
Copy-Item -Path "$env:USERPROFILE\.claude\skills\claudeforge-skill" -Destination "$env:USERPROFILE\.claude\skills\claudeforge-skill.backup" -Recurse
Copy-Item -Path "$env:USERPROFILE\.claude\commands\enhance-claude-md" -Destination "$env:USERPROFILE\.claude\commands\enhance-claude-md.backup" -Recurse
Copy-Item -Path "$env:USERPROFILE\.claude\agents\claude-md-guardian.md" -Destination "$env:USERPROFILE\.claude\agents\claude-md-guardian.md.backup"
```

### 2. Run the Installer

```bash
# macOS/Linux
./install.sh
```

```powershell
# Windows
.\install.ps1
```

The installer will:
- ✅ Detect your Claude Code version
- ✅ Automatically backup v1.x installations
- ✅ Install v2.0 with updated syntax
- ✅ Validate v2.1.4 compatibility

### 3. Restart Claude Code

Restart Claude Code to activate the SessionStart hooks:

```bash
# Exit and restart
exit
claude
```

### 4. Test the Migration

```bash
# Test the slash command
/enhance-claude-md

# Or invoke the skill directly
"Please enhance my CLAUDE.md file"
```

You should see:
- ✅ "Starting CLAUDE.md enhancement workflow" (command hook)
- ✅ "Guardian: Checking for CLAUDE.md updates..." (on session start)

---

## Troubleshooting

### "Permission denied" errors

**Cause:** Incorrect permission syntax in YAML frontmatter

**Solution:**
1. Check that `permissions.allow` array is properly formatted
2. Verify indentation (2 spaces for YAML)
3. Ensure each tool is on its own line with `-` prefix

Example:
```yaml
permissions:
  allow:
    - Read
    - Write
    - Bash(git:*)
```

### Hooks not firing

**Cause:** Claude Code version < 2.1.0 or hook syntax errors

**Solution:**
1. Verify Claude Code version: `claude --version`
2. Upgrade if needed: `claude update`
3. Check hook syntax matches valid event types:
   - `SessionStart`
   - `PreToolUse`
   - `PostToolUse`
   - `Stop`
4. Restart Claude Code to register hooks

### Guardian agent not auto-updating

**Cause:** SessionStart hook not triggered or git changes not detected

**Solution:**
1. SessionStart requires new session (restart Claude Code completely)
2. Verify git repository is initialized: `git status`
3. Check agent is installed: `ls ~/.claude/agents/claude-md-guardian.md`
4. Check for git changes: `git diff HEAD~10 --name-status`

### "Invalid YAML" errors

**Cause:** Syntax errors in frontmatter

**Solution:**
1. Validate YAML syntax online: https://www.yamllint.com/
2. Check for proper indentation (spaces, not tabs)
3. Ensure colons are followed by spaces
4. Verify array syntax with `-` prefix

### Version detection fails

**Cause:** `claude` command not in PATH

**Solution:**
1. Check Claude Code installation: `which claude`
2. Add to PATH if needed
3. Restart terminal
4. Re-run installer

---

## Rollback

If you need to rollback to v1.x:

### Option 1: Restore from Auto-Backup

The installer creates timestamped backups:

```bash
# List backups
ls ~/.claude/skills/claudeforge-skill.backup.*
ls ~/.claude/commands/enhance-claude-md.backup.*

# Restore (replace timestamp with your backup)
mv ~/.claude/skills/claudeforge-skill.backup.20260107_120000 ~/.claude/skills/claudeforge-skill
mv ~/.claude/commands/enhance-claude-md.backup.20260107_120000 ~/.claude/commands/enhance-claude-md
mv ~/.claude/agents/claude-md-guardian.md.backup.20260107_120000 ~/.claude/agents/claude-md-guardian.md
```

### Option 2: Restore from Manual Backup

```bash
# Restore from your manual backup
rm -rf ~/.claude/skills/claudeforge-skill
rm -rf ~/.claude/commands/enhance-claude-md
rm ~/.claude/agents/claude-md-guardian.md

cp -r ~/.claude/skills/claudeforge-skill.backup ~/.claude/skills/claudeforge-skill
cp -r ~/.claude/commands/enhance-claude-md.backup ~/.claude/commands/enhance-claude-md
cp ~/.claude/agents/claude-md-guardian.md.backup ~/.claude/agents/claude-md-guardian.md
```

### Option 3: Reinstall v1.0.0

```bash
# Download v1.0.0
curl -fsSL https://github.com/alirezarezvani/ClaudeForge/archive/refs/tags/v1.0.0.tar.gz | tar -xz
cd ClaudeForge-1.0.0
./install.sh
```

---

## What's Backward Compatible

✅ **Python Modules**: All 5 Python modules (analyzer.py, validator.py, generator.py, template_selector.py, workflow.py) work with both v1.x and v2.0

✅ **Skill Invocation**: The skill name (`claude-md-enhancer`) remains the same

✅ **Command Invocation**: `/enhance-claude-md` command works identically

✅ **Examples**: All 7 reference CLAUDE.md templates are unchanged

✅ **Functionality**: All analysis, generation, and validation features work the same

## What's Not Backward Compatible

❌ **Frontmatter Syntax**: Old `tools:` and `allowed-tools:` fields are deprecated (but gracefully degraded)

❌ **Hooks**: Only work with Claude Code 2.1.0+

❌ **Hot-Reload**: Only works with Claude Code 2.1.0+

❌ **Fork-Safe Mode**: Only works with Claude Code 2.1.0+

---

## Feature Comparison

| Feature | v1.0 | v2.0 (Claude Code 2.1.4+) |
|---------|------|---------------------------|
| CLAUDE.md Analysis | ✅ | ✅ |
| CLAUDE.md Generation | ✅ | ✅ |
| Quality Validation | ✅ | ✅ |
| Template Selection | ✅ | ✅ |
| Modular Architecture | ✅ | ✅ |
| Permission System | Old syntax | Modern `permissions:` syntax |
| Lifecycle Hooks | ❌ | ✅ SessionStart, Pre/PostToolUse |
| Hot-Reload | ❌ | ✅ Automatic |
| Fork-Safe Mode | ❌ | ✅ Independent execution |
| Auto-Update on Session | ❌ | ✅ Via SessionStart hook |

---

## Verification

After migration, verify your installation:

```bash
# Check file locations
ls -la ~/.claude/skills/claudeforge-skill/SKILL.md
ls -la ~/.claude/commands/enhance-claude-md/enhance-claude-md.md
ls -la ~/.claude/agents/claude-md-guardian.md

# Check for new syntax
grep "permissions:" ~/.claude/skills/claudeforge-skill/SKILL.md
grep "permissions:" ~/.claude/agents/claude-md-guardian.md

# Check for hooks
grep "hooks:" ~/.claude/agents/claude-md-guardian.md

# Test the command
claude
/enhance-claude-md
```

Expected output on session start:
```
Guardian: Checking for CLAUDE.md updates...
```

---

## Getting Help

If you encounter issues during migration:

1. **Check the logs**: Look for error messages during installation
2. **Verify version**: Run `claude --version` to confirm Claude Code 2.1.0+
3. **Review this guide**: Double-check each step
4. **Rollback if needed**: Use one of the rollback options above
5. **Report issues**: https://github.com/alirezarezvani/ClaudeForge/issues

---

## Additional Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks)
- [ClaudeForge GitHub](https://github.com/alirezarezvani/ClaudeForge)
- [ClaudeForge Changelog](https://github.com/alirezarezvani/ClaudeForge/blob/main/CHANGELOG.md)
