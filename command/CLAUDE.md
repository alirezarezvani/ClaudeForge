> Parent context: see the root [CLAUDE.md](../CLAUDE.md) for project-wide guidelines and behavioural rules.
> Chained import: `@../CLAUDE.md`

# Slash Command Development

Guidelines for the `/enhance-claude-md` and `/sync-claude-md` slash commands.

## Files

- `command/enhance-claude-md.md` — interactive initialise / enhance workflow.
- `command/sync-claude-md.md` — walks every CLAUDE.md, prunes stale references, enforces the 150-line cap, repairs the root ↔ sub chain.

Both install as top-level `~/.claude/commands/<name>.md` so they register as `/enhance-claude-md` and `/sync-claude-md`. There is no `enhance-claude-md/` bundle directory anymore — legacy bundles are backed up automatically on upgrade.

## Modifying `/enhance-claude-md`

1. Edit `command/enhance-claude-md.md`.
2. Key phases:
   - **Phase 1 (Discovery)** — bash inventory + Explore-subagent delegation for deep codebase walks. Keep the calling session's context lean.
   - **Phase 2 (Analysis)** — branches initialise (no CLAUDE.md) vs. enhance (CLAUDE.md exists).
   - **Phase 3 (Task)** — invokes the `claude-md-enhancer` skill or `claude-md-guardian` agent.
3. Always-on requirement: every generated/enhanced CLAUDE.md must include `## Behavioral Guidelines`. The skill inserts it automatically — do not strip it.
4. Re-install for testing: `./install.sh` (project-level) or copy the file manually to `~/.claude/commands/enhance-claude-md.md`.
5. Restart Claude Code (commands hot-reload, but restart guarantees a clean state) and test.

## Modifying `/sync-claude-md`

1. Edit `command/sync-claude-md.md`.
2. Phases: inventory → per-file audit → enforce 150-line cap (split into sub-files via `generator.generate_context_file()`) → re-chain root ↔ subs → cleanup report.
3. Sync should never commit on its own; leave the diff staged-but-uncommitted for the user.

## Skill ↔ Slash Command Integration

`command/enhance-claude-md.md` Phase 3 invokes the skill by name:

> I can invoke the `claude-md-enhancer` skill directly to handle the appropriate workflow based on what I discovered above.

Claude Code resolves `claude-md-enhancer` from the YAML frontmatter `name:` field in `skill/SKILL.md` (kept for backwards compatibility — the installed directory is `claudeforge-skill/`).
