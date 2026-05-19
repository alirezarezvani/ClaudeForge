> Parent context: see the root [CLAUDE.md](../CLAUDE.md) for project-wide guidelines and behavioural rules.
> Chained import: `@../CLAUDE.md`

# Installation, Testing & Release

Operational guidance for installers, smoke tests, and release management.

## Test Installation Scripts

```bash
# macOS/Linux
./install.sh
# Choose option 1 (user-level) or 2 (project-level)

# Windows
.\install.ps1
# Same options as above

# Verify after install:
ls -la ~/.claude/skills/claudeforge-skill/
ls -la ~/.claude/skills/karpathy-guidelines/
ls -la ~/.claude/skills/claude-md-drift-audit/
ls -la ~/.claude/skills/claude-md-link-check/
ls -la ~/.claude/skills/claude-md-dependency-rescan/
ls -la ~/.claude/commands/enhance-claude-md.md
ls -la ~/.claude/commands/sync-claude-md.md
ls -la ~/.claude/agents/claude-md-guardian.md
```

## Directory Layout After Install

```
~/.claude/                                  # user-level (project-level mirrors under ./.claude)
├── skills/
│   ├── claudeforge-skill/                  # from skill/
│   │   ├── SKILL.md
│   │   ├── analyzer.py
│   │   ├── validator.py
│   │   ├── generator.py
│   │   ├── template_selector.py
│   │   ├── workflow.py
│   │   └── examples/
│   └── karpathy-guidelines/                # from skill/karpathy-guidelines/
│       └── SKILL.md
├── commands/
│   ├── enhance-claude-md.md
│   └── sync-claude-md.md
└── agents/
    └── claude-md-guardian.md
```

## Smoke Test (run from repo root)

```bash
python3 - <<'PY'
import sys; sys.path.insert(0, 'skill')
from validator import BestPracticesValidator
from template_selector import TemplateSelector
from generator import ContentGenerator

assert BestPracticesValidator.MAX_RECOMMENDED_LINES == 150
for cfg in TemplateSelector.TEAM_SIZE_TEMPLATES.values():
    assert cfg['target_lines'] <= 150

ctx = {'type':'fullstack','tech_stack':['typescript','python'],
       'team_size':'medium','phase':'production','workflows':['cicd']}
out = ContentGenerator(ctx).generate_root_file()
assert len(out.splitlines()) <= 150
assert '## Behavioral Guidelines' in out
print('smoke ok')
PY
```

Run after any change to `skill/`, `command/`, or `agent/`.

## Manual End-to-End Tests

**Fresh project init:**
1. `mkdir test-project && cd test-project && git init && npm init -y`
2. Run `/enhance-claude-md`.
3. Confirm generated CLAUDE.md ≤ 150 lines, contains `## Behavioral Guidelines`, has tech detection right.

**Existing project enhance:**
1. Seed `CLAUDE.md` with one short section.
2. Run `/enhance-claude-md`; confirm quality score reported, missing sections proposed, `## Behavioral Guidelines` appended if absent.

**Guardian agent sync:**
1. Add a new dependency and create a new directory.
2. Open a new Claude Code session — `SessionStart` fires.
3. Confirm the agent updates Tech Stack / Project Structure and quality re-validates.

**Sync command:**
1. In a repo with stale CLAUDE.md references, run `/sync-claude-md`.
2. Confirm stale lines flagged, 150-cap enforced via split, root ↔ sub chain repaired, diff left staged for the user.

## Common Operations

**Update a reference template:** edit `skill/examples/<name>-CLAUDE.md`, then add a matching scenario to `skill/sample_input.json`.

**Update quality scoring:** edit `skill/analyzer.py` → `calculate_quality_score()`. Re-run the smoke test.

**Update installer:** edit `install.sh` / `install.ps1` (paths, copy logic, backup logic, hooks). Test both user-level and project-level on a throwaway directory.

## Release Process

1. Update `CHANGELOG.md` under a new version header.
2. Bump the version in `README.md`, `skill/SKILL.md`, and `.claude-plugin/plugin.json`.
3. `git tag -a vX.Y.Z -m "Release vX.Y.Z"`.
4. `git push origin vX.Y.Z`.
5. Create the GitHub release with a CHANGELOG excerpt.

Versioning is semver. See `docs/MIGRATION_V2.md` for the v1 → v2 upgrade path.
