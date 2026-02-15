#!/bin/bash
# ClaudeForge v2.1.4 Migration Validation Script
# Tests that the migration to v2.0.0 was successful

echo "=== ClaudeForge v2.1.4 Migration Validation ==="
echo ""

SKILLS_DIR="$HOME/.claude/skills"
COMMANDS_DIR="$HOME/.claude/commands"
AGENTS_DIR="$HOME/.claude/agents"

PASS_COUNT=0
FAIL_COUNT=0

# Helper functions
pass() {
    echo "✓ $1"
    ((PASS_COUNT++))
}

fail() {
    echo "✗ $1"
    ((FAIL_COUNT++))
}

# Test 1: File Existence
echo "Test 1: File Existence"
echo "----------------------"
[ -f "$SKILLS_DIR/claudeforge-skill/SKILL.md" ] && pass "Skill file exists" || fail "Skill file missing"
[ -f "$COMMANDS_DIR/enhance-claude-md/enhance-claude-md.md" ] && pass "Command file exists" || fail "Command file missing"
[ -f "$AGENTS_DIR/claude-md-guardian.md" ] && pass "Agent file exists" || fail "Agent file missing"

# Test 2: v2.1.4 Syntax Validation
echo ""
echo "Test 2: v2.1.4 Syntax Validation"
echo "---------------------------------"
grep -q "permissions:" "$SKILLS_DIR/claudeforge-skill/SKILL.md" 2>/dev/null && pass "Skill uses permissions syntax" || fail "Skill uses old syntax"
grep -q "permissions:" "$COMMANDS_DIR/enhance-claude-md/enhance-claude-md.md" 2>/dev/null && pass "Command uses permissions syntax" || fail "Command uses old syntax"
grep -q "permissions:" "$AGENTS_DIR/claude-md-guardian.md" 2>/dev/null && pass "Agent uses permissions syntax" || fail "Agent uses old syntax"

# Test 3: Hooks Configuration
echo ""
echo "Test 3: Hooks Configuration"
echo "---------------------------"
grep -q "hooks:" "$AGENTS_DIR/claude-md-guardian.md" 2>/dev/null && pass "Agent has hooks configured" || fail "Agent missing hooks"
grep -q "SessionStart" "$AGENTS_DIR/claude-md-guardian.md" 2>/dev/null && pass "SessionStart hook present" || fail "SessionStart hook missing"
grep -q "PreToolUse" "$AGENTS_DIR/claude-md-guardian.md" 2>/dev/null && pass "PreToolUse hook present" || fail "PreToolUse hook missing"
grep -q "PostToolUse" "$AGENTS_DIR/claude-md-guardian.md" 2>/dev/null && pass "PostToolUse hook present" || fail "PostToolUse hook missing"

# Test 4: Fork-Safe Mode
echo ""
echo "Test 4: Fork-Safe Mode"
echo "----------------------"
grep -q "fork_safe: true" "$AGENTS_DIR/claude-md-guardian.md" 2>/dev/null && pass "Fork-safe mode enabled" || fail "Fork-safe mode not configured"

# Test 5: Python Modules Integrity
echo ""
echo "Test 5: Python Modules Integrity"
echo "--------------------------------"
[ -f "$SKILLS_DIR/claudeforge-skill/analyzer.py" ] && pass "analyzer.py present" || fail "analyzer.py missing"
[ -f "$SKILLS_DIR/claudeforge-skill/validator.py" ] && pass "validator.py present" || fail "validator.py missing"
[ -f "$SKILLS_DIR/claudeforge-skill/generator.py" ] && pass "generator.py present" || fail "generator.py missing"
[ -f "$SKILLS_DIR/claudeforge-skill/template_selector.py" ] && pass "template_selector.py present" || fail "template_selector.py missing"
[ -f "$SKILLS_DIR/claudeforge-skill/workflow.py" ] && pass "workflow.py present" || fail "workflow.py missing"

# Test 6: Legacy Syntax Check (should NOT be present)
echo ""
echo "Test 6: Legacy Syntax Cleanup"
echo "-----------------------------"
! grep -q "^tools:" "$AGENTS_DIR/claude-md-guardian.md" 2>/dev/null && pass "Agent has no legacy 'tools:' field" || fail "Agent still has legacy 'tools:' field"
! grep -q "^allowed-tools:" "$COMMANDS_DIR/enhance-claude-md/enhance-claude-md.md" 2>/dev/null && pass "Command has no legacy 'allowed-tools:' field" || fail "Command still has legacy 'allowed-tools:' field"

# Test 7: Documentation
echo ""
echo "Test 7: Documentation"
echo "--------------------"
[ -f "docs/MIGRATION_V2.md" ] && pass "Migration guide exists" || fail "Migration guide missing"
grep -q "2.0.0" "CHANGELOG.md" 2>/dev/null && pass "CHANGELOG has v2.0.0 entry" || fail "CHANGELOG missing v2.0.0 entry"
grep -q "2.1.4" "README.md" 2>/dev/null && pass "README references v2.1.4" || fail "README missing v2.1.4 reference"

# Test 8: Example Files
echo ""
echo "Test 8: Example Files Unchanged"
echo "-------------------------------"
[ -f "$SKILLS_DIR/claudeforge-skill/examples/minimal-solo-CLAUDE.md" ] && pass "Example files present" || fail "Example files missing"

# Summary
echo ""
echo "==================================="
echo "Validation Complete"
echo "==================================="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✅ All tests passed! Migration successful."
    exit 0
else
    echo "❌ Some tests failed. Review errors above."
    exit 1
fi
