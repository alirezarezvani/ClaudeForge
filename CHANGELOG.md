# Changelog

All notable changes to ClaudeForge will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Fixed
- **Installation Script:** Fixed bash syntax error in `install.sh` caused by missing quotes around color variables in `read -p` commands (#13)
  - Added proper quoting around `${BLUE}` and `${NC}` variables in command substitution
  - Prevents "syntax error near unexpected token" during installation on macOS
  - Affects lines 132 and 179 in install.sh

---

## [1.0.0] - 2025-11-12

### 🎉 Initial Release

ClaudeForge v1.0.0 marks the first stable release of the automated CLAUDE.md management toolkit for Claude Code projects.

### Added

#### Core Features
- **Interactive Initialization Workflow** - Conversational workflow that explores repositories, detects project context, and creates customized CLAUDE.md files
- **100% Native Format Compliance** - All generated files follow official Claude Code format with project structure diagrams, setup instructions, and architecture sections
- **Intelligent Analysis** - Comprehensive file analysis with quality scoring (0-100) and actionable recommendations
- **Smart Enhancement** - Automatic addition of missing sections and structure improvements
- **Best Practice Validation** - Validation against Anthropic guidelines and community standards

#### Components
- **Skill:** `claudeforge-skill` v1.0.0
  - `analyzer.py` - File analysis and quality scoring (382 lines)
  - `validator.py` - Best practices validation (429 lines)
  - `generator.py` - Content generation (480 lines)
  - `template_selector.py` - Template selection logic (467 lines)
  - `workflow.py` - Interactive initialization workflow (432 lines)

- **Slash Command:** `/enhance-claude-md` v1.0.0
  - Multi-phase discovery workflow (Discovery → Analysis → Task)
  - Auto-detection of initialization vs. enhancement scenarios
  - Integration with skill and guardian agent

- **Guardian Agent:** `claude-md-guardian` v1.0.0
  - Background maintenance and auto-sync
  - Smart change detection (git-based)
  - Token-efficient updates using haiku model
  - Milestone-aware triggering

#### Templates
- **7 Reference CLAUDE.md Templates:**
  - `minimal-solo-CLAUDE.md` - Solo developer projects
  - `core-small-team-CLAUDE.md` - Small team projects (2-9 devs)
  - `python-api-CLAUDE.md` - Python API projects
  - `modular-root-CLAUDE.md` - Root navigation for modular setups
  - `modular-backend-CLAUDE.md` - Backend-specific guidelines
  - `modular-frontend-CLAUDE.md` - Frontend-specific guidelines
  - Reference examples covering TypeScript, Python, React, FastAPI, and more

#### Tech Stack Support
- **Frontend:** React, Vue, Angular, TypeScript, JavaScript
- **Backend:** Node.js, Python (Django, FastAPI, Flask), Go, Java (Spring Boot), Ruby (Rails)
- **Databases:** PostgreSQL, MongoDB, Redis, MySQL
- **Infrastructure:** Docker, Kubernetes, CI/CD systems

#### Team Size Adaptation
- **Solo** - Minimal guidelines (50-75 lines)
- **Small (<10)** - Core guidelines (100-150 lines)
- **Medium (10-50)** - Detailed guidelines (200-300 lines)
- **Large (50+)** - Comprehensive guidelines (modular architecture)

#### Installation
- **Automated Installers:**
  - `install.sh` - macOS/Linux bash installer
  - `install.ps1` - Windows PowerShell installer
- **Installation Options:**
  - User-level (`~/.claude/`) - Available in all projects
  - Project-level (`./.claude/`) - Current project only
- **One-line Installation:**
  ```bash
  curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.sh | bash
  ```

#### Documentation
- **Root Documentation:**
  - `README.md` - Comprehensive project overview with badges and quick start
  - `CHANGELOG.md` - Version history (this file)
  - `LICENSE` - MIT License

- **Detailed Guides:**
  - `docs/INSTALLATION.md` - Installation guide with troubleshooting
  - `docs/QUICK_START.md` - 5-minute tutorial
  - `docs/ARCHITECTURE.md` - Component architecture and data flow
  - `docs/TROUBLESHOOTING.md` - Common issues and solutions
  - `docs/CONTRIBUTING.md` - Contribution guidelines

- **Usage Examples:**
  - `examples/basic-usage.md` - Basic usage scenarios
  - `examples/modular-setup.md` - Modular architecture examples
  - `examples/integration-examples.md` - Integration patterns

#### GitHub Integration
- **CI/CD:**
  - `.github/workflows/validate.yml` - Automated validation workflow
  - Quality checks on pull requests

- **Community Templates:**
  - `.github/ISSUE_TEMPLATE/bug_report.md` - Bug report template
  - `.github/ISSUE_TEMPLATE/feature_request.md` - Feature request template
  - `.github/PULL_REQUEST_TEMPLATE.md` - Pull request template
  - `.github/CODE_OF_CONDUCT.md` - Code of conduct

#### Quality Hooks
- **Pre-commit Hook** - `hooks/pre-commit.sh`
  - Validates CLAUDE.md file quality before commits
  - Ensures best practices compliance
  - Optional installation during setup

### Quality Metrics

- **Quality Score Calculation (0-100):**
  - Length appropriateness: 25 points
  - Section completeness: 25 points
  - Formatting quality: 20 points
  - Content specificity: 15 points
  - Modular organization: 15 points

- **Validation Checks (5 categories):**
  - File length (20-300 lines recommended)
  - Structure (required sections present)
  - Formatting (markdown quality)
  - Completeness (essential content)
  - Anti-patterns (security, placeholders)

### Technical Details

- **Python Version:** 3.7+ compatible
- **Dependencies:** Standard library only (no external dependencies)
- **Total Code:** ~2,190 lines across 5 modules
- **Claude Code Compatibility:** 2.0+
- **Operating Systems:** macOS, Linux, Windows

### What's Next

See [Unreleased](#unreleased) section for planned features.

---

## [Unreleased]

### Planned for v1.1.0
- **Additional Templates:**
  - Rust/Cargo projects
  - Mobile (React Native, Flutter)
  - Desktop (Electron, Tauri)
  - Microservices architecture template

- **Enhanced Detection:**
  - Improved tech stack detection accuracy
  - Project phase detection from git history
  - Team size estimation from commit patterns

- **Quality Improvements:**
  - More granular quality scoring
  - Section-specific recommendations
  - Automated fix suggestions

### Planned for v1.2.0
- **VS Code Extension** (Future)
  - Inline CLAUDE.md editing
  - Real-time validation
  - Quick actions panel

- **GitHub Actions** (Enhanced)
  - Automated CLAUDE.md generation on repo creation
  - PR checks for CLAUDE.md quality
  - Auto-update on dependency changes

- **Advanced Hooks:**
  - Pre-push validation
  - Post-merge synchronization
  - Automated quality reports

### Under Consideration
- **Multi-language Support** - i18n for generated content
- **Custom Template Creation** - User-defined templates
- **AI-Powered Suggestions** - Context-aware recommendations
- **Integration with Other Tools** - Slack, Discord notifications
- **Web Dashboard** - Project-wide CLAUDE.md management
- **Analytics** - Usage patterns and effectiveness metrics

---

## Version History

| Version | Date | Status | Highlights |
|---------|------|--------|------------|
| 1.0.0 | 2025-11-12 | ✅ Stable | Initial release with full feature set |

---

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for details on how to contribute to ClaudeForge.

---

## Links

- **Repository:** https://github.com/alirezarezvani/ClaudeForge
- **Issues:** https://github.com/alirezarezvani/ClaudeForge/issues
- **Discussions:** https://github.com/alirezarezvani/ClaudeForge/discussions
- **Releases:** https://github.com/alirezarezvani/ClaudeForge/releases

---

**Made with ❤️ for the Claude Code community**
