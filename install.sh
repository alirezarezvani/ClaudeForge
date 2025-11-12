#!/bin/bash
# ClaudeForge Installer
# Automated installation script for macOS and Linux
# Version: 1.0.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

print_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}✗${NC}  $1"
}

# Banner
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                        ║${NC}"
echo -e "${BLUE}║         ${GREEN}ClaudeForge Installer${BLUE}         ║${NC}"
echo -e "${BLUE}║                                        ║${NC}"
echo -e "${BLUE}║  Automated CLAUDE.md Management Tool   ║${NC}"
echo -e "${BLUE}║            Version 1.0.0               ║${NC}"
echo -e "${BLUE}║                                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if running from correct directory
if [ ! -d "skill" ] || [ ! -d "command" ] || [ ! -d "agent" ]; then
    print_error "Installation files not found!"
    print_info "Please run this script from the ClaudeForge repository root."
    print_info "Usage: cd ClaudeForge && ./install.sh"
    exit 1
fi

# Check for Claude Code installation
print_info "Checking for Claude Code installation..."

if [ ! -d "$HOME/.claude" ]; then
    print_warning "Claude Code user directory (~/.claude) not found."
    print_info "Creating ~/.claude directory structure..."
    mkdir -p "$HOME/.claude"/{skills,commands,agents}
    print_success "Directory structure created"
fi

# Ask for installation scope
echo ""
print_info "Where would you like to install ClaudeForge?"
echo ""
echo "  ${GREEN}1)${NC} User-level (~/.claude/)     - Available in all Claude Code projects"
echo "  ${GREEN}2)${NC} Project-level (./.claude/)  - Available only in current project"
echo ""

while true; do
    read -p "$(echo -e ${BLUE}Enter choice [1/2]:${NC} )" choice
    case $choice in
        1)
            SKILLS_DIR="$HOME/.claude/skills"
            COMMANDS_DIR="$HOME/.claude/commands"
            AGENTS_DIR="$HOME/.claude/agents"
            SCOPE="user-level"
            print_success "Installing at user-level (all projects)"
            break
            ;;
        2)
            SKILLS_DIR="./.claude/skills"
            COMMANDS_DIR="./.claude/commands"
            AGENTS_DIR="./.claude/agents"
            SCOPE="project-level"
            print_success "Installing at project-level (current project only)"
            break
            ;;
        *)
            print_error "Invalid choice. Please enter 1 or 2."
            ;;
    esac
done

echo ""
print_info "Installation will create:"
echo "  • Skill:    $SKILLS_DIR/claudeforge-skill/"
echo "  • Command:  $COMMANDS_DIR/enhance-claude-md/"
echo "  • Agent:    $AGENTS_DIR/claude-md-guardian.md"
echo ""

# Confirm installation
read -p "$(echo -e ${BLUE}Proceed with installation? [Y/n]:${NC} )" confirm
confirm=${confirm:-Y}

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    print_warning "Installation cancelled."
    exit 0
fi

echo ""
print_info "Starting installation..."
echo ""

# Create directories if they don't exist
mkdir -p "$SKILLS_DIR" "$COMMANDS_DIR" "$AGENTS_DIR"

# Install skill
print_info "Installing ClaudeForge skill..."
if [ -d "$SKILLS_DIR/claudeforge-skill" ]; then
    print_warning "Existing skill found. Creating backup..."
    mv "$SKILLS_DIR/claudeforge-skill" "$SKILLS_DIR/claudeforge-skill.backup.$(date +%Y%m%d_%H%M%S)"
    print_success "Backup created"
fi
cp -r skill "$SKILLS_DIR/claudeforge-skill"
print_success "Skill installed → $SKILLS_DIR/claudeforge-skill/"

# Install slash command
print_info "Installing /enhance-claude-md command..."
if [ -d "$COMMANDS_DIR/enhance-claude-md" ]; then
    print_warning "Existing command found. Creating backup..."
    mv "$COMMANDS_DIR/enhance-claude-md" "$COMMANDS_DIR/enhance-claude-md.backup.$(date +%Y%m%d_%H%M%S)"
    print_success "Backup created"
fi
cp -r command "$COMMANDS_DIR/enhance-claude-md"
print_success "Command installed → $COMMANDS_DIR/enhance-claude-md/"

# Install guardian agent
print_info "Installing claude-md-guardian agent..."
if [ -f "$AGENTS_DIR/claude-md-guardian.md" ]; then
    print_warning "Existing agent found. Creating backup..."
    mv "$AGENTS_DIR/claude-md-guardian.md" "$AGENTS_DIR/claude-md-guardian.md.backup.$(date +%Y%m%d_%H%M%S)"
    print_success "Backup created"
fi
cp agent/claude-md-guardian.md "$AGENTS_DIR/"
print_success "Agent installed → $AGENTS_DIR/claude-md-guardian.md"

# Optional: Install quality hooks
echo ""
read -p "$(echo -e ${BLUE}Would you like to install quality hooks (pre-commit validation)? [y/N]:${NC} )" install_hooks
install_hooks=${install_hooks:-N}

if [[ $install_hooks =~ ^[Yy]$ ]]; then
    if [ "$SCOPE" == "project-level" ]; then
        print_info "Installing quality hooks..."
        mkdir -p .claude/hooks
        cp hooks/pre-commit.sh .claude/hooks/
        chmod +x .claude/hooks/pre-commit.sh
        print_success "Quality hooks installed → .claude/hooks/"
    else
        print_warning "Quality hooks can only be installed at project-level"
        print_info "Run installer with option 2 in your project directory"
    fi
fi

# Installation complete
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                        ║${NC}"
echo -e "${GREEN}║    Installation completed successfully!${NC}"
echo -e "${GREEN}║                                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Next steps
print_info "Next steps:"
echo ""
echo "  ${GREEN}1.${NC} Restart Claude Code (important!)"
echo "  ${GREEN}2.${NC} Navigate to your project directory"
echo "  ${GREEN}3.${NC} Run the command:"
echo ""
echo "     ${BLUE}/enhance-claude-md${NC}"
echo ""
echo "  ${GREEN}4.${NC} Follow the interactive prompts"
echo ""

# Additional information
print_info "Documentation:"
echo ""
echo "  • Quick Start:      docs/QUICK_START.md"
echo "  • Installation:     docs/INSTALLATION.md"
echo "  • Architecture:     docs/ARCHITECTURE.md"
echo "  • Troubleshooting:  docs/TROUBLESHOOTING.md"
echo ""
echo "  • GitHub:           ${BLUE}https://github.com/alirezarezvani/ClaudeForge${NC}"
echo ""

# Uninstall instructions
print_info "To uninstall, run:"
echo ""
if [ "$SCOPE" == "user-level" ]; then
    echo "  rm -rf ~/.claude/skills/claudeforge-skill"
    echo "  rm -rf ~/.claude/commands/enhance-claude-md"
    echo "  rm -f ~/.claude/agents/claude-md-guardian.md"
else
    echo "  rm -rf ./.claude/skills/claudeforge-skill"
    echo "  rm -rf ./.claude/commands/enhance-claude-md"
    echo "  rm -f ./.claude/agents/claude-md-guardian.md"
fi
echo ""

print_success "Thank you for installing ClaudeForge!"
echo ""
