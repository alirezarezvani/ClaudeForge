# Changelog

All notable changes to ClaudeForge will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added (wave 5 — CLAUDE.md → AGENTS.md conversion for Codex / Gemini)

Cross-tool adoption: every project using ClaudeForge can now share its instructions with non-Claude tools (OpenAI Codex, Gemini Code Assist, anything honouring the AGENTS.md convention) without maintaining two files.

- **`/claude-to-agents`** slash command (`command/claude-to-agents.md`) with three modes:
  - `--symlink` (default on macOS / Linux) — `AGENTS.md` becomes a symlink to `CLAUDE.md`. One source of truth; edits propagate instantly. Windows falls back to `--copy` automatically with a stderr notice.
  - `--copy` — byte-for-byte snapshot. Use when the user wants to fork the instructions or when their VCS/build pipeline doesn't follow symlinks.
  - `--inline-chain` — recursively walks every `@path/.../CLAUDE.md` import and writes a single flat AGENTS.md with all sub-file content inlined. **Recommended for Codex / Gemini in modular projects** because those tools don't auto-resolve `@`-imports.
- **`hooks/claude-to-agents.py`** — standalone, idempotent script. Backs up an existing `AGENTS.md` to `AGENTS.md.backup.<UTC-timestamp>` before overwrite (unless `--force`). Strips Claude-only scaffolding (backlink lines, `@`-import lines) from `--inline-chain` output. Cycle-safe (each file read at most once).
- Plugin manifest registers the new command. Both installers list it in their banner and uninstall instructions.

### Added (wave 4 — forked task-style audit skills)

Three new task-style skills under `skill/`, each using Anthropic's `context: fork` + `agent: Explore` so they run in an isolated subagent context (no caller chat history, ≤500-token summary back to the main session):

- **`claude-md-drift-audit`** (`skill/claude-md-drift-audit/SKILL.md`, 51 lines): walks the last N days of git history (default 7), cross-references every CLAUDE.md and `.claude/rules/*.md` against deleted paths / renamed paths / removed deps from that window, returns a punch list. Read-only.
- **`claude-md-link-check`** (`skill/claude-md-link-check/SKILL.md`, 51 lines): verifies every `@path` chain import and every relative markdown link inside every CLAUDE.md resolves to an existing file. Returns broken links with file:line refs. Read-only.
- **`claude-md-dependency-rescan`** (`skill/claude-md-dependency-rescan/SKILL.md`, 54 lines): re-detects the project's tech stack from `package.json` / `requirements.txt` / `pyproject.toml` / `go.mod` / `Cargo.toml`, diffs against every CLAUDE.md's Tech Stack section, returns added / removed / renamed lists per file. Read-only.

All three are standalone-invocable (`/claude-md-drift-audit`, etc.) and orchestrated by **`/sync-claude-md --weekly`**, which now opens with a Phase 0 that issues the three skills in parallel via the Skill tool before doing the normal sync work. Plugin manifest registers all five skills (the two existing + three new).

### Added (wave 3 — adoption hardening)

- **Command discovery metadata** (`command/enhance-claude-md.md`, `command/sync-claude-md.md`): both commands now declare `allowed-tools`, `disallowedTools` (blocks `WebFetch`/`WebSearch`), `argument-hint`, and `when_to_use` so Claude Code can auto-suggest and zero-prompt them.
- **Path-scoped Karpathy guidelines** (`skill/karpathy-guidelines/SKILL.md`): `paths:` glob on code-file extensions (`*.py`, `*.ts`, `*.go`, `*.rs`, etc.) so the guardrails load only when editing code, not when editing markdown or data.
- **Cheaper skill execution** (`skill/SKILL.md`): `model: haiku`, `effort: medium`, and `paths:` scoping the skill to CLAUDE.md / AGENTS.md / `.claude/rules/*.md` so validator + generator passes run cheaply without affecting the user-facing model.
- **`CLAUDE.local.md` personal tier**: `validator.BestPracticesValidator` now accepts `filename=` and waives the 150-line cap for any `*.local.md` file. `hooks/validate-claude-md.py` is exempt-suffix aware too. `.gitignore` excludes `CLAUDE.local.md`, `**/CLAUDE.local.md`, `.claude/settings.local.json`, and `hooks/hooks-config.local.json`.
- **Layered hook config** (`hooks/hooks-config.json` shared + `hooks/hooks-config.local.json` gitignored): `validate-claude-md.py` merges the two and honours `validateClaudeMd.enabled: false`, `maxLines`, `exemptFilenameSuffix`, and `exitCodeOnViolation`. Teams can opt out per developer without forking the shipped config.
- **`Stop` audit hook** (`hooks/audit-claude-md.py` + entry in `hooks/hooks.json`): prints a 1-line summary to stderr at session end — total CLAUDE.md tracked, count over the cap, count near it — so users see drift before the session's context is lost.
- **Fail-closed contract on guardian** (`agent/claude-md-guardian.md` Safety & Validation section): the guardian now states it invokes `claude-md-enhancer` exclusively through the Skill tool (never paraphrases SKILL.md content), aborts on missing validated output, never auto-commits, and respects the local hook config.

Patterns adapted (with attribution and in original prose) from the MIT-licensed [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice).

### Fixed

- **Guardian agent hook frontmatter** (`agent/claude-md-guardian.md`): rewritten from the array-of-objects shape (`hooks: [{ event, commands }]`) to Anthropic's canonical keyed-object shape (`hooks: { EventName: [{ matcher, hooks: [{ type: "command", command }] }] }`). The previous shape did not match the documented schema, so the guardian's hooks did not fire. ([docs](https://code.claude.com/docs/en/hooks))

### Added

- **Plugin-level hooks** (`hooks/hooks.json` + `hooks/validate-claude-md.py`): every `Edit`/`Write` to a `CLAUDE.md` and every `InstructionsLoaded` event (all five `load_reason` values — `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact`) runs `validate-claude-md.py`, which exits `2` with stderr feedback when the touched file exceeds the 150-line cap. Turns the cap from advisory into deterministic enforcement at load time and write time.
- **`generate_rules_file()` on `ContentGenerator`** (`skill/generator.py`): emits path-scoped `.claude/rules/*.md` instruction files with `name`, `description`, and `paths:` glob frontmatter. Claude loads these conditionally when accessing files that match the globs, so file-type-specific guidance (e.g. backend-only standards) no longer has to live in the root CLAUDE.md.
- **`AGENTS.md` / `.cursorrules` / `.windsurfrules` interop**: `command/enhance-claude-md.md` Phase 1 now detects these sibling instruction files, and `ContentGenerator.generate_root_file()` prepends an `## External Instructions` section with `@AGENTS.md`-style imports when `project_context['existing_instruction_files']` lists them. Repos already using other agent tooling can adopt ClaudeForge without losing their existing instructions.

### Added (earlier in this Unreleased window)

- **Claude Code plugin manifest** (`.claude-plugin/plugin.json`): ClaudeForge is now installable as a Claude Code plugin via `/plugin marketplace add alirezarezvani/ClaudeForge && /plugin install claudeforge`. Manifest registers all skills, commands, and the guardian agent in one bundle.
- **`/sync-claude-md` slash command** (`command/sync-claude-md.md`): walks every CLAUDE.md in the project, prunes stale references (removed dependencies, deleted paths, broken modular links), enforces the 150-line cap, and repairs the root ↔ sub chain. Designed to run after refactors, dependency changes, or before a release.
- **Karpathy Guidelines skill** (`skill/karpathy-guidelines/SKILL.md`): behavioural-guardrail skill applied to every coding, review, and refactoring task. Covers four principles — Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution — adapted with attribution from the MIT-licensed [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) repository.
- **Automatic embedding into every CLAUDE.md**: `skill/template_selector.py` and `skill/generator.py` insert a `## Behavioral Guidelines` section into every generated and enhanced CLAUDE.md.
- **Modular chaining via `@path` imports**: the modular root generator emits both human-readable markdown links and Claude Code `@path/to/CLAUDE.md` imports for every sub-CLAUDE.md. Sub-files now get a back-link header pointing to the root file so navigation is bidirectional.
- **Explore-agent delegation in `/enhance-claude-md`**: deep project scans are delegated to the Explore subagent to keep the calling session's context lean.

### Changed

- **Hard 150-line cap per CLAUDE.md**: `validator.MAX_RECOMMENDED_LINES` lowered from 300 to 150 (warning at 120). `template_selector.TEAM_SIZE_TEMPLATES` target lines lowered to fit (solo 75 / small 100 / medium 125 / large 150). `analyzer` length thresholds and quality scoring rebased on the new cap. Projects that need more content split it across chained sub-files instead of growing the root.
- **Installers register commands as top-level files**: `install.sh` and `install.ps1` now install each `.md` under `command/` as its own `~/.claude/commands/<name>.md` (registering as `/<name>`) rather than bundling the whole directory under one path. Legacy `~/.claude/commands/enhance-claude-md/` bundles are backed up automatically on upgrade.

### Verified

- Smoke tests: validator constants, all four team-size templates, generator output for solo/small/medium/large + library presets (all ≤ 150 lines), context files with back-links, `@`-import chain in modular root, idempotent `merge_with_existing`, validator status transitions (pass / warning / fail) at the new cap, analyzer quality score differential between compliant and bloated files, plugin manifest JSON shape and that every referenced path exists on disk.

---

## [2.0.0] - 2026-01-08

### 🎉 Major Update: Claude Code v2.1.4+ Support

ClaudeForge v2.0.0 modernizes the toolkit for Claude Code v2.1.4+ with hooks, modern permission syntax, and enhanced automation capabilities.

### Added

#### Claude Code v2.1.4+ Features
- **Lifecycle Hooks**: Guardian agent now uses SessionStart, PreToolUse, and PostToolUse hooks for automatic maintenance
  - SessionStart hook checks for CLAUDE.md updates on every new session
  - PreToolUse hook validates changes before writing
  - PostToolUse hook confirms successful updates
- **Modern Permission Syntax**: All components migrated to `permissions:` array format
  - Skill uses `permissions.allow:` array with wildcard support
  - Command uses `permissions.allow:` with tool-specific wildcards
  - Agent uses `permissions.allow:` with comprehensive tool access
- **Fork-Safe Mode**: Guardian agent configured with `fork_safe: true` for independent execution
- **Hot-Reload Support**: Skills automatically reload when modified (Claude Code 2.1.0+ feature)
- **Version Detection**: Installers now detect Claude Code version and validate compatibility
  - Warns if Claude Code < 2.1.0 (limited features)
  - Recommends Claude Code 2.1.4+ for full functionality
  - Exits if Claude Code < 2.0
- **Auto-Migration System**: Automatic migration from v1.x with timestamped backups
  - Detects v1.x installations using syntax analysis
  - Creates dated backups before upgrading
  - Validates v2.1.4 compatibility after installation

#### Documentation
- **Migration Guide**: Comprehensive `docs/MIGRATION_V2.md` with step-by-step instructions
  - Covers permission syntax changes
  - Documents hooks functionality
  - Provides troubleshooting guide
  - Includes rollback procedures
- **Testing Scripts**: Complete test suite in `test/` directory
  - `test/validate_migration.sh` - 18 automated validation tests
  - `test/rollback.sh` - One-command rollback to v1.x
  - `test/README.md` - Testing documentation and workflows
  - `test/LOCAL_TESTING_GUIDE.md` - Step-by-step local testing guide
- **Updated Documentation**: All docs now reference Claude Code v2.1.4+ features
  - `CLAUDE.md` - Updated with v2.0.0 features and permission syntax examples
  - `README.md` - Added "New in v2.0" section highlighting features

### Changed

- **Skill Frontmatter** (`skill/SKILL.md`):
  - ~~`tools:` field~~ → `permissions.allow:` array
  - Added wildcard Bash permissions: `Bash(ls:*)`, `Bash(find:*)`, `Bash(git:*)`

- **Command Frontmatter** (`command/enhance-claude-md.md`):
  - ~~`allowed-tools:` field~~ → `permissions.allow:` array
  - Added startup hook for workflow initiation

- **Agent Frontmatter** (`agent/claude-md-guardian.md`):
  - ~~`tools:` field~~ → `permissions.allow:` array
  - Added `fork_safe: true` for independent operation
  - Added SessionStart hook for auto-updates
  - Added PreToolUse/PostToolUse hooks for Write validation
  - Removed obsolete `mcp_tools: none` field

- **Installation Scripts**:
  - `install.sh`: Added Claude Code version detection and validation
  - `install.ps1`: Added Claude Code version detection and validation
  - Both scripts now include post-installation compatibility checks

- **Version Requirements**:
  - **Minimum**: Claude Code 2.1.0
  - **Recommended**: Claude Code 2.1.4+
  - **Previous**: Claude Code 2.0+

### Fixed
- **Installation Script:** Fixed bash syntax error in `install.sh` caused by missing quotes around color variables in `read -p` commands (#13, #19)
  - Added proper quoting around `${BLUE}` and `${NC}` variables in command substitution
  - Prevents "syntax error near unexpected token" during installation on macOS
  - Credit to @bartdorlandt for original fix

- **CI Workflow:** Removed strict branch naming requirement for PRs into dev (#17)
  - Contributors can now use any branch name when creating PRs
  - Reduces friction for external contributors and fork PRs
  - Maintains PR title validation (Conventional Commits) for commit hygiene

- **Compatibility**: All components now fully compatible with Claude Code v2.1.4+
  - Hooks work correctly with SessionStart events
  - Permission wildcards properly recognized
  - Hot-reload enabled for skill modifications

### Deprecated

- **Old Permission Syntax**: `tools:` and `allowed-tools:` fields deprecated in favor of `permissions:`
  - Still backward compatible for existing installations
  - Migration guide provides upgrade path

### Breaking Changes

- **Minimum Claude Code Version**: Now requires Claude Code 2.1.0+ (was 2.0+)
- **Frontmatter Syntax**: Old `tools:` and `allowed-tools:` syntax deprecated
- **Users on Claude Code < 2.1.0**: Should remain on ClaudeForge v1.0.0

### Migration

👉 **Upgrading from v1.0.0?** See [docs/MIGRATION_V2.md](docs/MIGRATION_V2.md) for detailed migration instructions.

**Quick Migration:**
```bash
# Backup first
cp -r ~/.claude/skills/claudeforge-skill ~/.claude/skills/claudeforge-skill.backup

# Run installer (auto-migrates)
./install.sh

# Restart Claude Code
exit
claude
```

### Notes

- **Python Modules**: All 5 Python modules (analyzer.py, validator.py, generator.py, template_selector.py, workflow.py) remain unchanged and backward compatible
- **Examples**: All 7 reference CLAUDE.md templates unchanged
- **Functionality**: Core analysis, generation, and validation features identical to v1.0.0

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
