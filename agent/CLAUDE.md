> Parent context: see the root [CLAUDE.md](../CLAUDE.md) for project-wide guidelines and behavioural rules.
> Chained import: `@../CLAUDE.md`

# Guardian Agent Development

Guidelines for the `claude-md-guardian` background-maintenance agent.

## File

`agent/claude-md-guardian.md` — installs to `~/.claude/agents/claude-md-guardian.md`.

## Modifying the Agent

1. Edit `agent/claude-md-guardian.md`.
2. YAML frontmatter fields to preserve:
   - `permissions: [Bash, Read, Write, Edit, Grep, Glob, Skill]`
   - `model: haiku` — token efficiency for routine sync runs.
   - `color: purple` — visual indicator in Claude Code UI.
   - `fork_safe: true` — agent runs independently.
   - `hooks: [SessionStart, PreToolUse, PostToolUse]`.
3. Workflow phases inside the agent:
   - **Assessment** — read `git diff` / `git status` / changed-file counts.
   - **Analysis** — decide if changes are significant enough to update CLAUDE.md.
   - **Update** — invoke the skill for targeted section updates rather than full regeneration (~70–80% token saving vs. rewrite).
4. Re-install for testing: `cp agent/claude-md-guardian.md ~/.claude/agents/`.

## v2.0.0+ Frontmatter Reference

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

## Skill ↔ Agent Integration

The agent uses `claude-md-enhancer` (the skill's frontmatter name; installed as `claudeforge-skill/`) as its core capability. Invoke it with `Skill: claude-md-enhancer` inside the agent workflow.

Hook responsibilities:

- **SessionStart** — check `git diff`; if significant change is detected, invoke the skill for an incremental update.
- **PreToolUse** — validate before a CLAUDE.md edit lands.
- **PostToolUse** — after Edit/Write to any CLAUDE.md, run `BestPracticesValidator`, report the quality score, suggest improvements. Refuse to leave the file over 150 lines.

## Agent ↔ Git

The agent watches for change signals via:

```bash
git diff --name-status HEAD~10
git log --since="1 week ago" --oneline --no-merges
git diff HEAD~10 -- package.json requirements.txt pyproject.toml go.mod Cargo.toml
```

Triggers an update when any of these hold:

- 5+ files modified since the last sync.
- New dependencies added to a manifest file.
- New top-level directories created (potential new sub-CLAUDE.md candidates).
- Manual invocation after a milestone or release.

When the agent runs sync, it follows `command/sync-claude-md.md`: never commit, leave the diff for the user to review.
