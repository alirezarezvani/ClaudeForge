# Quick Start Guide

Get started with ClaudeForge in 5 minutes. This guide walks you through your first CLAUDE.md creation.

---

## 🚀 5-Minute Tutorial

### Step 1: Install ClaudeForge (1 minute)

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.sh | bash

# Windows (PowerShell)
iwr https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.ps1 -useb | iex
```

**Choose:** Option 1 (user-level) for global availability

**Restart Claude Code** after installation

---

### Step 2: Navigate to Your Project (30 seconds)

```bash
cd /path/to/your/project
```

**Requirements:**
- Any code project (doesn't need to be git-initialized, but recommended)
- Works with TypeScript, Python, Go, Java, Ruby, and more

---

### Step 3: Run the Command (10 seconds)

In Claude Code, type:

```bash
/enhance-claude-md
```

---

### Step 4: Interactive Workflow (3 minutes)

ClaudeForge will now:

#### Phase 1: Discovery ✓

Claude explores your project:
```
Checking for existing CLAUDE.md... Not found
Exploring repository structure...
Analyzing package.json, requirements.txt, etc...
```

#### Phase 2: Analysis ✓

Claude shows discoveries:
```
Based on my exploration, here's what I discovered:

📦 Project Type: Full-Stack Application
🛠️ Tech Stack: TypeScript, React, Node.js, PostgreSQL, Docker
👥 Team Size: Small (5 developers detected from git history)
🚀 Development Phase: MVP
⚙️ Workflows: TDD, CI/CD

📋 Recommended Structure:
- Root CLAUDE.md (navigation hub, ~100 lines)
- backend/CLAUDE.md (API guidelines, ~150 lines)
- frontend/CLAUDE.md (React guidelines, ~175 lines)
```

#### Phase 3: Confirmation ✓

Claude asks for your approval:
```
Would you like me to create these files with these settings?
```

**You respond:** `Yes` or `Yes, proceed`

#### Phase 4: Generation ✓

Claude creates your CLAUDE.md files:
```
Creating customized CLAUDE.md files...

✅ Created CLAUDE.md (108 lines)
   - Quick Navigation section
   - 5 Core Principles
   - Tech Stack summary
   - Common commands

✅ Created backend/CLAUDE.md (156 lines)
   - API design guidelines
   - Database operations
   - Testing requirements

✅ Created frontend/CLAUDE.md (182 lines)
   - Component standards
   - State management
   - Performance tips
```

---

### Step 5: Review Your CLAUDE.md (1 minute)

Open the generated file:

```bash
cat CLAUDE.md
```

**You'll see:**
- **Overview** - Project description
- **Project Structure** - ASCII tree diagram
- **Setup & Installation** - How to get started
- **Architecture** - Key patterns and decisions
- **Core Principles** - Development guidelines
- **Tech Stack** - Technologies used
- **Common Commands** - Build, test, lint
- **Development Workflow** - How to contribute

All in **100% native Claude Code format**!

---

## 🎯 What Just Happened?

1. **Explored** your codebase automatically
2. **Detected** project type, tech stack, team size
3. **Generated** customized CLAUDE.md with:
   - Native format compliance
   - Tech-specific best practices
   - Team-appropriate complexity
4. **Created** modular files (if needed)

**Result:** Future Claude Code sessions now have perfect context about your project!

---

## 🔄 Common Workflows

### Scenario A: New Project

```bash
# You: Create a new project
mkdir my-new-app && cd my-new-app
npm init -y

# You: Run ClaudeForge
/enhance-claude-md

# Claude: Explores → Analyzes → Creates CLAUDE.md
```

**Time:** ~2 minutes

---

### Scenario B: Existing Project (No CLAUDE.md)

```bash
# You: Navigate to existing project
cd my-existing-project

# You: Run ClaudeForge
/enhance-claude-md

# Claude: Explores → Detects tech → Creates CLAUDE.md
```

**Time:** ~3 minutes

---

### Scenario C: Improve Existing CLAUDE.md

```bash
# You: Have basic CLAUDE.md
cat CLAUDE.md
# Output: Basic file with just tech stack

# You: Run ClaudeForge
/enhance-claude-md

# Claude: Analyzes current file
# Shows: Quality Score: 55/100
# Missing: Project Structure, Setup, Architecture
# Claude: Adds missing sections

# Result: Quality Score: 55 → 88
```

**Time:** ~2 minutes

---

### Scenario D: Automatic Maintenance

```bash
# You: Make significant changes
npm install react-query
mkdir src/components/auth

# You: Start new Claude Code session
# Guardian agent automatically checks changes

# Agent output:
# ✅ CLAUDE.md updated:
# - Tech Stack: Added react-query
# - Project Structure: Updated diagram
# Changes: 2 sections, 8 lines
```

**Time:** Automatic, ~10 seconds

---

## 📚 Next Steps

### Learn More

- **Architecture:** [ARCHITECTURE.md](ARCHITECTURE.md) - How components work together
- **Examples:** [../examples/](../examples/) - Real-world usage patterns
- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

### Customize Your CLAUDE.md

After generation, you can:

1. **Edit Core Principles** - Add team-specific guidelines
2. **Add Custom Sections** - Project-specific conventions
3. **Update Tech Stack** - Add missing dependencies
4. **Refine Workflows** - Adjust to your process

### Enable Automatic Maintenance

Set up the guardian agent to keep CLAUDE.md current:

```bash
# Agent runs automatically at session start
# Or invoke manually after major changes:
Claude, invoke claude-md-guardian to update CLAUDE.md
```

---

## 💡 Pro Tips

### Tip 1: Use Modular Architecture for Large Projects

If your CLAUDE.md exceeds 300 lines, split it:

```bash
/enhance-claude-md

# Tell Claude: "Use modular architecture"
# Result: Separate files for backend/, frontend/, database/
```

### Tip 2: Regenerate When Tech Stack Changes

```bash
# You: Added new major framework
npm install @nestjs/core

# You: Regenerate with new context
/enhance-claude-md

# Claude: Updates Tech Stack and patterns
```

### Tip 3: Validate Before Committing

```bash
# You: Made manual edits to CLAUDE.md
# You: Want to check quality

/enhance-claude-md

# Claude: Analyzes and shows quality score
# If score < 80, Claude suggests improvements
```

### Tip 4: Team Consistency

Install at user-level on all team machines:

```bash
# Each team member runs:
curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.sh | bash

# Choose option 1 (user-level)
# Result: Consistent CLAUDE.md standards across team
```

---

## 🎓 Understanding the Output

### What's in a Generated CLAUDE.md?

**Native Format Sections (Always Included):**
1. **Overview** - What this project does
2. **Project Structure** - ASCII tree diagram
3. **File Structure** - Directory explanations
4. **Setup & Installation** - Getting started steps
5. **Architecture** - Key design decisions (for complex projects)

**Team-Specific Sections:**
6. **Core Principles** - Development guidelines
7. **Tech Stack** - Technologies with versions
8. **Development Workflow** - How to contribute
9. **Testing Requirements** - Test standards
10. **Common Commands** - Build, test, lint scripts

**Optional Sections (Based on Project Type):**
- **Error Handling** - Error patterns
- **Performance Guidelines** - Optimization tips
- **Security Checklist** - Security requirements
- **Deployment Process** - How to deploy

---

## ⚡ Quick Reference

### Commands

| Command | Purpose |
|---------|---------|
| `/enhance-claude-md` | Initialize or enhance CLAUDE.md |
| `Claude, invoke claude-md-guardian` | Manually trigger maintenance |

### Quality Scores

| Score | Meaning | Action |
|-------|---------|--------|
| 0-40 | Poor | Major improvements needed |
| 41-70 | Fair | Add missing sections |
| 71-85 | Good | Minor improvements |
| 86-100 | Excellent | Maintain current quality |

### File Size Guidelines

| Team Size | Recommended Lines | Structure |
|-----------|-------------------|-----------|
| Solo | 50-100 | Single file |
| Small (2-9) | 100-200 | Single file |
| Medium (10-50) | 200-300 | Single or modular |
| Large (50+) | Modular | Multiple context files |

---

## 🆘 Having Issues?

### Issue: Command not recognized

**Solution:** Restart Claude Code after installation

### Issue: Quality score too low

**Solution:** Run `/enhance-claude-md` and let Claude add missing sections

### Issue: Generated file too generic

**Solution:** Provide more context:
```
/enhance-claude-md

"This is a Python FastAPI microservice project with PostgreSQL"
```

### More Help

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

---

## 🎉 Success!

You now have a fully functional CLAUDE.md file that:
- ✅ Follows native Claude Code format
- ✅ Includes project-specific context
- ✅ Provides clear development guidelines
- ✅ Automatically maintains itself (via guardian agent)

**Future Claude Code sessions will be significantly more productive!**

---

## 📖 Further Reading

- **Installation Guide:** [INSTALLATION.md](INSTALLATION.md)
- **Architecture Deep Dive:** [ARCHITECTURE.md](ARCHITECTURE.md)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **GitHub Repository:** https://github.com/alirezarezvani/ClaudeForge

---

**Ready to create amazing projects with ClaudeForge? Let's build! 🚀**
