# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**ClaudeForge** is a comprehensive toolkit for automated CLAUDE.md creation, enhancement, and maintenance for Claude Code projects. The repository consists of three integrated components:

1. **Skill** (`claudeforge-skill`) - Core Python modules for analysis, generation, and validation
2. **Slash Command** (`/enhance-claude-md`) - Interactive multi-phase discovery workflow
3. **Guardian Agent** (`claude-md-guardian`) - Background maintenance agent

---

## What's New in v2.0.0

**Claude Code v2.1.4+ Support:**
- **Lifecycle Hooks**: Guardian agent uses SessionStart, PreToolUse, PostToolUse hooks
- **Modern Permissions**: Updated to `permissions:` array syntax
- **Hot-Reload**: Skills auto-reload when modified (no restart needed)
- **Fork-Safe Mode**: Guardian runs independently with `fork_safe: true`
- **Auto-Migration**: Seamless upgrade from v1.x with automatic backups

**Migration:** See `docs/MIGRATION_V2.md` for upgrading from v1.0.0.

---

## Architecture

### Component Interaction Flow

```
User Project
    ↓
/enhance-claude-md (Slash Command)
    ↓
[Phase 1: Discovery] → [Phase 2: Analysis] → [Phase 3: Task]
    ↓
claude-md-guardian (Agent) OR Direct Skill Invocation
    ↓
claudeforge-skill (Python Modules)
    ↓
workflow.py → analyzer.py → validator.py → template_selector.py → generator.py
    ↓
CLAUDE.md Created/Updated with 100% Native Format
```

### Python Module Architecture

The skill consists of 5 core modules (~2,190 lines):

**workflow.py (432 lines)** - `InitializationWorkflow` class
- Orchestrates interactive initialization for new projects
- Methods: `check_claude_md_exists()`, `generate_exploration_prompt()`, `analyze_discoveries()`
- Detects: project type, tech stack, team size, development phase, workflows
- Returns: Project context dictionary for template selection

**analyzer.py (382 lines)** - `CLAUDEMDAnalyzer` class
- Analyzes existing CLAUDE.md files
- Methods: `analyze_file()`, `detect_sections()`, `calculate_quality_score()`, `generate_recommendations()`
- Quality scoring: 0-100 based on length (25pts), completeness (25pts), formatting (20pts), specificity (15pts), modularity (15pts)
- Returns: Analysis report with quality score and actionable recommendations

**validator.py (429 lines)** - `BestPracticesValidator` class
- Validates against Anthropic guidelines
- Methods: `validate_length()`, `validate_structure()`, `validate_formatting()`, `validate_completeness()`, `validate_all()`
- Checks: file length (20-300 lines), required sections, markdown formatting, anti-patterns
- Returns: Validation report with pass/fail status and detailed issues

**template_selector.py (467 lines)** - `TemplateSelector` class
- Selects appropriate template based on context
- Methods: `select_template()`, `customize_template()`, `recommend_modular_structure()`
- Logic: Maps project type + team size → template complexity
- Returns: Template configuration with target line count and modular recommendation

**generator.py (480 lines)** - `ContentGenerator` class
- Generates new or enhanced CLAUDE.md content
- Methods: `generate_root_file()`, `generate_context_file()`, `generate_section()`, `merge_with_existing()`
- Supports: Root files, context-specific files (backend/, frontend/, database/), individual sections
- Returns: Complete CLAUDE.md content with 100% native format compliance

### Critical Validation Rule

All generated CLAUDE.md files MUST include:
- Project structure (ASCII tree diagram)
- File structure explanations
- Setup & installation instructions
- Architecture section (for complex projects)
- Validation against `/update-claude-md` slash command format
- Cross-check against reference examples in `skill/examples/`

---

## Installation & Testing

### Test Installation Scripts

```bash
# macOS/Linux
./install.sh
# Choose option 1 (user-level) or 2 (project-level)
# Verify installation at ~/.claude/ or ./.claude/

# Windows
.\install.ps1
# Same options as above

# Verify components installed:
ls -la ~/.claude/skills/claudeforge-skill/
ls -la ~/.claude/commands/enhance-claude-md/
ls -la ~/.claude/agents/claude-md-guardian.md
```

### Directory Structure After Installation

```
~/.claude/                           # User-level installation
├── skills/
│   └── claudeforge-skill/          # Copied from skill/
│       ├── SKILL.md
│       ├── analyzer.py
│       ├── validator.py
│       ├── generator.py
│       ├── template_selector.py
│       ├── workflow.py
│       └── examples/               # 7 reference templates
├── commands/
│   └── enhance-claude-md/          # Copied from command/
│       └── enhance-claude-md.md
└── agents/
    └── claude-md-guardian.md       # Copied from agent/
```

---

## Development Workflow

### Modifying Python Modules

When updating skill modules (analyzer.py, generator.py, etc.):

1. Edit files in `skill/` directory
2. Test changes by reinstalling: `./install.sh` (choose option 2 for project-level testing)
3. Test skill invocation in Claude Code: `/enhance-claude-md`
4. Validate output against reference examples in `skill/examples/`
5. Update `CHANGELOG.md` with changes

### Modifying Slash Command

When updating `/enhance-claude-md` command:

1. Edit `command/enhance-claude-md.md`
2. Key sections to modify:
   - **Phase 1 (Discovery)**: Bash commands that check project state
   - **Phase 2 (Analysis)**: Logic that determines initialize vs. enhance
   - **Phase 3 (Task)**: Skill/agent invocation logic
3. Test by reinstalling command: `cp command/enhance-claude-md.md ~/.claude/commands/enhance-claude-md/`
4. Restart Claude Code and test: `/enhance-claude-md`

### Modifying Guardian Agent

When updating `claude-md-guardian` agent:

1. Edit `agent/claude-md-guardian.md`
2. Key YAML frontmatter fields:
   - `permissions`: [Bash, Read, Write, Edit, Grep, Glob, Skill]
   - `model`: Set to `haiku` for token efficiency
   - `color`: Visual indicator (purple)
   - `fork_safe`: Set to `true` for independent execution
   - `hooks`: Array of lifecycle hooks (SessionStart, PreToolUse, PostToolUse)
3. Agent workflow phases:
   - Phase 1: Assessment (check git changes)
   - Phase 2: Analysis (determine scope)
   - Phase 3: Update (invoke skill for targeted updates)
4. Test: `cp agent/claude-md-guardian.md ~/.claude/agents/`

**Example Agent Definition with v2.0.0 Syntax:**
```yaml
---
name: claude-md-guardian
permissions: [Bash, Read, Write, Edit, Grep, Glob, Skill]
model: haiku
color: purple
fork_safe: true
hooks:
  - SessionStart
  - PreToolUse
  - PostToolUse
---
```

### Adding New Templates

To add a new reference template (e.g., Rust, mobile):

1. Create new template file in `skill/examples/`
2. Follow native format structure:
   - Project structure diagram (ASCII tree)
   - Setup & installation
   - Architecture section
   - Tech-specific guidelines
3. Update `skill/examples/README.md` with new template description
4. Update `template_selector.py` logic to detect when to use new template
5. Add test case in `skill/sample_input.json`

---

## Testing & Validation

### Manual Testing Checklist

**Test New Project Initialization:**
```bash
# 1. Create test project
mkdir test-project && cd test-project
git init
npm init -y  # or create package.json

# 2. Run slash command
/enhance-claude-md

# 3. Verify Claude:
#    - Explores repository
#    - Detects TypeScript/Node project
#    - Shows discoveries
#    - Asks for confirmation
#    - Creates CLAUDE.md with native format
```

**Test Existing Project Enhancement:**
```bash
# 1. Create basic CLAUDE.md
echo "# CLAUDE.md\n\n## Tech Stack\n- TypeScript" > CLAUDE.md

# 2. Run slash command
/enhance-claude-md

# 3. Verify Claude:
#    - Analyzes existing file
#    - Calculates quality score (0-100)
#    - Identifies missing sections (Project Structure, Setup, etc.)
#    - Asks to enhance
#    - Adds missing native format sections
```

**Test Guardian Agent:**
```bash
# 1. Make significant changes
npm install react  # Add new dependency
mkdir src/components  # New directory

# 2. Start new Claude Code session (triggers SessionStart)

# 3. Verify agent:
#    - Detects changes via git diff
#    - Updates CLAUDE.md automatically
#    - Reports: "Tech Stack: Added react", "Project Structure: Updated diagram"
```

### Quality Validation

All generated CLAUDE.md files should pass these checks:

```python
# Use validator.py
validator = BestPracticesValidator(content)
results = validator.validate_all()

# Expected passes:
# - File length: 20-300 lines (or modular if >300)
# - Structure: Required sections present
# - Formatting: Valid markdown, proper heading hierarchy
# - Completeness: Code examples, tech stack, workflows
# - Anti-patterns: No hardcoded secrets, no TODOs/placeholders
```

---

## File Organization

### Repository Structure

```
ClaudeForge/
├── skill/                          # Python modules (core capability)
│   ├── analyzer.py                 # File analysis
│   ├── validator.py                # Best practices validation
│   ├── generator.py                # Content generation
│   ├── template_selector.py        # Template selection logic
│   ├── workflow.py                 # Interactive initialization
│   ├── SKILL.md                    # Skill definition (YAML frontmatter)
│   ├── sample_input.json           # Test scenarios (6 examples)
│   ├── expected_output.json        # Expected outputs
│   └── examples/                   # 7 reference templates
│
├── command/                        # Slash command definition
│   ├── enhance-claude-md.md        # Multi-phase workflow
│   └── README.md
│
├── agent/                          # Guardian agent definition
│   ├── claude-md-guardian.md       # Background maintenance agent
│   └── README.md
│
├── docs/                           # Documentation
│   ├── INSTALLATION.md
│   ├── QUICK_START.md
│   ├── ARCHITECTURE.md
│   ├── TROUBLESHOOTING.md
│   └── CONTRIBUTING.md
│
├── examples/                       # Usage examples (markdown)
├── hooks/                          # Quality hooks (pre-commit)
├── .github/                        # GitHub templates & workflows
│   ├── workflows/validate.yml      # CI/CD validation
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODE_OF_CONDUCT.md
│
├── install.sh                      # macOS/Linux installer
├── install.ps1                     # Windows installer
├── README.md                       # Project overview
├── CHANGELOG.md                    # Version history
├── LICENSE                         # MIT License
└── CLAUDE.md                       # This file
```

### Important: Dual Directory Structure

Note the duplication: `claude-md-enhancer/` (legacy) and `skill/` (current). When making changes:
- **Always edit `skill/`** - This is the active version used by installers
- `claude-md-enhancer/` is kept for reference but not actively maintained

---

## Common Operations

### Update Reference Templates

```bash
# Edit template
vim skill/examples/python-api-CLAUDE.md

# Test template selection
# 1. Create test project matching template criteria
mkdir test-python-api && cd test-python-api
echo "fastapi" > requirements.txt

# 2. Run slash command and verify template is used
/enhance-claude-md
```

### Update Quality Scoring Logic

```bash
# Edit analyzer.py
vim skill/analyzer.py

# Update calculate_quality_score() method
# Current scoring breakdown:
#   - length_appropriateness: 25 points (20-300 lines ideal)
#   - section_completeness: 25 points (required sections present)
#   - formatting_quality: 20 points (markdown, headings, code blocks)
#   - content_specificity: 15 points (project-specific, not generic)
#   - modular_organization: 15 points (context files if needed)

# Test scoring
python3 -c "
from skill.analyzer import CLAUDEMDAnalyzer
with open('test-CLAUDE.md') as f:
    analyzer = CLAUDEMDAnalyzer(f.read())
    report = analyzer.analyze_file()
    print(f'Quality Score: {report[\"quality_score\"]}/100')
"
```

### Update Installer Scripts

```bash
# Edit installer
vim install.sh  # or install.ps1

# Key sections:
# - Installation paths (user-level vs project-level)
# - Component copying (skill, command, agent)
# - Backup logic (existing installations)
# - Quality hooks installation (optional)

# Test installer
./install.sh
# Choose test option and verify all components copied correctly
```

---

## Integration Points

### Skill ↔ Slash Command

The slash command invokes the skill via:
```markdown
# In command/enhance-claude-md.md, Phase 3:

I can invoke the `claude-md-enhancer` skill directly to handle the appropriate workflow based on what I discovered above.
```

Claude Code recognizes the skill name `claude-md-enhancer` and calls Python modules.

### Skill ↔ Guardian Agent

The agent uses the skill as its core capability:
```yaml
# In agent/claude-md-guardian.md:
permissions: [Bash, Read, Write, Edit, Grep, Glob, Skill]
hooks:
  - SessionStart  # Detects project changes on session start
  - PreToolUse    # Validates before tool execution
  - PostToolUse   # Validates after CLAUDE.md updates
```

Agent invokes skill with: `Skill: claude-md-enhancer` in agent workflow.

**Example Hook Usage:**
```markdown
# When SessionStart hook triggers:
1. Check git diff for changes
2. If significant changes detected → invoke skill
3. Update CLAUDE.md automatically

# When PostToolUse hook triggers after Edit/Write to CLAUDE.md:
1. Validate updated content with validator.py
2. Report quality score
3. Suggest improvements if needed
```

### Agent ↔ Git

Agent detects changes via git commands:
```bash
git diff --name-status HEAD~10
git log --since="1 week ago" --oneline --no-merges
git diff HEAD~10 -- package.json requirements.txt
```

Triggers update when:
- 5+ files modified
- New dependencies added
- New directories created
- Manual invocation after milestone

---

## Tech Stack Detection Logic

The workflow and template selector detect tech stacks via:

**Frontend Detection:**
- React: `package.json` contains `"react"`
- Vue: `package.json` contains `"vue"`
- Angular: `angular.json` exists
- TypeScript: `tsconfig.json` exists

**Backend Detection:**
- Node.js: `package.json` exists
- Python: `requirements.txt`, `pyproject.toml`, `setup.py`
- Go: `go.mod` exists
- Java: `pom.xml`, `build.gradle`
- Rust: `Cargo.toml` exists

**Database Detection:**
- PostgreSQL: `package.json` or `requirements.txt` contains "pg" or "psycopg2"
- MongoDB: Contains "mongoose" or "pymongo"
- Redis: Contains "redis" or "ioredis"

Update detection logic in: `skill/workflow.py` → `_detect_tech_stack()` method

---

## Repository Naming

**Project Name:** ClaudeForge
**GitHub URL:** https://github.com/alirezarezvani/ClaudeForge
**Skill Name:** `claudeforge-skill` (installed as directory name)
**Slash Command:** `/enhance-claude-md` (fixed name, cannot be changed by user)
**Agent Name:** `claude-md-guardian` (file name)

When updating references:
- `skill/SKILL.md` → YAML frontmatter `name: claude-md-enhancer` (kept for compatibility)
- `README.md` → Use "ClaudeForge" as display name
- `install.sh` → Copies to `claudeforge-skill/` directory
- Internal documentation → Use "ClaudeForge" consistently

---

## Version Management

**Current Version:** 2.0.0 (see CHANGELOG.md)
**Versioning:** Semantic Versioning (MAJOR.MINOR.PATCH)

When releasing new version:
1. Update `CHANGELOG.md` with changes under new version header
2. Update version in `README.md` badge
3. Update version in `skill/SKILL.md` bottom section
4. Create git tag: `git tag -a v2.1.0 -m "Release v2.1.0"`
5. Push tag: `git push origin v2.1.0`
6. Create GitHub release with CHANGELOG excerpt

---

## License & Copyright

**License:** MIT License
**Copyright:** © 2025 Alireza Rezvani

All files should include appropriate copyright headers. The LICENSE file is authoritative.
