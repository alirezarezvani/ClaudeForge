---
description: Initialize or enhance a CLAUDE.md (and chained sub-CLAUDE.md files) for the current project using the claude-md-enhancer skill. Delegates deep codebase scans to the Explore subagent and stays within the 150-line cap.
argument-hint: "[--init | --enhance | <path-to-CLAUDE.md>]"
when_to_use: |
  Use whenever a project has no CLAUDE.md, when an existing one is over 150 lines,
  when an /init result needs to be hardened against context bloat, or when a repo
  already uses AGENTS.md / .cursorrules / .windsurfrules and you want a Claude-
  aware root that chains to them via @-imports instead of overwriting.
allowed-tools:
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - Skill
  - "Bash(ls:*)"
  - "Bash(find:*)"
  - "Bash(git status:*)"
  - "Bash(git diff:*)"
  - "Bash(wc:*)"
disallowedTools:
  - WebFetch
  - WebSearch
permissions:
  allow:
    - "Bash(ls:*)"
    - "Bash(find:*)"
    - "Bash(git status:*)"
    - Read
    - Glob
    - Skill
---

# CLAUDE.md Enhancer Command

This command uses the `claude-md-enhancer` skill to initialize or enhance CLAUDE.md files for your project.

---

## Phase 1: Discovery - Check Current State

### Check if CLAUDE.md exists

!`ls -la CLAUDE.md 2>/dev/null || echo "CLAUDE.md not found"`

### Check for modular CLAUDE.md files

!`find . -name "CLAUDE.md" -type f -not -path "./node_modules/*" -not -path "./.git/*" | head -10`

### Get repository status

!`git status --short 2>/dev/null || echo "Not a git repository"`

### Check project structure

!`ls -la`

### Check for sibling agent / rule files

If `AGENTS.md`, `.cursorrules`, or `.windsurfrules` exists, ClaudeForge will preserve it and chain it from the root CLAUDE.md via `@AGENTS.md` (or the equivalent) instead of overwriting. Detect them now:

!`for f in AGENTS.md .cursorrules .windsurfrules; do [ -f "$f" ] && echo "found: $f ($(wc -l < "$f") lines)" || echo "absent: $f"; done`

### Deep project scan via Explore agent

For non-trivial repositories, delegate the codebase walk to the **Explore** subagent so the discovery does not bloat this command's context window. Ask it a single, scoped question — for example:

> Walk this repository and report: project type (web_app / api / fullstack / cli / library / mobile / desktop), languages and frameworks detected, primary tech stack files (package.json, requirements.txt, pyproject.toml, go.mod, Cargo.toml), team-size indicators (number of contributors, CODEOWNERS), workflow indicators (.github/workflows, Dockerfile, CI configs), and any subdirectories that warrant their own CLAUDE.md (backend/, frontend/, database/, docs/, .github/). Return findings as a compact JSON object. Under 250 words.

Use the **general-purpose** subagent only for research that requires synthesising findings across multiple agents (e.g. comparing detected stack against template registry). Keep agent prompts self-contained and ask for short, structured reports.

---

## Phase 2: Analysis - Determine Action

Based on the discovery above, I need to determine the appropriate action:

**If CLAUDE.md does NOT exist** → Interactive Initialization Workflow
**If CLAUDE.md exists** → Analysis and Enhancement Workflow

### For New Projects (No CLAUDE.md):

The `claude-md-enhancer` skill will:
1. Explore your repository structure
2. Detect project type, tech stack, team size, development phase
3. Show you the discoveries and ask for confirmation
4. Create customized CLAUDE.md file(s) after your approval
5. Apply 100% native format compliance (project structure diagrams, setup instructions, architecture sections)

### For Existing Projects (CLAUDE.md exists):

The `claude-md-enhancer` skill will:
1. Analyze current CLAUDE.md for quality and completeness
2. Calculate quality score (0-100)
3. Identify missing sections
4. Provide actionable recommendations
5. Offer to enhance with missing native format sections

---

## Phase 3: Task - Execute with Skill or Agent

### Option A: Direct Skill Invocation

I can invoke the `claude-md-enhancer` skill directly to handle the appropriate workflow based on what I discovered above.

The skill provides:
- ✨ **100% Native Format Compliance**: All generated files follow official Claude Code format with project structure diagrams, setup instructions, architecture sections, and file structure explanations
- 🆕 **Interactive Initialization**: For new projects, explores repository and asks for confirmation before creating files
- ✅ **Intelligent Analysis**: For existing projects, scans and evaluates for quality and completeness
- 🚀 **Smart Generation**: Creates customized CLAUDE.md files from scratch
- 🔧 **Enhancement**: Adds missing sections and improves existing files
- 📦 **Modular Architecture**: Supports context-specific files (backend/, frontend/, database/)

### Always-On: Karpathy Behavioral Guidelines

Every generated or enhanced CLAUDE.md MUST include a `## Behavioral Guidelines` section summarising the four Karpathy principles (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) with a link to the installed `karpathy-guidelines` skill.

The `claude-md-enhancer` skill inserts this section automatically — both in `template_selector.customize_template()` for new files and in `generator.merge_with_existing()` for enhanced files. Do not strip it during enhancement; if it is missing from an existing CLAUDE.md, treat that as a required addition.

The full skill is installed at `~/.claude/skills/karpathy-guidelines/SKILL.md` (or `./.claude/skills/karpathy-guidelines/SKILL.md` for project-level installs).

### Option B: Agent Invocation (Recommended for Maintenance)

For ongoing maintenance and automatic updates throughout your project lifecycle, I can invoke the `claude-md-guardian` agent instead:

**When to use the agent**:
- After feature completion
- After major refactoring
- When new dependencies are added
- After architecture changes
- For periodic CLAUDE.md synchronization

**Agent benefits**:
- 🔄 **Auto-Sync**: Updates CLAUDE.md based on detected changes
- 🎯 **Smart Detection**: Only updates when significant changes occur
- ⚡ **Token-Efficient**: Uses haiku model for routine updates
- 📦 **Milestone-Aware**: Triggers after completion signals
- ✨ **Native Format**: Ensures 100% Claude Code format compliance

### Your Task

I'm ready to proceed. What would you like me to do?

**For new projects**: I'll run the interactive initialization workflow (skill)
**For existing projects**: I'll analyze your current CLAUDE.md and suggest improvements (skill)
**For maintenance**: I'll invoke claude-md-guardian agent to check for updates and synchronize

Please confirm how you'd like to proceed, or let me know if you have specific requirements (e.g., "Create a CLAUDE.md for my Python FastAPI project" or "Invoke claude-md-guardian to update my CLAUDE.md").
