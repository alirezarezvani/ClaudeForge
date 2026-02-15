# ClaudeForge Installer for Windows
# PowerShell installation script
# Version: 2.0.0

#Requires -Version 5.1

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ  $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓  $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠  $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗  $Message" -ForegroundColor Red
}

# Banner
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║                                        ║" -ForegroundColor Blue
Write-Host "║         " -NoNewline -ForegroundColor Blue
Write-Host "ClaudeForge Installer" -NoNewline -ForegroundColor Green
Write-Host "         ║" -ForegroundColor Blue
Write-Host "║                                        ║" -ForegroundColor Blue
Write-Host "║  Automated CLAUDE.md Management Tool   ║" -ForegroundColor Blue
Write-Host "║            Version 2.0.0               ║" -ForegroundColor Blue
Write-Host "║                                        ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Check if running from correct directory or need to download
$RemoteInstall = $false
$OriginalDir = Get-Location

if (-not (Test-Path "skill") -or -not (Test-Path "command") -or -not (Test-Path "agent")) {
    Write-Info "Installing from GitHub..."
    $RemoteInstall = $true

    # Create temporary directory
    $TempDir = New-Item -ItemType Directory -Path ([System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString())) -Force
    Set-Location $TempDir

    Write-Info "Downloading ClaudeForge v2.0.0..."

    # Download archive
    $archiveUrl = "https://github.com/alirezarezvani/ClaudeForge/archive/refs/heads/main.zip"
    $archivePath = Join-Path $TempDir "claudeforge.zip"

    try {
        Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath -UseBasicParsing
    } catch {
        Write-Error-Custom "Failed to download ClaudeForge. Please check your internet connection."
        exit 1
    }

    Write-Info "Extracting files..."
    Expand-Archive -Path $archivePath -DestinationPath $TempDir -Force
    Set-Location (Join-Path $TempDir "ClaudeForge-main")

    Write-Success "Downloaded ClaudeForge successfully"
}

# Check for Claude Code installation
Write-Info "Checking for Claude Code installation..."

$claudeDir = "$env:USERPROFILE\.claude"
if (-not (Test-Path $claudeDir)) {
    Write-Warning "Claude Code user directory (~/.claude) not found."
    Write-Info "Creating $claudeDir directory structure..."
    New-Item -ItemType Directory -Path "$claudeDir\skills" -Force | Out-Null
    New-Item -ItemType Directory -Path "$claudeDir\commands" -Force | Out-Null
    New-Item -ItemType Directory -Path "$claudeDir\agents" -Force | Out-Null
    Write-Success "Directory structure created"
}

# Check Claude Code version
function Check-ClaudeCodeVersion {
    $version = $null

    try {
        $output = & claude --version 2>&1
        if ($output -match '\d+\.\d+\.\d+') {
            $version = $matches[0]
        }
    } catch {
        Write-Warning "Could not detect Claude Code version"
        Write-Info "ClaudeForge v2.0 requires Claude Code 2.1.0 or later"
        Write-Info "Continuing with installation (compatibility not guaranteed)"
        return $true
    }

    if ([string]::IsNullOrEmpty($version)) {
        Write-Warning "Could not detect Claude Code version"
        Write-Info "Continuing with installation (compatibility not guaranteed)"
        return $true
    }

    $parts = $version.Split('.')
    $major = [int]$parts[0]
    $minor = [int]$parts[1]

    if ($major -lt 2) {
        Write-Error-Custom "Claude Code version $version is not supported"
        Write-Error-Custom "Please upgrade to Claude Code 2.1.0 or later"
        return $false
    } elseif ($major -eq 2 -and $minor -lt 1) {
        Write-Warning "Claude Code version $version may have limited features"
        Write-Info "Recommended: Claude Code 2.1.4 or later for full hook support"
    }

    Write-Success "Claude Code version $version detected"
    return $true
}

Write-Info "Checking Claude Code version..."
if (-not (Check-ClaudeCodeVersion)) {
    exit 1
}

# Ask for installation scope
Write-Host ""
Write-Info "Where would you like to install ClaudeForge?"
Write-Host ""
Write-Host "  " -NoNewline
Write-Host "1)" -ForegroundColor Green -NoNewline
Write-Host " User-level (~/.claude/)     - Available in all Claude Code projects"
Write-Host "  " -NoNewline
Write-Host "2)" -ForegroundColor Green -NoNewline
Write-Host " Project-level (./.claude/)  - Available only in current project"
Write-Host ""

$validChoice = $false
while (-not $validChoice) {
    $choice = Read-Host "Enter choice [1/2]"
    switch ($choice) {
        "1" {
            $skillsDir = "$env:USERPROFILE\.claude\skills"
            $commandsDir = "$env:USERPROFILE\.claude\commands"
            $agentsDir = "$env:USERPROFILE\.claude\agents"
            $scope = "user-level"
            Write-Success "Installing at user-level (all projects)"
            $validChoice = $true
        }
        "2" {
            if ($RemoteInstall) {
                $skillsDir = Join-Path $OriginalDir ".claude\skills"
                $commandsDir = Join-Path $OriginalDir ".claude\commands"
                $agentsDir = Join-Path $OriginalDir ".claude\agents"
            } else {
                $skillsDir = ".\.claude\skills"
                $commandsDir = ".\.claude\commands"
                $agentsDir = ".\.claude\agents"
            }
            $scope = "project-level"
            Write-Success "Installing at project-level (current project only)"
            $validChoice = $true
        }
        default {
            Write-Error-Custom "Invalid choice. Please enter 1 or 2."
        }
    }
}

Write-Host ""
Write-Info "Installation will create:"
Write-Host "  • Skill:    $skillsDir\claudeforge-skill\"
Write-Host "  • Command:  $commandsDir\enhance-claude-md\"
Write-Host "  • Agent:    $agentsDir\claude-md-guardian.md"
Write-Host ""

# Confirm installation
$confirm = Read-Host "Proceed with installation? [Y/n]"
if ([string]::IsNullOrEmpty($confirm)) { $confirm = "Y" }

if ($confirm -notmatch "^[Yy]$") {
    Write-Warning "Installation cancelled."
    exit 0
}

Write-Host ""
Write-Info "Starting installation..."
Write-Host ""

# Create directories if they don't exist
New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null

# Install skill
Write-Info "Installing ClaudeForge skill..."
$skillPath = "$skillsDir\claudeforge-skill"
if (Test-Path $skillPath) {
    Write-Warning "Existing skill found. Creating backup..."
    $backupName = "claudeforge-skill.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Move-Item -Path $skillPath -Destination "$skillsDir\$backupName" -Force
    Write-Success "Backup created"
}
Copy-Item -Path "skill" -Destination $skillPath -Recurse -Force
Write-Success "Skill installed → $skillPath\"

# Install slash command
Write-Info "Installing /enhance-claude-md command..."
$commandPath = "$commandsDir\enhance-claude-md"
if (Test-Path $commandPath) {
    Write-Warning "Existing command found. Creating backup..."
    $backupName = "enhance-claude-md.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Move-Item -Path $commandPath -Destination "$commandsDir\$backupName" -Force
    Write-Success "Backup created"
}
Copy-Item -Path "command" -Destination $commandPath -Recurse -Force
Write-Success "Command installed → $commandPath\"

# Install guardian agent
Write-Info "Installing claude-md-guardian agent..."
$agentPath = "$agentsDir\claude-md-guardian.md"
if (Test-Path $agentPath) {
    Write-Warning "Existing agent found. Creating backup..."
    $backupName = "claude-md-guardian.md.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Move-Item -Path $agentPath -Destination "$agentsDir\$backupName" -Force
    Write-Success "Backup created"
}
Copy-Item -Path "agent\claude-md-guardian.md" -Destination $agentPath -Force
Write-Success "Agent installed → $agentPath"

# Optional: Install quality hooks
Write-Host ""
$installHooks = Read-Host "Would you like to install quality hooks (pre-commit validation)? [y/N]"
if ([string]::IsNullOrEmpty($installHooks)) { $installHooks = "N" }

if ($installHooks -match "^[Yy]$") {
    if ($scope -eq "project-level") {
        Write-Info "Installing quality hooks..."
        if ($RemoteInstall) {
            $hooksDir = Join-Path $OriginalDir ".claude\hooks"
        } else {
            $hooksDir = ".claude\hooks"
        }
        New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
        Copy-Item -Path "hooks\pre-commit.sh" -Destination "$hooksDir\" -Force
        Write-Success "Quality hooks installed → $hooksDir\"
    } else {
        Write-Warning "Quality hooks can only be installed at project-level"
        Write-Info "Run installer with option 2 in your project directory"
    }
}

# Validate v2.1.4 compatibility
function Validate-V214Compatibility {
    param(
        [string]$skillsDir,
        [string]$agentsDir
    )

    Write-Info "Validating v2.1.4 compatibility..."

    $skillFile = Join-Path $skillsDir "claudeforge-skill\SKILL.md"
    $agentFile = Join-Path $agentsDir "claude-md-guardian.md"

    # Verify new syntax is present
    if (-not (Select-String -Path $skillFile -Pattern "permissions:" -Quiet)) {
        Write-Error-Custom "Skill missing v2.1.4 permissions syntax"
        return $false
    }

    if (-not (Select-String -Path $agentFile -Pattern "permissions:" -Quiet)) {
        Write-Error-Custom "Agent missing v2.1.4 permissions syntax"
        return $false
    }

    # Check for hooks
    if (Select-String -Path $agentFile -Pattern "hooks:" -Quiet) {
        Write-Success "Guardian agent hooks configured"
    } else {
        Write-Warning "Guardian agent has no hooks (optional)"
    }

    Write-Success "v2.1.4 compatibility validated"
    return $true
}

Write-Host ""
if (-not (Validate-V214Compatibility -skillsDir $skillsDir -agentsDir $agentsDir)) {
    Write-Error-Custom "Installation validation failed"
    exit 1
}

# Installation complete
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                        ║" -ForegroundColor Green
Write-Host "║    Installation completed successfully!║" -ForegroundColor Green
Write-Host "║                                        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Next steps
Write-Info "Next steps:"
Write-Host ""
Write-Host "  " -NoNewline
Write-Host "1." -ForegroundColor Green -NoNewline
Write-Host " Restart Claude Code (important!)"
Write-Host "  " -NoNewline
Write-Host "2." -ForegroundColor Green -NoNewline
Write-Host " Navigate to your project directory"
Write-Host "  " -NoNewline
Write-Host "3." -ForegroundColor Green -NoNewline
Write-Host " Run the command:"
Write-Host ""
Write-Host "     /enhance-claude-md" -ForegroundColor Blue
Write-Host ""
Write-Host "  " -NoNewline
Write-Host "4." -ForegroundColor Green -NoNewline
Write-Host " Follow the interactive prompts"
Write-Host ""

# Additional information
Write-Info "Documentation:"
Write-Host ""
Write-Host "  • Quick Start:      docs\QUICK_START.md"
Write-Host "  • Installation:     docs\INSTALLATION.md"
Write-Host "  • Architecture:     docs\ARCHITECTURE.md"
Write-Host "  • Troubleshooting:  docs\TROUBLESHOOTING.md"
Write-Host ""
Write-Host "  • GitHub:           https://github.com/alirezarezvani/ClaudeForge" -ForegroundColor Blue
Write-Host ""

# Uninstall instructions
Write-Info "To uninstall, run:"
Write-Host ""
if ($scope -eq "user-level") {
    Write-Host "  Remove-Item -Recurse -Force ~\.claude\skills\claudeforge-skill"
    Write-Host "  Remove-Item -Recurse -Force ~\.claude\commands\enhance-claude-md"
    Write-Host "  Remove-Item -Force ~\.claude\agents\claude-md-guardian.md"
} else {
    Write-Host "  Remove-Item -Recurse -Force .\.claude\skills\claudeforge-skill"
    Write-Host "  Remove-Item -Recurse -Force .\.claude\commands\enhance-claude-md"
    Write-Host "  Remove-Item -Force .\.claude\agents\claude-md-guardian.md"
}
Write-Host ""

Write-Success "Thank you for installing ClaudeForge!"
Write-Host ""

# Cleanup temporary directory if remote install
if ($RemoteInstall) {
    Set-Location $env:USERPROFILE
    Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
}
