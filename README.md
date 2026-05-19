# ClaudeForge

> **Automated CLAUDE.md creation, enhancement, and maintenance for Claude Code projects**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/alirezarezvani/ClaudeForge/releases)
[![Claude Code](https://img.shields.io/badge/Claude_Code-2.1.4%2B-purple.svg)](https://claude.com/claude-code)
[![CI/CD](https://img.shields.io/badge/CI/CD-GitHub_Actions-2088FF.svg)](https://github.com/alirezarezvani/ClaudeForge/actions)
[![Quality Gates](https://img.shields.io/badge/Quality_Gates-Automated-success.svg)](docs/GITHUB_WORKFLOWS.md)

ClaudeForge is a comprehensive toolkit that eliminates the tedious process of manually creating and maintaining CLAUDE.md files. With intelligent analysis, automated generation, and background maintenance, your CLAUDE.md files stay perfectly synchronized with your codebase.

---

## 🆕 New in v2.0 (Claude Code v2.1.4+ Support)

- **Lifecycle Hooks**: Guardian agent automatically checks for updates at session start using SessionStart hooks
- **Modern Permissions**: All components now use `permissions:` syntax for fine-grained control
- **Hot-Reload**: Skills automatically reload when modified (no restart needed)
- **Fork-Safe Mode**: Guardian runs independently with `fork_safe: true` without blocking operations
- **Version Detection**: Installers validate Claude Code version and ensure compatibility
- **Auto-Migration**: Seamless upgrade from v1.x with automatic backups

👉 **Upgrading from v1.x?** See [docs/MIGRATION_V2.md](docs/MIGRATION_V2.md) for migration guide.

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

### 1. **Skill** (`claudeforge-skill`)
Core capability for CLAUDE.md analysis, generation, validation, and enhancement

### 2. **Slash Command** (`/enhance-claude-md`)
Interactive interface with multi-phase discovery workflow. Delegates deep codebase scans to the Explore subagent so the discovery does not bloat the calling session.

### 3. **Slash Command** (`/sync-claude-md`)
Walks every CLAUDE.md in the project, prunes stale references (removed dependencies, deleted files, dead modular links), enforces the **150-line hard cap per file**, and repairs the root ↔ subdirectory chain (markdown links + `@path` imports). Run after refactors, dependency changes, or before cutting a release.

### 4. **Guardian Agent** (`claude-md-guardian`)
Background agent for automatic CLAUDE.md maintenance and synchronization

### 5. **Karpathy Guidelines Skill** (`karpathy-guidelines`)
Behavioral guardrails — Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution — installed as a standalone skill and automatically embedded into every CLAUDE.md generated or enhanced by `/enhance-claude-md`. Adapted with attribution from the MIT-licensed [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) repository, inspired by Andrej Karpathy's observations on common LLM coding failure modes.

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

**Multi-Phase Workflow:**
1. **Discovery** - Checks for existing CLAUDE.md, examines project structure
2. **Analysis** - Determines appropriate action (initialize vs. enhance)
3. **Task** - Invokes skill or agent to execute workflow

### **Agent: claude-md-guardian**

**Background Maintenance:**
- **Auto-Sync** - Updates CLAUDE.md based on detected changes
- **Smart Detection** - Only updates when significant changes occur
- **Token-Efficient** - Uses haiku model for routine updates
- **Milestone-Aware** - Triggers after feature completion, refactoring, etc.

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

- Built for the [Claude Code](https://claude.com/claude-code) community
- Inspired by best practices from Anthropic's official documentation
- Special thanks to all contributors and early adopters

---

## 🚦 Project Status

**Version:** 1.0.0
**Status:** ✅ Stable & Production-Ready
**Last Updated:** November 12, 2025

---

## 📊 Quick Stats

- **7** reference CLAUDE.md templates included
- **100%** native Claude Code format compliance
- **5** Python modules
- **3** integrated components (skill, command, agent)
- **10+** usage examples and scenarios

---

## 🌟 Star History

If you find ClaudeForge helpful, please consider giving it a star on GitHub!

[![Star History Chart](https://api.star-history.com/svg?repos=alirezarezvani/ClaudeForge&type=Date)](https://star-history.com/#alirezarezvani/ClaudeForge&Date)

---

<div align="center">

**[⬆ Back to Top](#claudeforge)**

Made with ❤️ for the Claude Code community

</div>
