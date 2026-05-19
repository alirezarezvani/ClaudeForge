# ClaudeForge

> **Automated CLAUDE.md creation, enhancement, and maintenance for Claude Code projects**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/alirezarezvani/ClaudeForge/releases)
[![Claude Code](https://img.shields.io/badge/Claude_Code-2.1.4%2B-purple.svg)](https://claude.com/claude-code)
[![CI/CD](https://img.shields.io/badge/CI/CD-GitHub_Actions-2088FF.svg)](https://github.com/alirezarezvani/ClaudeForge/actions)
[![Quality Gates](https://img.shields.io/badge/Quality_Gates-Automated-success.svg)](docs/GITHUB_WORKFLOWS.md)

ClaudeForge is a comprehensive toolkit that eliminates the tedious process of manually creating and maintaining CLAUDE.md files. With intelligent analysis, automated generation, and background maintenance, your CLAUDE.md files stay perfectly synchronized with your codebase.

---

## 🆕 What's New

- **Installable Claude Code plugin** — manifest at `.claude-plugin/plugin.json`; install with `/plugin marketplace add alirezarezvani/ClaudeForge && /plugin install claudeforge`
- **Hard 150-line cap per CLAUDE.md** — enforced deterministically by `hooks/hooks.json` on `PostToolUse(Edit|Write)` *and* `InstructionsLoaded` (every `load_reason`); larger projects spread content across chained sub-files via `@path` imports
- **`/sync-claude-md`** — walks every CLAUDE.md, prunes stale references, splits when over the cap, repairs root ↔ sub chains
- **`/sync-claude-md --weekly`** — orchestrates three forked task-style skills in parallel: `claude-md-drift-audit`, `claude-md-link-check`, `claude-md-dependency-rescan`
- **Karpathy behavioural guidelines** auto-embedded in every generated CLAUDE.md and installed as a standalone `~/.claude/skills/karpathy-guidelines/` skill scoped to code-file globs
- **`AGENTS.md` / `.cursorrules` / `.windsurfrules` interop** — `/enhance-claude-md` detects sibling instruction files and chains them via `@`-imports instead of overwriting
- **`CLAUDE.local.md` personal tier** — per-developer overrides exempt from the cap, gitignored automatically
- **Layered hook config** — `hooks/hooks-config.json` (committed defaults) + `hooks/hooks-config.local.json` (gitignored) lets developers opt out per machine
- **Lifecycle hooks**: `SessionStart`, `PreToolUse`, `PostToolUse`, `InstructionsLoaded`, `Stop` (one-line drift summary at session end)
- **Guardian agent** runs `model: haiku` with a fail-closed contract (Skill-tool only, never auto-commits, aborts on missing validated output)

👉 **Upgrading from v1.x?** See [docs/MIGRATION_V2.md](docs/MIGRATION_V2.md).

---

## ✨ Features

- 🚀 **Interactive Initialization** - Explores your repository, detects project context, and creates customized CLAUDE.md files through conversational workflow
- ✅ **Intelligent Analysis** - Scans and evaluates existing CLAUDE.md files with quality scoring (0-100) and actionable recommendations
- 🔧 **Smart Enhancement** - Adds missing sections and improves structure automatically
- 🛡️ **Background Maintenance** - Guardian agent keeps CLAUDE.md synchronized with codebase changes
- 📦 **Modular Architecture** - Supports complex projects with context-specific files (backend/, frontend/, database/)
- 🎯 **100% Native Format** - All generated files follow official Claude Code format with project structure diagrams, setup instructions, and architecture sections
- 🛠️ **Tech Stack Customization** - Tailors guidelines to TypeScript, Python, Go, React, Vue, FastAPI, and more
- 👥 **Team Size Adaptation** - Adjusts complexity based on team size (solo, small, medium, large)

---

## 📦 What's Included

### Skills

1. **`claudeforge-skill`** (`skill/SKILL.md`) — core analysis / validation / generation engine; runs on `model: haiku`. Scoped via `paths:` to `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md`, `.cursorrules`, `.windsurfrules`, and `.claude/rules/*.md` so it auto-loads only when those files are touched.
2. **`karpathy-guidelines`** (`skill/karpathy-guidelines/SKILL.md`) — Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution. Embedded into every generated CLAUDE.md and installed as a standalone skill `paths:`-scoped to ~23 source-file extensions. Adapted with attribution from the MIT-licensed [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills).
3. **`claude-md-drift-audit`** (`skill/claude-md-drift-audit/SKILL.md`, forked + `agent: Explore`) — walks the last N days of git history and flags every CLAUDE.md line that references deleted paths, renamed paths, or removed dependencies. Read-only. `/claude-md-drift-audit [days=7]`.
4. **`claude-md-link-check`** (`skill/claude-md-link-check/SKILL.md`, forked + `agent: Explore`) — verifies every `@path` chain import and every relative markdown link inside every CLAUDE.md resolves. Read-only. `/claude-md-link-check [path-glob]`.
5. **`claude-md-dependency-rescan`** (`skill/claude-md-dependency-rescan/SKILL.md`, forked + `agent: Explore`) — diffs declared dependencies (`package.json` / `requirements.txt` / `pyproject.toml` / `go.mod` / `Cargo.toml`) against the Tech Stack section of every CLAUDE.md. Read-only. `/claude-md-dependency-rescan [manifest]`.

### Slash commands

- **`/enhance-claude-md`** (`command/enhance-claude-md.md`) — multi-phase init/enhance workflow with `argument-hint`, `when_to_use`, `allowed-tools`, and `disallowedTools` (blocks `WebFetch` / `WebSearch`). Delegates deep codebase scans to the Explore subagent.
- **`/sync-claude-md`** (`command/sync-claude-md.md`) — inventory → prune stale refs → enforce the 150-line cap → repair root ↔ sub chain. **New `--weekly` flag** orchestrates the three audit skills in parallel before doing sync work.
- **`/claude-to-agents`** (`command/claude-to-agents.md`) — convert the project's CLAUDE.md tree into an `AGENTS.md` for Codex / Gemini Code Assist / any tool honouring the AGENTS.md convention. Three modes: `--symlink` (one source of truth, default on macOS/Linux), `--copy` (snapshot), `--inline-chain` (flattens the `@path` chain into one self-contained file — recommended for modular projects since Codex/Gemini don't auto-resolve `@` imports). Backs up an existing AGENTS.md before overwrite.

### Agent

- **`claude-md-guardian`** (`agent/claude-md-guardian.md`) — background maintenance. Runs `model: haiku` with a fail-closed contract: Skill-tool only, aborts on missing validated output, never auto-commits, respects the local hook config.

### Hooks

- **`hooks/hooks.json`** — wires `PostToolUse(Write|Edit)`, `InstructionsLoaded` (all five `load_reason` values), and `Stop` events to scripts under `hooks/`.
- **`hooks/validate-claude-md.py`** — enforces the 150-line cap deterministically at load time *and* write time; exempts `*.local.md`; exits with stderr feedback on violation.
- **`hooks/audit-claude-md.py`** — `Stop` hook; one-line CLAUDE.md health summary printed at session end (total tracked / over cap / near cap).
- **`hooks/hooks-config.json`** + **`hooks/hooks-config.local.json`** — layered config; per-developer overrides without forking the shipped manifest.

---

## 🚀 Quick Start

### Installation

#### **Claude Code Plugin (recommended)**

ClaudeForge ships as a Claude Code plugin. From any Claude Code session:

```text
/plugin marketplace add alirezarezvani/ClaudeForge
/plugin install claudeforge
```

This installs every component (skills, slash commands, guardian agent) and registers `/enhance-claude-md` and `/sync-claude-md` for any project. Works the same at the user level (available everywhere) or scoped to a single project.

#### **macOS / Linux**
```bash
curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.sh | bash
```

#### **Windows (PowerShell)**
```powershell
iwr https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.ps1 -useb | iex
```

#### **Manual Installation**
```bash
git clone https://github.com/alirezarezvani/ClaudeForge.git
cd ClaudeForge
./install.sh  # or .\install.ps1 on Windows
```

### Usage

After installation, restart Claude Code and run:

```bash
/enhance-claude-md
```

That's it! The command will:
1. ✅ Explore your project structure
2. ✅ Detect tech stack and project type
3. ✅ Show discoveries and ask for confirmation
4. ✅ Create customized CLAUDE.md file(s)
5. ✅ Apply best practices and native format

---

## 💡 Use Cases

### **New Project (No CLAUDE.md)**

```bash
/enhance-claude-md

# Claude explores your repository and responds:
#
# "Based on my exploration, here's what I discovered:
#
#  📦 Project Type: Full-Stack Application
#  🛠️ Tech Stack: TypeScript, React, Node.js, PostgreSQL, Docker
#  👥 Team Size: Small (5 developers)
#  🚀 Development Phase: MVP
#
#  📋 Recommended Structure:
#  - Root CLAUDE.md (navigation hub, ~100 lines)
#  - backend/CLAUDE.md (API guidelines, ~150 lines)
#  - frontend/CLAUDE.md (React guidelines, ~175 lines)
#
#  Would you like me to create these files?"
#
# You: "Yes"
#
# ✅ CLAUDE.md created (108 lines)
# ✅ backend/CLAUDE.md created (156 lines)
# ✅ frontend/CLAUDE.md created (182 lines)
```

### **Existing Project (Needs Improvement)**

```bash
/enhance-claude-md

# Claude analyzes your current CLAUDE.md:
#
# "Quality Score: 65/100
#
#  Missing Sections:
#  - Project Structure (ASCII diagram)
#  - Setup & Installation
#  - Architecture
#
#  Would you like me to enhance your CLAUDE.md with these sections?"
#
# You: "Yes"
#
# ✅ CLAUDE.md enhanced (+2 sections, quality score: 65 → 88)
```

### **Background Maintenance**

```bash
# You start a new Claude Code session
# Guardian agent automatically checks for changes
#
# ✅ CLAUDE.md updated:
# - Tech Stack: Added 2 dependencies (react-query, tailwindcss)
# - Project Structure: Updated diagram with new components/ directory
# - Setup & Installation: New environment variables
#
# Changes: 3 sections, 12 lines
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [Quick Start Guide](docs/QUICK_START.md) | 5-minute tutorial to get started |
| [Installation Guide](docs/INSTALLATION.md) | Detailed installation instructions and troubleshooting |
| [Architecture Overview](docs/ARCHITECTURE.md) | How components work together |
| [GitHub Workflows](docs/GITHUB_WORKFLOWS.md) | CI/CD automation and quality gates |
| [Branching Strategy](docs/BRANCHING_STRATEGY.md) | Branch flow and protection rules |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions |
| [Contributing Guide](docs/CONTRIBUTING.md) | How to contribute to ClaudeForge |

---

## 📖 Examples

See the [examples/](examples/) directory for:
- Basic usage scenarios
- Modular architecture setup
- Integration with existing projects
- Advanced customization

---

## 🔧 Components Deep Dive

### **Skill: claudeforge-skill**

**Core Capabilities:**
- **Analysis** - Scans existing CLAUDE.md files for quality and completeness
- **Validation** - Checks against Anthropic guidelines and best practices
- **Generation** - Creates new CLAUDE.md files from scratch
- **Enhancement** - Adds missing sections and improves structure
- **Template Selection** - Chooses appropriate templates based on project context

**Quality Scoring (0-100):**
- Length appropriateness (25 pts)
- Section completeness (25 pts)
- Formatting quality (20 pts)
- Content specificity (15 pts)
- Modular organization (15 pts)

### **Slash Command: /enhance-claude-md**

**Multi-phase workflow** (Discovery → Analysis → Task). Discovery delegates the deep codebase walk to the Explore subagent so it doesn't bloat the calling session. Phase 1 also detects sibling `AGENTS.md` / `.cursorrules` / `.windsurfrules` and chains them via `@`-imports rather than overwriting. Phase 3 invokes `claudeforge-skill` via the Skill tool.

### **Slash Command: /sync-claude-md (with `--weekly`)**

Default mode: inventory every CLAUDE.md, prune stale references, enforce the 150-line cap by splitting into sub-files, repair the root ↔ sub chain. With `--weekly`, **Phase 0** issues the three forked audit skills (`claude-md-drift-audit`, `claude-md-link-check`, `claude-md-dependency-rescan`) in parallel via the Skill tool, aggregates their findings under `## Weekly Audit Summary`, then proceeds. Each forked skill runs in an isolated subagent context (`context: fork`, `agent: Explore`) so audit work doesn't bloat the calling session.

### **Agent: claude-md-guardian**

Runs `model: haiku`, `fork_safe: true`. Hook frontmatter uses Anthropic's canonical keyed-object schema (events: `SessionStart`, `PreToolUse`, `PostToolUse`, `InstructionsLoaded`). **Fail-closed contract**: invokes `claudeforge-skill` exclusively through the Skill tool (never inlines SKILL.md), aborts on missing validated output, never auto-commits, respects `hooks/hooks-config.local.json`.

---

## 🎯 Requirements

- **Claude Code** 2.0 or later
- **Git** (recommended for change detection)
- **Operating Systems:** macOS, Linux, Windows (PowerShell)

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](docs/CONTRIBUTING.md) for details.

### Quick Contribution Steps:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 🐛 Issues & Support

- **Bug Reports:** [GitHub Issues](https://github.com/alirezarezvani/ClaudeForge/issues)
- **Feature Requests:** [GitHub Discussions](https://github.com/alirezarezvani/ClaudeForge/discussions)
- **Documentation:** [docs/](docs/)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Copyright © 2025 Alireza Rezvani**

---

## 🙏 Acknowledgments

- Built for the [Claude Code](https://claude.com/claude-code) community.
- The behavioural-guardrail skill adapts the four principles from the MIT-licensed [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (inspired by Andrej Karpathy's commentary on LLM coding pitfalls). Original prose; attribution preserved in `skill/karpathy-guidelines/SKILL.md`.
- Several plugin conventions (layered hook config, `Stop` audit hook, command discovery metadata, `paths:` scoping on skills, fail-closed contracts) are adapted from the MIT-licensed [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice). Patterns implemented in original code with attribution in `CHANGELOG.md`.
- Anthropic's [Claude Code documentation](https://code.claude.com/docs/en/memory) drove the load-event integrations (`InstructionsLoaded`, all five `load_reason` matchers) and the `context: fork` task-style skills.

---

## 🚦 Project Status

**Version:** 2.1.0 (see [CHANGELOG.md](CHANGELOG.md))
**Status:** ✅ Stable & Production-Ready
**Requires:** Claude Code 2.1.4+ for hooks/`InstructionsLoaded`/`paths:` features

---

## 📊 Quick Stats

- **5** skills (`claudeforge-skill`, `karpathy-guidelines`, plus three forked audit skills)
- **3** slash commands (`/enhance-claude-md`, `/sync-claude-md` with `--weekly`, `/claude-to-agents`)
- **1** agent (`claude-md-guardian`, fail-closed contract)
- **3** hook scripts wired across `PostToolUse`, `InstructionsLoaded`, `Stop`
- **5** Python modules under `skill/` (analyzer, validator, generator, template_selector, workflow)
- **7** reference CLAUDE.md templates under `skill/examples/`
- **150** — hard line cap per CLAUDE.md, enforced at load time *and* write time

---

## 🌟 Star History

If you find ClaudeForge helpful, please consider giving it a star on GitHub!

[![Star History Chart](https://api.star-history.com/svg?repos=alirezarezvani/ClaudeForge&type=Date)](https://star-history.com/#alirezarezvani/ClaudeForge&Date)

---

<div align="center">

**[⬆ Back to Top](#claudeforge)**

Made with ❤️ for the Claude Code community

</div>
