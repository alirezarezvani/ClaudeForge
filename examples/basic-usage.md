# Basic Usage Examples

Common ClaudeForge usage scenarios.

---

## Example 1: New TypeScript React Project

**Scenario:** Starting fresh project, need CLAUDE.md

**Setup:**
```bash
mkdir my-react-app
cd my-react-app
npm init -y
npm install react react-dom typescript
```

**Run ClaudeForge:**
```
/enhance-claude-md
```

**Claude's Response:**
```
Discovered:
- Project Type: Web App
- Tech Stack: TypeScript, React, Node.js
- Team Size: Solo
- Phase: Prototype

Creating CLAUDE.md (85 lines) with:
- Project structure diagram
- Setup instructions (npm install, npm start)
- Component guidelines
- TypeScript best practices
```

**Output:** Single `CLAUDE.md` file, ~85 lines

---

## Example 2: Python FastAPI Project

**Scenario:** API service, team of 6

**Setup:**
```bash
mkdir api-service
cd api-service
echo "fastapi[all]" > requirements.txt
echo "pytest" >> requirements.txt
mkdir app tests
```

**Run ClaudeForge:**
```
/enhance-claude-md

"This is a Python FastAPI API service. Team of 6 developers, MVP phase."
```

**Output:** `CLAUDE.md` with:
- FastAPI patterns
- Async/await guidelines
- Testing with pytest
- API documentation standards

---

## Example 3: Full-Stack Application

**Scenario:** Large project with backend + frontend

**Setup:**
```bash
mkdir fullstack-app
cd fullstack-app
mkdir backend frontend
cd backend && echo "express" > package.json
cd ../frontend && echo "react" > package.json
```

**Run ClaudeForge:**
```
/enhance-claude-md
```

**Output:** Modular structure
- `CLAUDE.md` (root navigation)
- `backend/CLAUDE.md` (API guidelines)
- `frontend/CLAUDE.md` (React patterns)

---

## Example 4: Enhance Existing Basic File

**Before:**
```markdown
# CLAUDE.md

## Tech Stack
- TypeScript
- React
```

**Run:**
```
/enhance-claude-md
```

**Claude Analyzes:**
```
Quality Score: 25/100

Missing:
- Project Structure
- Setup & Installation
- Core Principles
- Common Commands
```

**After:** Complete 120-line file with all sections

---

## Example 5: Quality Check Before Commit

**Scenario:** Made edits, verify quality

**Run:**
```
/enhance-claude-md

"Just validate, don't make changes"
```

**Output:**
```
Quality Score: 88/100

✅ Length: 245 lines (good)
✅ Structure: All required sections
✅ Formatting: Valid markdown
⚠️  Consider adding: Performance Guidelines
```

---

See also:
- [modular-setup.md](modular-setup.md) - Complex projects
- [integration-examples.md](integration-examples.md) - CI/CD integration
