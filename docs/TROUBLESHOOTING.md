# Troubleshooting Guide

Common issues and solutions for ClaudeForge.

---

## Installation Issues

### Issue: Command not recognized after installation

**Symptoms:**
- `/enhance-claude-md` shows "command not found"
- Slash command doesn't autocomplete

**Causes:**
- Claude Code hasn't reloaded components
- Incorrect installation path
- Insufficient permissions

**Solutions:**

1. **Restart Claude Code completely:**
   ```bash
   # Quit Claude Code entirely (not just close window)
   # Reopen Claude Code
   # Wait 5-10 seconds for components to load
   ```

2. **Verify installation paths:**
   ```bash
   # macOS/Linux
   ls -la ~/.claude/commands/enhance-claude-md/
   ls -la ~/.claude/skills/claudeforge-skill/
   ls -la ~/.claude/agents/claude-md-guardian.md

   # Windows
   dir %USERPROFILE%\.claude\commands\enhance-claude-md\
   dir %USERPROFILE%\.claude\skills\claudeforge-skill\
   dir %USERPROFILE%\.claude\agents\claude-md-guardian.md
   ```

3. **Reinstall with correct permissions:**
   ```bash
   chmod +x install.sh  # macOS/Linux
   ./install.sh
   ```

---

### Issue: "Skill not found" error

**Symptoms:**
- Error message: "claude-md-enhancer skill not found"
- Slash command runs but fails

**Cause:** Skill directory name mismatch or missing skill files

**Solutions:**

1. **Check skill directory name (must be exact):**
   ```bash
   ls ~/.claude/skills/
   # Must show: claudeforge-skill
   ```

2. **Verify skill files exist:**
   ```bash
   ls ~/.claude/skills/claudeforge-skill/
   # Must contain: SKILL.md, analyzer.py, generator.py, etc.
   ```

3. **Reinstall skill only:**
   ```bash
   rm -rf ~/.claude/skills/claudeforge-skill
   cp -r skill ~/.claude/skills/claudeforge-skill
   ```

---

### Issue: Windows PowerShell execution policy error

**Symptoms:**
- Error: "execution of scripts is disabled on this system"

**Cause:** PowerShell security settings

**Solution:**
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

---

## Usage Issues

### Issue: Quality score unexpectedly low

**Symptoms:**
- Quality score < 50
- Many "missing section" warnings

**Causes:**
- Basic CLAUDE.md without native format sections
- File too short (< 20 lines) or too long (> 400 lines)
- Missing required sections

**Solutions:**

1. **Let ClaudeForge add missing sections:**
   ```bash
   /enhance-claude-md
   # Claude will identify missing sections
   # Confirm enhancement
   # Quality score will improve
   ```

2. **Check file length:**
   ```bash
   wc -l CLAUDE.md
   # Recommended: 20-300 lines
   # If > 300: Consider modular architecture
   ```

3. **Manually add required sections:**
   - Core Principles
   - Tech Stack
   - Workflow Instructions
   - Project Structure (ASCII diagram)
   - Setup & Installation

---

### Issue: Generated content too generic

**Symptoms:**
- CLAUDE.md doesn't mention specific tech stack
- No project-specific guidelines
- Feels like template without customization

**Causes:**
- Project detection failed (no package.json, requirements.txt, etc.)
- Insufficient project context

**Solutions:**

1. **Provide explicit context:**
   ```bash
   /enhance-claude-md

   # When Claude asks, specify:
   "This is a Python FastAPI microservice with PostgreSQL, Redis, and Docker. Team of 8 developers, MVP phase."
   ```

2. **Add project files before running:**
   ```bash
   # Ensure detection files exist:
   touch package.json      # Node.js
   touch requirements.txt  # Python
   touch go.mod            # Go
   touch Cargo.toml        # Rust
   ```

3. **Manual customization after generation:**
   - Edit generated CLAUDE.md
   - Add project-specific conventions
   - Include team standards

---

### Issue: Modular architecture not recommended

**Symptoms:**
- Single CLAUDE.md generated for large project
- File exceeds 300 lines

**Causes:**
- Project type not detected as `fullstack`
- Team size estimated as `small`

**Solutions:**

1. **Explicitly request modular:**
   ```bash
   /enhance-claude-md

   # Tell Claude:
   "Use modular architecture with separate files for backend, frontend, and database"
   ```

2. **Create backend/ and frontend/ directories:**
   ```bash
   mkdir -p backend frontend
   # Then run /enhance-claude-md
   ```

3. **Manual split if needed:**
   ```bash
   # Create context files manually:
   touch backend/CLAUDE.md
   touch frontend/CLAUDE.md

   # Then run enhancement on each:
   cd backend && /enhance-claude-md
   cd frontend && /enhance-claude-md
   ```

---

### Issue: Guardian agent not updating automatically

**Symptoms:**
- Made significant changes
- Started new session
- CLAUDE.md not updated

**Causes:**
- Agent not installed
- Changes below significance threshold
- Git repository not initialized

**Solutions:**

1. **Verify agent installation:**
   ```bash
   ls ~/.claude/agents/claude-md-guardian.md
   ```

2. **Check git repository:**
   ```bash
   git status
   # Agent requires git for change detection
   ```

3. **Manually invoke agent:**
   ```bash
   # In Claude Code:
   Claude, invoke claude-md-guardian to update CLAUDE.md
   ```

4. **Lower significance threshold (if needed):**
   Edit `agent/claude-md-guardian.md`:
   ```markdown
   # Change from 5 to 3 files minimum
   - Less than 5 files modified  # Change to 3
   ```

---

## Output Issues

### Issue: CLAUDE.md missing Project Structure diagram

**Symptoms:**
- No ASCII tree diagram in output
- Native format incomplete

**Cause:** Template generation skipped structure section

**Solution:**

1. **Regenerate with explicit request:**
   ```bash
   /enhance-claude-md

   # Tell Claude:
   "Add Project Structure section with ASCII tree diagram"
   ```

2. **Manual addition:**
   ```markdown
   ## Project Structure

   ```
   project/
   ├── src/
   │   ├── components/
   │   └── services/
   └── tests/
   ```
   ```

---

### Issue: Setup & Installation section generic

**Symptoms:**
- Says "npm install" for Python project
- Incorrect commands

**Cause:** Tech stack detection mismatch

**Solution:**

1. **Verify tech stack detection:**
   ```bash
   # Check project files:
   ls package.json requirements.txt go.mod
   ```

2. **Regenerate with correct context:**
   ```bash
   /enhance-claude-md

   "This is a Python project, not Node.js"
   ```

3. **Manual fix:**
   Edit CLAUDE.md and correct commands

---

## Performance Issues

### Issue: Guardian agent too slow

**Symptoms:**
- Agent takes > 30 seconds
- Multiple updates in single session

**Causes:**
- Model set to sonnet instead of haiku
- Full regeneration instead of targeted update

**Solutions:**

1. **Verify agent model:**
   ```bash
   grep "model:" ~/.claude/agents/claude-md-guardian.md
   # Should be: model: haiku
   ```

2. **Check agent workflow:**
   - Should use targeted section updates
   - Not full file regeneration

---

### Issue: Slash command timeout

**Symptoms:**
- Command starts but never completes
- "Timeout" error

**Causes:**
- Large repository exploration
- Network issues (if fetching remote content)

**Solutions:**

1. **Run in smaller scope:**
   ```bash
   cd specific-directory
   /enhance-claude-md
   ```

2. **Skip exploration, provide context directly:**
   ```bash
   /enhance-claude-md

   "Skip exploration. Create CLAUDE.md for TypeScript React app with PostgreSQL."
   ```

---

## Integration Issues

### Issue: Git commands fail in agent

**Symptoms:**
- Agent error: "git: command not found"
- Agent can't detect changes

**Cause:** Git not installed or not in PATH

**Solutions:**

1. **Install git:**
   ```bash
   # macOS
   brew install git

   # Ubuntu/Debian
   sudo apt-get install git

   # Windows
   # Download from git-scm.com
   ```

2. **Verify git installation:**
   ```bash
   git --version
   # Should show: git version 2.x
   ```

---

### Issue: Quality hooks not working

**Symptoms:**
- Pre-commit hook doesn't run
- No validation before commit

**Causes:**
- Hook not executable
- Git not configured to use hooks
- Wrong hooks directory

**Solutions:**

1. **Make hook executable:**
   ```bash
   chmod +x .claude/hooks/pre-commit.sh
   ```

2. **Configure git:**
   ```bash
   git config core.hooksPath .claude/hooks
   ```

3. **Test hook manually:**
   ```bash
   ./.claude/hooks/pre-commit.sh
   # Should validate CLAUDE.md
   ```

---

## Validation Errors

### Issue: "File length exceeds recommended maximum"

**Symptoms:**
- Validation warning: File > 300 lines
- Quality score penalty

**Cause:** Single file too large

**Solution:**

1. **Split into modular architecture:**
   ```bash
   /enhance-claude-md

   "Convert to modular architecture with separate backend and frontend files"
   ```

2. **Remove unnecessary content:**
   - Delete redundant sections
   - Move detailed examples to separate docs
   - Link to external documentation

---

### Issue: "Missing required sections"

**Symptoms:**
- Validation fails
- Lists missing: Core Principles, Tech Stack, etc.

**Solution:**

1. **Let ClaudeForge add them:**
   ```bash
   /enhance-claude-md
   # Claude will identify and add missing sections
   ```

2. **Manual addition:**
   Add required sections following native format

---

## Common Error Messages

### "CLAUDE.md not found"

**Meaning:** File doesn't exist (expected for new projects)

**Action:** Continue with initialization workflow

---

### "Quality score: 0/100"

**Meaning:** Empty or invalid file

**Action:** Regenerate completely

---

### "Invalid project structure"

**Meaning:** Cannot detect project type

**Action:** Add project files (package.json, etc.) or provide context manually

---

### "Template selection failed"

**Meaning:** No matching template for project

**Action:** Provide more specific project context

---

## Getting Help

If your issue isn't covered here:

1. **Check GitHub Issues:**
   https://github.com/alirezarezvani/ClaudeForge/issues

2. **Search Discussions:**
   https://github.com/alirezarezvani/ClaudeForge/discussions

3. **Open New Issue:**
   - Describe the problem
   - Include steps to reproduce
   - Attach relevant logs or errors
   - Mention your OS and Claude Code version

4. **Review Documentation:**
   - [INSTALLATION.md](INSTALLATION.md)
   - [QUICK_START.md](QUICK_START.md)
   - [ARCHITECTURE.md](ARCHITECTURE.md)
   - [CLAUDE.md](../CLAUDE.md)

---

## Debug Mode

To get more detailed output:

```bash
# Run installer with verbose output:
bash -x install.sh

# Check Claude Code logs:
# macOS: ~/Library/Logs/Claude Code/
# Linux: ~/.config/claude-code/logs/
# Windows: %APPDATA%\Claude Code\logs\
```

---

**Still having issues?** We're here to help!

Open an issue: https://github.com/alirezarezvani/ClaudeForge/issues/new
