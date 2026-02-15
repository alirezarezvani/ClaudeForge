#!/bin/bash
# ClaudeForge Rollback Script
# Rolls back from v2.0.0 to v1.0.0 using automatic backups

echo "=== ClaudeForge Rollback to v1.x ==="
echo ""

SKILLS_DIR="$HOME/.claude/skills"
COMMANDS_DIR="$HOME/.claude/commands"
AGENTS_DIR="$HOME/.claude/agents"

RESTORED_COUNT=0

# Find and restore skill backup
echo "Searching for skill backup..."
for backup in "$SKILLS_DIR"/claudeforge-skill.v1_backup_* "$SKILLS_DIR"/claudeforge-skill.backup.*; do
    if [ -d "$backup" ]; then
        echo "Found backup: $(basename $backup)"
        rm -rf "$SKILLS_DIR/claudeforge-skill"
        mv "$backup" "$SKILLS_DIR/claudeforge-skill"
        echo "✓ Restored skill from: $(basename $backup)"
        ((RESTORED_COUNT++))
        break
    fi
done

# Find and restore command backup
echo ""
echo "Searching for command backup..."
for backup in "$COMMANDS_DIR"/enhance-claude-md.v1_backup_* "$COMMANDS_DIR"/enhance-claude-md.backup.*; do
    if [ -d "$backup" ]; then
        echo "Found backup: $(basename $backup)"
        rm -rf "$COMMANDS_DIR/enhance-claude-md"
        mv "$backup" "$COMMANDS_DIR/enhance-claude-md"
        echo "✓ Restored command from: $(basename $backup)"
        ((RESTORED_COUNT++))
        break
    fi
done

# Find and restore agent backup
echo ""
echo "Searching for agent backup..."
for backup in "$AGENTS_DIR"/claude-md-guardian.md.v1_backup_* "$AGENTS_DIR"/claude-md-guardian.md.backup.*; do
    if [ -f "$backup" ]; then
        echo "Found backup: $(basename $backup)"
        rm -f "$AGENTS_DIR/claude-md-guardian.md"
        mv "$backup" "$AGENTS_DIR/claude-md-guardian.md"
        echo "✓ Restored agent from: $(basename $backup)"
        ((RESTORED_COUNT++))
        break
    fi
done

# Summary
echo ""
echo "===================================="
echo "Rollback Summary"
echo "===================================="
echo "Components restored: $RESTORED_COUNT"
echo ""

if [ $RESTORED_COUNT -eq 0 ]; then
    echo "⚠️  No backups found. Cannot rollback."
    echo ""
    echo "To manually install v1.0.0:"
    echo "  curl -fsSL https://github.com/alirezarezvani/ClaudeForge/archive/refs/tags/v1.0.0.tar.gz | tar -xz"
    echo "  cd ClaudeForge-1.0.0"
    echo "  ./install.sh"
    exit 1
else
    echo "✅ Rollback complete!"
    echo ""
    echo "Next steps:"
    echo "1. Restart Claude Code"
    echo "2. Test with: /enhance-claude-md"
    exit 0
fi
