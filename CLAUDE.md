# CLAUDE.md

Top-level guidance for Claude Code when working on this repository.

## Project Overview

**ClaudeForge** is a Claude Code plugin (manifest at `.claude-plugin/plugin.json`) and standalone toolkit for the CLAUDE.md lifecycle: initialise, enhance, sync, and modularise files with a hard **150-line cap**, automatic chaining via `@path` imports, and Karpathy behavioural guardrails. Works in any Claude Code or Claude.cowork project.

Five components ship in this repo:

1. **Skill** (`claudeforge-skill`, in `skill/`) — Python modules for analysis, generation, validation. Enforces the 150-line cap.
2. **Slash command** (`/enhance-claude-md`, in `command/`) — interactive init/enhance workflow. Delegates deep codebase scans to the Explore subagent.
3. **Slash command** (`/sync-claude-md`, in `command/`) — walks every CLAUDE.md, prunes stale references, enforces the 150-line cap, repairs the root ↔ sub chain.
4. **Guardian agent** (`claude-md-guardian`, in `agent/`) — background sync triggered by `SessionStart` / `PreToolUse` / `PostToolUse` hooks.
5. **Karpathy guidelines skill** (`karpathy-guidelines`, in `skill/karpathy-guidelines/`) — behavioural guardrails embedded into every generated CLAUDE.md. Adapted with attribution from the MIT-licensed [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) repo.

Current version: **2.1.0** — see `CHANGELOG.md`. v1 → v2 upgrade: `docs/MIGRATION_V2.md`.

## Quick Navigation

- [Skill development](skill/CLAUDE.md)
- [Slash command development](command/CLAUDE.md)
- [Guardian agent development](agent/CLAUDE.md)
- [Installation, testing & release](docs/CLAUDE.md)

Chained context (Claude Code auto-imports these):

@skill/CLAUDE.md
@command/CLAUDE.md
@agent/CLAUDE.md
@docs/CLAUDE.md

## Behavioral Guidelines

Behavioural guardrails applied to every coding, review, and refactoring task in this repo. Full skill: `~/.claude/skills/karpathy-guidelines/SKILL.md`.

1. **Think before coding.** State load-bearing assumptions; if a request has multiple reasonable interpretations, surface them instead of picking silently. Stop and ask when something is genuinely unclear.
2. **Simplicity first.** Write the minimum code that solves the stated problem. No speculative abstractions, no unrequested configuration, no error handling for conditions that cannot occur.
3. **Surgical changes.** Touch only what the task requires. Match surrounding style. Every changed line should trace directly to the user's request.
4. **Goal-driven execution.** Convert vague requests into verifiable success criteria before coding (failing test first), and state a step-by-step plan with per-step verification for multi-step work.

## Repository Layout (top level)

```
ClaudeForge/
├── .claude-plugin/plugin.json    # plugin manifest
├── skill/                        # core Python modules + karpathy-guidelines/
├── command/                      # /enhance-claude-md, /sync-claude-md
├── agent/                        # claude-md-guardian
├── docs/                         # operational docs (installation, testing, release)
├── examples/                     # usage examples
├── hooks/                        # quality hooks (pre-commit)
├── .github/                      # CI workflows, issue/PR templates
├── install.sh / install.ps1      # installers
├── README.md / CHANGELOG.md / LICENSE
└── CLAUDE.md                     # this file
```

## Naming Reference

- **Project / display name:** ClaudeForge
- **GitHub:** https://github.com/alirezarezvani/ClaudeForge
- **Skill name (frontmatter):** `claude-md-enhancer` (kept for backwards compatibility); installed as `claudeforge-skill/`
- **Slash commands:** `/enhance-claude-md`, `/sync-claude-md` (names fixed by file name)
- **Agent:** `claude-md-guardian`
- **Standalone skill:** `karpathy-guidelines`

## License

MIT — © 2025 Alireza Rezvani. See `LICENSE`.
