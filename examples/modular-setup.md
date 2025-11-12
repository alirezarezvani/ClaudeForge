# Modular Architecture Setup

Examples of modular CLAUDE.md structure for large projects.

---

## When to Use Modular Architecture

- Full-stack projects with distinct frontend/backend
- Team size > 10 developers
- Single CLAUDE.md would exceed 300 lines
- Different teams own different areas

---

## Example: E-Commerce Platform

**Project Structure:**
```
ecommerce/
├── CLAUDE.md              # Root navigation
├── backend/
│   ├── CLAUDE.md          # API guidelines
│   └── api/
├── frontend/
│   ├── CLAUDE.md          # React guidelines
│   └── src/
├── mobile/
│   ├── CLAUDE.md          # React Native guidelines
│   └── app/
└── database/
    ├── CLAUDE.md          # Schema guidelines
    └── migrations/
```

**Setup:**
```bash
mkdir -p ecommerce/{backend,frontend,mobile,database}
cd ecommerce

# Create basic files for detection
echo '{"dependencies":{"express":""}}' > backend/package.json
echo '{"dependencies":{"react":""}}' > frontend/package.json
echo '{"dependencies":{"react-native":""}}' > mobile/package.json
```

**Run:**
```
/enhance-claude-md

"Use modular architecture for this full-stack e-commerce platform"
```

**Output:**
- `CLAUDE.md` - 95 lines (navigation)
- `backend/CLAUDE.md` - 180 lines (API, auth, payments)
- `frontend/CLAUDE.md` - 165 lines (components, state, cart)
- `mobile/CLAUDE.md` - 145 lines (screens, navigation, offline)
- `database/CLAUDE.md` - 120 lines (schema, migrations, queries)

---

## Root CLAUDE.md (Navigation Hub)

**Content:**
```markdown
# CLAUDE.md

Quick navigation hub for this project.

## Quick Navigation

- [Backend API Guidelines](backend/CLAUDE.md)
- [Frontend React Guidelines](frontend/CLAUDE.md)
- [Mobile App Guidelines](mobile/CLAUDE.md)
- [Database Operations](database/CLAUDE.md)

## Core Principles

1. API-first development
2. Mobile-responsive design
3. Database integrity
4. Comprehensive testing

## Project Structure

```
[ASCII tree diagram]
```

## Common Commands

```bash
# Backend
cd backend && npm run dev

# Frontend
cd frontend && npm start

# Mobile
cd mobile && npm run ios
```
```

---

## Context-Specific Files

### backend/CLAUDE.md

**Focus:**
- API endpoints design (REST/GraphQL)
- Authentication & authorization
- Database queries and optimization
- Error handling patterns
- Testing strategies (unit, integration)

### frontend/CLAUDE.md

**Focus:**
- Component architecture
- State management
- Routing and navigation
- Performance optimization
- Accessibility standards

### mobile/CLAUDE.md

**Focus:**
- Screen layouts
- Native features (camera, GPS, etc.)
- Offline functionality
- Platform-specific patterns (iOS/Android)
- App store deployment

### database/CLAUDE.md

**Focus:**
- Schema design
- Migration procedures
- Query optimization
- Backup strategies
- Data integrity rules

---

## Benefits

✅ **Separation of Concerns:** Each area has focused guidelines
✅ **Team Ownership:** Different teams manage their files
✅ **Maintainability:** Easier to update specific areas
✅ **Scalability:** Add new areas without bloat
✅ **Readability:** Each file stays under 200 lines

---

## Maintenance

**Guardian Agent updates all files:**
```
# New backend dependency added
✅ backend/CLAUDE.md updated: Tech Stack section

# New frontend component pattern
✅ frontend/CLAUDE.md updated: Component Guidelines

# Database schema change
✅ database/CLAUDE.md updated: Schema Documentation
```

---

See also:
- [basic-usage.md](basic-usage.md) - Simple projects
- [integration-examples.md](integration-examples.md) - CI/CD
