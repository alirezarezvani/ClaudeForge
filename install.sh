#!/bin/bash
# ClaudeForge Installer
# Automated installation script for macOS and Linux
# Version: 2.0.0

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
echo -e "${BLUE}║            Version 2.0.0               ║${NC}"
echo -e "${BLUE}║                                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if running from correct directory or need to download
REMOTE_INSTALL=false
ORIGINAL_DIR=$(pwd)

if [ ! -d "skill" ] || [ ! -d "command" ] || [ ! -d "agent" ]; then
    print_info "Installing from GitHub..."
    REMOTE_INSTALL=true

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    print_info "Downloading ClaudeForge v2.0.0..."

    # Download using curl or wget
    if command -v curl &> /dev/null; then
        curl -fsSL https://github.com/alirezarezvani/ClaudeForge/archive/refs/heads/main.tar.gz -o claudeforge.tar.gz
    elif command -v wget &> /dev/null; then
        wget -q https://github.com/alirezarezvani/ClaudeForge/archive/refs/heads/main.tar.gz -O claudeforge.tar.gz
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    print_info "Extracting files..."
    tar -xzf claudeforge.tar.gz
    cd ClaudeForge-main

    print_success "Downloaded ClaudeForge successfully"
fi

# Check for Claude Code installation
print_info "Checking for Claude Code installation..."

if [ ! -d "$HOME/.claude" ]; then
    print_warning "Claude Code user directory (~/.claude) not found."
    print_info "Creating ~/.claude directory structure..."
    mkdir -p "$HOME/.claude"/{skills,commands,agents}
    print_success "Directory structure created"
fi

# Check Claude Code version
check_claude_code_version() {
    local version=""

    if command -v claude &> /dev/null; then
        version=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    fi

    if [ -z "$version" ]; then
        print_warning "Could not detect Claude Code version"
        print_info "ClaudeForge v2.0 requires Claude Code 2.1.0 or later"
        print_info "Continuing with installation (compatibility not guaranteed)"
        return 0
    fi

    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)

    if [ "$major" -lt 2 ]; then
        print_error "Claude Code version $version is not supported"
        print_error "Please upgrade to Claude Code 2.1.0 or later"
        return 1
    elif [ "$major" -eq 2 ] && [ "$minor" -lt 1 ]; then
        print_warning "Claude Code version $version may have limited features"
        print_info "Recommended: Claude Code 2.1.4 or later for full hook support"
    fi

    print_success "Claude Code version $version detected"
    return 0
}

print_info "Checking Claude Code version..."
check_claude_code_version || exit 1

# Ask for installation scope
echo ""
print_info "Where would you like to install ClaudeForge?"
echo ""
echo -e "  ${GREEN}1)${NC} User-level (~/.claude/)     - Available in all Claude Code projects"
echo -e "  ${GREEN}2)${NC} Project-level (./.claude/)  - Available only in current project"
echo ""

while true; do
    read -p "$(echo -e ${BLUE}Enter choice [1/2]:${NC} )" choice < /dev/tty
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
            if [ "$REMOTE_INSTALL" = true ]; then
                SKILLS_DIR="$ORIGINAL_DIR/.claude/skills"
                COMMANDS_DIR="$ORIGINAL_DIR/.claude/commands"
                AGENTS_DIR="$ORIGINAL_DIR/.claude/agents"
            else
                SKILLS_DIR="./.claude/skills"
                COMMANDS_DIR="./.claude/commands"
                AGENTS_DIR="./.claude/agents"
            fi
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
read -p "$(echo -e "${BLUE}Proceed with installation? [Y/n]:${NC}")" confirm < /dev/tty
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
read -p "$(echo -e "${BLUE}Would you like to install quality hooks (pre-commit validation)? [y/N]:${NC}")" install_hooks < /dev/tty
install_hooks=${install_hooks:-N}

if [[ $install_hooks =~ ^[Yy]$ ]]; then
    if [ "$SCOPE" == "project-level" ]; then
        print_info "Installing quality hooks..."
        if [ "$REMOTE_INSTALL" = true ]; then
            HOOKS_DIR="$ORIGINAL_DIR/.claude/hooks"
        else
            HOOKS_DIR=".claude/hooks"
        fi
        mkdir -p "$HOOKS_DIR"
        cp hooks/pre-commit.sh "$HOOKS_DIR/"
        chmod +x "$HOOKS_DIR/pre-commit.sh"
        print_success "Quality hooks installed → $HOOKS_DIR/"
    else
        print_warning "Quality hooks can only be installed at project-level"
        print_info "Run installer with option 2 in your project directory"
    fi
fi

# Validate v2.1.4 compatibility
validate_v214_compatibility() {
    print_info "Validating v2.1.4 compatibility..."

    local skill_file="$SKILLS_DIR/claudeforge-skill/SKILL.md"
    local agent_file="$AGENTS_DIR/claude-md-guardian.md"

    # Verify new syntax is present
    if ! grep -q "permissions:" "$skill_file"; then
        print_error "Skill missing v2.1.4 permissions syntax"
        return 1
    fi

    if ! grep -q "permissions:" "$agent_file"; then
        print_error "Agent missing v2.1.4 permissions syntax"
        return 1
    fi

    # Check for hooks
    if grep -q "hooks:" "$agent_file"; then
        print_success "Guardian agent hooks configured"
    else
        print_warning "Guardian agent has no hooks (optional)"
    fi

    print_success "v2.1.4 compatibility validated"
    return 0
}

echo ""
validate_v214_compatibility || {
    print_error "Installation validation failed"
    exit 1
}

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
echo -e "  ${GREEN}1.${NC} Restart Claude Code (important!)"
echo -e "  ${GREEN}2.${NC} Navigate to your project directory"
echo -e "  ${GREEN}3.${NC} Run the command:"
echo ""
echo -e "     ${BLUE}/enhance-claude-md${NC}"
echo ""
echo -e "  ${GREEN}4.${NC} Follow the interactive prompts"
echo ""

# Additional information
print_info "Documentation:"
echo ""
echo "  • Quick Start:      docs/QUICK_START.md"
echo "  • Installation:     docs/INSTALLATION.md"
echo "  • Architecture:     docs/ARCHITECTURE.md"
echo "  • Troubleshooting:  docs/TROUBLESHOOTING.md"
echo ""
echo -e "  • GitHub:           ${BLUE}https://github.com/alirezarezvani/ClaudeForge${NC}"
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

# Cleanup temporary directory if remote install
if [ "$REMOTE_INSTALL" = true ]; then
    cd "$HOME"
    rm -rf "$TEMP_DIR"
fi
