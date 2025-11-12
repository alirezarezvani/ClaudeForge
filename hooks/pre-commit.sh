#!/bin/bash
# ClaudeForge Quality Hook - Pre-Commit Validation
# Validates CLAUDE.md file quality before allowing commits

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 ClaudeForge Quality Hook: Validating CLAUDE.md..."
echo ""

# Check if CLAUDE.md exists
if [ ! -f "CLAUDE.md" ]; then
    echo -e "${YELLOW}⚠  Warning: CLAUDE.md not found${NC}"
    echo "   Skipping validation (no CLAUDE.md to validate)"
    exit 0
fi

# Check if skill modules are available (for advanced validation)
SKILL_AVAILABLE=false
if [ -f "skill/validator.py" ] || [ -f "$HOME/.claude/skills/claudeforge-skill/validator.py" ]; then
    SKILL_AVAILABLE=true
fi

# Basic Validation (always run)
echo "Running basic validation checks..."

# 1. Check file length
echo -n "  ✓ Checking file length... "
LINES=$(wc -l < CLAUDE.md)
if [ $LINES -lt 20 ]; then
    echo -e "${RED}FAILED${NC}"
    echo -e "    ${RED}Error: CLAUDE.md too short ($LINES lines)${NC}"
    echo "    Minimum: 20 lines recommended"
    exit 1
elif [ $LINES -gt 400 ]; then
    echo -e "${YELLOW}WARNING${NC}"
    echo -e "    ${YELLOW}Warning: CLAUDE.md very long ($LINES lines)${NC}"
    echo "    Recommended: <300 lines (or use modular architecture)"
    echo "    Continuing anyway..."
else
    echo -e "${GREEN}OK${NC} ($LINES lines)"
fi

# 2. Check required sections
echo -n "  ✓ Checking required sections... "
MISSING_SECTIONS=()

for section in "Core Principles" "Tech Stack" "Workflow"; do
    if ! grep -qi "$section" CLAUDE.md; then
        MISSING_SECTIONS+=("$section")
    fi
done

if [ ${#MISSING_SECTIONS[@]} -gt 0 ]; then
    echo -e "${RED}FAILED${NC}"
    echo -e "    ${RED}Missing required sections:${NC}"
    for section in "${MISSING_SECTIONS[@]}"; do
        echo "      - $section"
    done
    echo ""
    echo "  Run: /enhance-claude-md to add missing sections"
    exit 1
else
    echo -e "${GREEN}OK${NC}"
fi

# 3. Check for code blocks
echo -n "  ✓ Checking for code examples... "
CODE_BLOCKS=$(grep -c '```' CLAUDE.md || echo "0")
if [ $CODE_BLOCKS -lt 2 ]; then
    echo -e "${YELLOW}WARNING${NC}"
    echo -e "    ${YELLOW}Warning: Few code examples ($CODE_BLOCKS blocks)${NC}"
    echo "    Recommended: Include code examples in your CLAUDE.md"
else
    echo -e "${GREEN}OK${NC} ($CODE_BLOCKS blocks)"
fi

# 4. Check for TODO/FIXME placeholders
echo -n "  ✓ Checking for placeholders... "
if grep -qi "TODO\|FIXME\|XXX\|\[TBD\]" CLAUDE.md; then
    echo -e "${YELLOW}WARNING${NC}"
    echo -e "    ${YELLOW}Warning: Found TODO/FIXME placeholders${NC}"
    grep -n "TODO\|FIXME\|XXX\|\[TBD\]" CLAUDE.md | head -3
    echo "    Consider completing these before committing"
else
    echo -e "${GREEN}OK${NC}"
fi

# 5. Check for potential secrets
echo -n "  ✓ Checking for hardcoded secrets... "
if grep -Ei "API_KEY|password|token|secret" CLAUDE.md | grep -v "example\|sample\|placeholder"; then
    echo -e "${RED}FAILED${NC}"
    echo -e "    ${RED}Error: Potential hardcoded secrets found${NC}"
    grep -n -Ei "API_KEY|password|token|secret" CLAUDE.md
    exit 1
else
    echo -e "${GREEN}OK${NC}"
fi

# Advanced Validation (if skill modules available)
if [ "$SKILL_AVAILABLE" = true ]; then
    echo ""
    echo "Running advanced validation (using ClaudeForge skill)..."

    # Determine skill path
    if [ -f "skill/validator.py" ]; then
        SKILL_PATH="skill"
    else
        SKILL_PATH="$HOME/.claude/skills/claudeforge-skill"
    fi

    # Run Python validation
    python3 << EOF
import sys
sys.path.insert(0, '$SKILL_PATH')

try:
    from validator import BestPracticesValidator

    with open('CLAUDE.md', 'r') as f:
        content = f.read()

    validator = BestPracticesValidator(content)
    results = validator.validate_all()

    passed = sum(1 for r in results if r['passed'])
    total = len(results)

    print(f"  ✓ Advanced validation: {passed}/{total} checks passed")

    if passed < 4:
        print(f"\n  \033[0;31mError: Only {passed}/{total} validation checks passed\033[0m")
        print("  Run: /enhance-claude-md to improve quality")
        sys.exit(1)

except Exception as e:
    print(f"  ⚠  Advanced validation skipped (error: {e})")
    pass
EOF

    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

# All checks passed
echo ""
echo -e "${GREEN}✅ CLAUDE.md validation passed!${NC}"
echo ""
echo "Proceeding with commit..."
exit 0
