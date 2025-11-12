# Architecture Overview

Technical architecture and design decisions for ClaudeForge.

---

## System Design

### Component Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     User Project                         │
│                                                           │
│  User runs: /enhance-claude-md                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│          Slash Command (enhance-claude-md.md)           │
│                                                           │
│  Phase 1: Discovery    - Check CLAUDE.md existence      │
│  Phase 2: Analysis     - Determine initialize/enhance   │
│  Phase 3: Task         - Invoke skill or agent          │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ↓                       ↓
┌──────────────────┐    ┌──────────────────┐
│  Guardian Agent  │    │  Direct Skill    │
│  (Background)    │    │  Invocation      │
│                  │    │                  │
│  • SessionStart  │    │  • User request  │
│  • Manual invoke │    │  • One-time gen  │
└────────┬─────────┘    └─────────┬────────┘
         │                        │
         └────────────┬───────────┘
                      │
                      ↓
         ┌────────────────────────┐
         │  Skill: claudeforge    │
         │                        │
         │  Python Modules:       │
         │  • workflow.py         │
         │  • analyzer.py         │
         │  • validator.py        │
         │  • template_selector   │
         │  • generator.py        │
         └────────────┬───────────┘
                      │
                      ↓
         ┌────────────────────────┐
         │  CLAUDE.md Output      │
         │                        │
         │  • Root file           │
         │  • Context files       │
         │  • Native format       │
         └────────────────────────┘
```

---

## Data Flow

### 1. New Project Initialization

```
1. User → /enhance-claude-md
2. Command checks: CLAUDE.md not found
3. Command → Skill (initialize mode)
4. Skill workflow.py:
   - generate_exploration_prompt()
   - Claude explores repository
   - analyze_discoveries(exploration_results)
   - Returns project_context
5. Skill template_selector.py:
   - select_template(project_context)
   - Returns template configuration
6. Skill generator.py:
   - generate_root_file(template)
   - Returns CLAUDE.md content
7. Skill validator.py:
   - validate_all(generated_content)
   - Returns validation report
8. Output → CLAUDE.md file(s) created
```

### 2. Existing Project Enhancement

```
1. User → /enhance-claude-md
2. Command checks: CLAUDE.md exists
3. Command → Skill (enhance mode)
4. Skill analyzer.py:
   - analyze_file(current_content)
   - calculate_quality_score()
   - Returns analysis report
5. Skill validator.py:
   - validate_all(current_content)
   - Returns validation results
6. Skill shows user:
   - Quality score (0-100)
   - Missing sections
   - Recommendations
7. User confirms enhancement
8. Skill generator.py:
   - merge_with_existing(content, sections)
   - Returns enhanced content
9. Output → CLAUDE.md updated
```

### 3. Background Maintenance

```
1. SessionStart event
2. Guardian agent triggered
3. Agent checks git changes:
   - git diff --name-status HEAD~10
   - git diff package.json requirements.txt
4. Agent determines significance:
   - Files changed > 5?
   - New dependencies?
   - New directories?
5. If significant:
   - Agent → Skill (enhance mode)
   - Skill updates specific sections
   - Agent validates changes
6. Output → CLAUDE.md synced
```

---

## Module Design

### workflow.py

**Purpose:** Interactive initialization for new projects

**Key Classes:**
- `InitializationWorkflow` - Main orchestrator

**Key Methods:**
```python
check_claude_md_exists() → bool
generate_exploration_prompt() → str
analyze_discoveries(results: Dict) → Dict[str, Any]
_detect_project_type(results) → str
_detect_tech_stack(results) → List[str]
_estimate_team_size(results) → str
_detect_development_phase(results) → str
_detect_workflows(results) → List[str]
_should_use_modular(results) → bool
```

**Detection Logic:**
- Project type: Check for frontend/, backend/, src/ patterns
- Tech stack: Parse package.json, requirements.txt, go.mod
- Team size: Analyze git contributors, project complexity
- Phase: Check for CI/CD, production configs
- Workflows: Detect test/, .github/, documentation patterns

---

### analyzer.py

**Purpose:** Analyze existing CLAUDE.md files

**Key Classes:**
- `CLAUDEMDAnalyzer` - File analyzer

**Quality Scoring Algorithm:**
```python
def calculate_quality_score(self) → int:
    score = 0

    # Length appropriateness (25 points)
    if 20 <= line_count <= 300:
        score += 25
    elif 300 < line_count <= 400:
        score += 15  # Warn: consider modular
    else:
        score += 5   # Poor: too short or too long

    # Section completeness (25 points)
    required = ["Core Principles", "Tech Stack", "Workflow"]
    found = len([s for s in required if s in sections])
    score += (found / len(required)) * 25

    # Formatting quality (20 points)
    # Check: headings, code blocks, lists, links
    score += formatting_score

    # Content specificity (15 points)
    # Check: project-specific vs. generic
    score += specificity_score

    # Modular organization (15 points)
    # Check: context files if needed
    score += modular_score

    return min(score, 100)
```

---

### validator.py

**Purpose:** Validate against best practices

**Validation Categories:**

1. **Length Validation**
   - Recommended: 20-300 lines
   - Warning: 300-400 lines (suggest modular)
   - Error: < 20 or > 400 lines

2. **Structure Validation**
   - Required sections: Core Principles, Tech Stack, Workflow
   - Recommended sections: Testing, Error Handling
   - Heading hierarchy: H1 → H2 → H3 (no skips)

3. **Formatting Validation**
   - Balanced code blocks (open/close)
   - Valid markdown syntax
   - No broken links

4. **Completeness Validation**
   - Has code examples
   - Lists tech stack with versions
   - Includes setup instructions

5. **Anti-Pattern Detection**
   - No hardcoded secrets (API keys, tokens)
   - No TODO placeholders
   - No broken reference links

---

### template_selector.py

**Purpose:** Select appropriate template

**Selection Matrix:**

| Project Type | Team Size | Lines | Template |
|--------------|-----------|-------|----------|
| CLI/Library | Solo | 50-75 | minimal |
| Web App | Small | 100-150 | core |
| API | Small | 125-175 | api-focused |
| Full-Stack | Medium | 200-300 | detailed |
| Enterprise | Large | Modular | root + contexts |

**Modular Recommendation Logic:**
```python
def recommend_modular_structure(context: Dict) → bool:
    return (
        context['type'] == 'fullstack' or
        context['team_size'] in ['medium', 'large'] or
        context['phase'] in ['production', 'enterprise'] or
        len(context['tech_stack']) > 5
    )
```

---

### generator.py

**Purpose:** Generate CLAUDE.md content

**Generation Modes:**

1. **Root File (Navigation Hub)**
   - Quick Navigation section
   - Core Principles (high-level)
   - Tech Stack summary
   - Links to context files

2. **Context File (Specific Area)**
   - Detailed guidelines for backend/, frontend/, etc.
   - Tech-specific patterns
   - Common commands for that area

3. **Section Generation (Individual)**
   - Generate single section
   - Merge with existing content

**Native Format Template:**
```markdown
# CLAUDE.md

[Overview paragraph]

## Project Structure

```
project/
├── src/
│   ├── components/
│   └── services/
└── tests/
```

## File Structure

- `src/` - Source code
- `tests/` - Test files

## Setup & Installation

```bash
npm install
npm run dev
```

## Architecture

[Key design decisions]

## Core Principles

1. Principle one
2. Principle two

## Tech Stack

- React 18
- TypeScript 5
- Node.js 20

## Common Commands

```bash
npm run build  # Build project
npm test       # Run tests
```
```

---

## Integration Points

### Skill ↔ Slash Command

**File:** `command/enhance-claude-md.md`

```yaml
# YAML frontmatter
allowed-tools: Bash, Read, Glob, Skill

# Phase 3: Task section
I can invoke the `claude-md-enhancer` skill...
```

Claude Code recognizes skill name and loads Python modules.

### Skill ↔ Guardian Agent

**File:** `agent/claude-md-guardian.md`

```yaml
# YAML frontmatter
tools: Bash, Read, Write, Edit, Grep, Glob, Skill
model: haiku

# Agent workflow section
I invoke the `claude-md-enhancer` skill...
```

Agent uses `haiku` model for token efficiency, invokes skill for updates.

### Agent ↔ Git

Agent detects changes via bash commands:
```bash
git diff --name-status HEAD~10
git log --since="1 week ago" --oneline
git diff HEAD~10 -- package.json requirements.txt
```

Triggers update if:
- 5+ files changed
- Dependencies modified
- New directories created

---

## Design Decisions

### Why Python for Skill Modules?

- **Portability:** Standard library only, no dependencies
- **Readability:** Clear logic for community contributions
- **Performance:** Adequate for file analysis/generation
- **Integration:** Claude Code supports Python natively

### Why Separate Slash Command and Agent?

- **Slash Command:** User-initiated, interactive, immediate feedback
- **Agent:** Background, automatic, non-intrusive
- **Flexibility:** User chooses explicit control vs. automation

### Why Quality Scoring Algorithm?

- **Objectivity:** Consistent evaluation across projects
- **Actionable:** Specific areas to improve
- **Educational:** Users learn best practices
- **Gamification:** Encourages quality improvement

### Why Modular Architecture Support?

- **Scalability:** Large projects need organization
- **Context:** Different areas have different needs
- **Maintainability:** Easier to update specific sections
- **Team:** Different teams own different files

---

## Performance Considerations

### Token Efficiency

**Guardian Agent uses `haiku` model:**
- Routine updates: ~500-1000 tokens
- Targeted section updates only
- Saves 70-80% tokens vs. full regeneration

**Slash Command uses default model (sonnet):**
- Interactive, user-facing
- Requires better understanding
- More complex reasoning

### File Size Limits

- Single file: Max 400 lines (prefer 300)
- Modular files: Each 150-300 lines
- Total project: Unlimited with modular

### Caching Strategy

No caching implemented (stateless design):
- Each invocation reads fresh files
- Ensures accuracy with latest changes
- Simple implementation

---

## Security Considerations

### Anti-Pattern Detection

**validator.py** checks for:
- Hardcoded secrets: `API_KEY=`, `password=`, `token=`
- Placeholder TODOs: `TODO`, `FIXME`, `XXX`
- Broken links: Invalid URL patterns

### File Permissions

Installation respects user permissions:
- User-level: `~/.claude/` (user writable)
- Project-level: `./.claude/` (project writable)
- No system-level changes

### Git Integration

Agent only reads git:
- `git diff` (read-only)
- `git log` (read-only)
- `git status` (read-only)
- No git write operations

---

## Extensibility

### Adding New Project Types

1. Update `workflow.py` → `_detect_project_type()`
2. Add detection patterns
3. Update `template_selector.py` → selection matrix
4. Create new template in `skill/examples/`

### Adding New Tech Stacks

1. Update `workflow.py` → `_detect_tech_stack()`
2. Add file detection (e.g., `Cargo.toml` for Rust)
3. Update `generator.py` → tech-specific sections

### Adding New Validation Rules

1. Update `validator.py` → `validate_all()`
2. Add new validation method
3. Return validation result in standard format

---

## Testing Strategy

### Manual Testing

See [QUICK_START.md](QUICK_START.md) for test scenarios.

### Integration Testing

Test entire flow:
1. Install components
2. Run slash command
3. Verify output quality
4. Test guardian agent
5. Validate native format

### Unit Testing

(Not implemented in v1.0.0, planned for v1.1.0)
- Test each Python module independently
- Mock file I/O
- Validate scoring algorithms

---

## Future Architecture

### Planned for v1.1.0

- **VS Code Extension:** Inline editing, real-time validation
- **GitHub Action:** Auto-generate on repo creation
- **Custom Templates:** User-defined template system
- **Analytics:** Usage patterns, effectiveness metrics

### Planned for v2.0.0

- **AI-Powered Suggestions:** Context-aware recommendations
- **Multi-Language Support:** i18n for generated content
- **Web Dashboard:** Project-wide management
- **Plugin System:** Third-party extensions

---

## Related Documentation

- **Implementation Details:** [CLAUDE.md](../CLAUDE.md)
- **Installation:** [INSTALLATION.md](INSTALLATION.md)
- **Quick Start:** [QUICK_START.md](QUICK_START.md)
- **Troubleshooting:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

**Questions about architecture?** Open an issue: https://github.com/alirezarezvani/ClaudeForge/issues
