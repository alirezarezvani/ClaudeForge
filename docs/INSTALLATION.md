# Installation Guide

Complete installation instructions for ClaudeForge on all supported platforms.

---

## Prerequisites

### Required
- **Claude Code** 2.0 or later
- **Operating System:** macOS, Linux, or Windows

### Recommended
- **Git** (for change detection by guardian agent)
- Terminal access (macOS/Linux) or PowerShell (Windows)

---

## Installation Methods

### Method 1: One-Line Install (Recommended)

#### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.sh | bash
```

#### Windows (PowerShell as Administrator)

```powershell
iwr https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.ps1 -useb | iex
```

**What this does:**
1. Downloads the installer script
2. Prompts for installation scope (user-level or project-level)
3. Copies all components to appropriate directories
4. Creates backups of any existing installations
5. Optionally installs quality hooks

---

### Method 2: Manual Git Clone

```bash
# Clone the repository
git clone https://github.com/alirezarezvani/ClaudeForge.git

# Navigate to directory
cd ClaudeForge

# Run installer
./install.sh  # macOS/Linux
# or
.\install.ps1  # Windows
```

---

### Method 3: Manual Installation (Advanced)

If you prefer to manually copy files:

#### Step 1: Download Components

Download the latest release from:
https://github.com/alirezarezvani/ClaudeForge/releases

#### Step 2: Choose Installation Scope

**User-Level (Recommended)** - Available in all Claude Code projects:
```bash
# macOS/Linux
INSTALL_DIR="$HOME/.claude"

# Windows
$INSTALL_DIR="$env:USERPROFILE\.claude"
```

**Project-Level** - Available only in current project:
```bash
# macOS/Linux
INSTALL_DIR="./.claude"

# Windows
$INSTALL_DIR=".\.claude"
```

#### Step 3: Copy Components

```bash
# Create directories
mkdir -p "$INSTALL_DIR/skills"
mkdir -p "$INSTALL_DIR/commands"
mkdir -p "$INSTALL_DIR/agents"

# Copy skill
cp -r skill "$INSTALL_DIR/skills/claudeforge-skill"

# Copy slash command
cp -r command "$INSTALL_DIR/commands/enhance-claude-md"

# Copy guardian agent
cp agent/claude-md-guardian.md "$INSTALL_DIR/agents/"
```

#### Step 4: Restart Claude Code

Close and restart Claude Code to load the new components.

---

## Installation Scopes

### User-Level Installation

**Location:** `~/.claude/` (or `%USERPROFILE%\.claude` on Windows)

**Advantages:**
- ✅ Available in all Claude Code projects
- ✅ Install once, use everywhere
- ✅ Automatic updates apply globally

**Use When:**
- You work on multiple projects
- You want consistent CLAUDE.md standards across all projects
- You're the primary developer on your machine

### Project-Level Installation

**Location:** `./.claude/` (in your project root)

**Advantages:**
- ✅ Project-specific configuration
- ✅ Version controlled with project (can commit to git)
- ✅ Team members get same tools

**Use When:**
- Different projects need different versions
- You want to version control the tools
- Team collaboration requires shared tooling

---

## Verification

After installation, verify all components are installed correctly:

### Check Skill Installation

```bash
# macOS/Linux
ls -la ~/.claude/skills/claudeforge-skill/

# Windows
dir $env:USERPROFILE\.claude\skills\claudeforge-skill\
```

**Expected output:**
```
analyzer.py
generator.py
template_selector.py
validator.py
workflow.py
SKILL.md
README.md
examples/
```

### Check Command Installation

```bash
# macOS/Linux
ls -la ~/.claude/commands/enhance-claude-md/

# Windows
dir $env:USERPROFILE\.claude\commands\enhance-claude-md\
```

**Expected output:**
```
enhance-claude-md.md
README.md
```

### Check Agent Installation

```bash
# macOS/Linux
ls -la ~/.claude/agents/claude-md-guardian.md

# Windows
dir $env:USERPROFILE\.claude\agents\claude-md-guardian.md
```

### Test in Claude Code

1. Restart Claude Code
2. Open any project
3. Run the command:
   ```
   /enhance-claude-md
   ```
4. You should see the multi-phase workflow start

---

## Quality Hooks (Optional)

During installation, you'll be asked if you want to install quality hooks.

**What are Quality Hooks?**
- Pre-commit validation that checks CLAUDE.md quality before commits
- Ensures best practices compliance
- Only available for project-level installations

**To Install Hooks:**

```bash
# During installer
# When prompted: "Would you like to install quality hooks?"
# Type: y

# Or manually:
mkdir -p .claude/hooks
cp hooks/pre-commit.sh .claude/hooks/
chmod +x .claude/hooks/pre-commit.sh
```

**To Use Hooks:**

Configure git to use the hook:
```bash
# Add to .git/config or use git config
git config core.hooksPath .claude/hooks
```

---

## Troubleshooting Installation

### Issue: "Installation files not found"

**Cause:** Running installer from wrong directory

**Solution:**
```bash
cd ClaudeForge  # Navigate to repository root
./install.sh     # Run from correct directory
```

---

### Issue: "Permission denied"

**Cause:** Installer doesn't have execute permission

**Solution:**
```bash
chmod +x install.sh  # macOS/Linux
# or run with bash explicitly
bash install.sh
```

---

### Issue: "~/.claude directory not found"

**Cause:** Claude Code not installed or hasn't been run yet

**Solution:**
1. Ensure Claude Code is installed
2. Run Claude Code at least once to create directory structure
3. Or let installer create directories (it will prompt)

---

### Issue: Command not recognized after installation

**Cause:** Claude Code hasn't reloaded components

**Solution:**
1. Fully quit Claude Code (not just close window)
2. Restart Claude Code
3. Wait a few seconds for components to load
4. Try command again: `/enhance-claude-md`

---

### Issue: "Skill not found" error

**Cause:** Skill directory name mismatch

**Solution:**
```bash
# Verify skill directory name is exactly:
ls ~/.claude/skills/
# Should show: claudeforge-skill

# If different, rename:
mv ~/.claude/skills/old-name ~/.claude/skills/claudeforge-skill
```

---

### Issue: Windows installer fails with execution policy error

**Cause:** PowerShell execution policy restricts scripts

**Solution:**
```powershell
# Run PowerShell as Administrator
# Set execution policy temporarily:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Then run installer:
.\install.ps1
```

---

## Updating ClaudeForge

To update to a newer version:

### Method 1: Using Installer

```bash
# Pull latest changes
cd ClaudeForge
git pull origin main

# Run installer (existing installation will be backed up)
./install.sh
```

### Method 2: Manual Update

```bash
# Backup current installation
mv ~/.claude/skills/claudeforge-skill ~/.claude/skills/claudeforge-skill.backup

# Copy new version
cp -r skill ~/.claude/skills/claudeforge-skill

# Repeat for command and agent
```

---

## Uninstallation

To completely remove ClaudeForge:

### User-Level Uninstall

```bash
# macOS/Linux
rm -rf ~/.claude/skills/claudeforge-skill
rm -rf ~/.claude/commands/enhance-claude-md
rm -f ~/.claude/agents/claude-md-guardian.md

# Windows (PowerShell)
Remove-Item -Recurse -Force $env:USERPROFILE\.claude\skills\claudeforge-skill
Remove-Item -Recurse -Force $env:USERPROFILE\.claude\commands\enhance-claude-md
Remove-Item -Force $env:USERPROFILE\.claude\agents\claude-md-guardian.md
```

### Project-Level Uninstall

```bash
# macOS/Linux
rm -rf ./.claude/skills/claudeforge-skill
rm -rf ./.claude/commands/enhance-claude-md
rm -f ./.claude/agents/claude-md-guardian.md
rm -rf ./.claude/hooks  # If quality hooks were installed

# Windows (PowerShell)
Remove-Item -Recurse -Force .\.claude\skills\claudeforge-skill
Remove-Item -Recurse -Force .\.claude\commands\enhance-claude-md
Remove-Item -Force .\.claude\agents\claude-md-guardian.md
Remove-Item -Recurse -Force .\.claude\hooks
```

After uninstalling, restart Claude Code.

---

## Next Steps

After successful installation:

1. **Read Quick Start Guide:** [QUICK_START.md](QUICK_START.md)
2. **Test the command:** Run `/enhance-claude-md` in a project
3. **Review Architecture:** [ARCHITECTURE.md](ARCHITECTURE.md)
4. **Explore Examples:** Check `examples/` directory

---

## Support

If you encounter installation issues not covered here:

- **GitHub Issues:** https://github.com/alirezarezvani/ClaudeForge/issues
- **Troubleshooting Guide:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Discussions:** https://github.com/alirezarezvani/ClaudeForge/discussions

---

**Installation successful?** Proceed to [Quick Start Guide](QUICK_START.md) →
