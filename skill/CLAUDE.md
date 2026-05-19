> Parent context: see the root [CLAUDE.md](../CLAUDE.md) for project-wide guidelines and behavioural rules.
> Chained import: `@../CLAUDE.md`

# Skill Development

Guidelines for the `claudeforge-skill` Python modules and the `karpathy-guidelines` skill.

## Component Interaction Flow

```
User Project
    ↓
/enhance-claude-md (Slash Command)  →  Explore subagent (deep scan)
    ↓
[Discovery] → [Analysis] → [Task]
    ↓
claude-md-guardian (Agent) OR Direct Skill Invocation
    ↓
claudeforge-skill (Python Modules)
    ↓
workflow.py → analyzer.py → validator.py → template_selector.py → generator.py
    ↓
CLAUDE.md ≤ 150 lines, chained via `@path` imports
```

## Python Module Architecture

Five modules live under `skill/`:

- **`workflow.py`** — `InitializationWorkflow`: orchestrates interactive setup, detects project type / tech stack / team size / phase / workflows, returns a context dict.
- **`analyzer.py`** — `CLAUDEMDAnalyzer`: analyses existing files; quality scoring (0–100) across length, completeness, formatting, specificity, modularity.
- **`validator.py`** — `BestPracticesValidator`: checks file length (hard cap 150, warning at 120), required sections, formatting, anti-patterns.
- **`template_selector.py`** — `TemplateSelector`: maps project type + team size to a template; all team-size targets are ≤ 150 lines.
- **`generator.py`** — `ContentGenerator`: writes root + context files, emits `@path` chain imports, prepends sub-file back-links, idempotent `merge_with_existing`. Also exposes `generate_rules_file(name, description, paths, body)` for path-scoped `.claude/rules/*.md` files (loaded lazily by Claude when accessed files match the `paths:` globs) and prepends `@AGENTS.md`-style imports when `project_context['existing_instruction_files']` lists sibling instruction files.

## Required Output Sections

Every generated CLAUDE.md must contain:

- Project structure (ASCII tree, for projects that need it)
- Setup & installation
- Architecture (for non-trivial projects)
- `## Behavioral Guidelines` (Karpathy summary — inserted automatically)
- Cross-check against reference examples in `skill/examples/`

## Modifying Python Modules

1. Edit files in `skill/`.
2. Run the smoke test (see `docs/CLAUDE.md` → Testing & Validation).
3. Re-install for live testing: `./install.sh` (project-level scope).
4. Test slash command: `/enhance-claude-md`.
5. Validate output against `skill/examples/`.
6. Update `CHANGELOG.md`.

## Adding Reference Templates

1. Add a new file under `skill/examples/`.
2. Follow the native format (project structure, setup, architecture, tech guidelines).
3. Update `skill/examples/README.md`.
4. Teach `template_selector.py` how to detect the new template.
5. Add a scenario to `skill/sample_input.json`.

## Quality Scoring (analyzer.py)

`calculate_quality_score()` breakdown:

- length_appropriateness: 25 pts (50–150 lines ideal; the 150-line hard cap is enforced here)
- section_completeness: 25 pts (required sections present)
- formatting_quality: 20 pts (markdown, heading hierarchy, code blocks)
- content_specificity: 15 pts (project-specific, not generic)
- modular_organization: 15 pts (chained sub-files when needed)

## Tech Stack Detection

`skill/workflow.py` → `_detect_tech_stack()` reads these signals:

- **Frontend** — React/Vue/Angular via `package.json`; Angular via `angular.json`; TypeScript via `tsconfig.json`.
- **Backend** — Node (`package.json`), Python (`requirements.txt` / `pyproject.toml` / `setup.py`), Go (`go.mod`), Java (`pom.xml` / `build.gradle`), Rust (`Cargo.toml`).
- **Database** — Postgres (`pg` / `psycopg2`), MongoDB (`mongoose` / `pymongo`), Redis (`redis` / `ioredis`).

Add new detectors there, not in the template selector.

## Karpathy Guidelines Skill

`skill/karpathy-guidelines/SKILL.md` is the standalone skill installed at `~/.claude/skills/karpathy-guidelines/`. Adapted with attribution from the MIT-licensed [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) repo. The four principles are inserted automatically into every generated CLAUDE.md via `template_selector._generate_karpathy_guidelines()` and `generator._generate_karpathy_guidelines()`. Do not strip the embedded section during enhancement.
