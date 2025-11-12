# Integration Examples

Integrating ClaudeForge with CI/CD and development workflows.

---

## GitHub Actions Integration

**`.github/workflows/validate-claude-md.yml`:**
```yaml
name: Validate CLAUDE.md

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install ClaudeForge
        run: |
          curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.sh | bash
          export PATH="$HOME/.claude/bin:$PATH"

      - name: Validate CLAUDE.md
        run: |
          # Check file exists
          test -f CLAUDE.md || exit 1

          # Check minimum quality (requires Python validation)
          python3 -c "
          from skill.validator import BestPracticesValidator
          content = open('CLAUDE.md').read()
          validator = BestPracticesValidator(content)
          results = validator.validate_all()
          passed = sum(1 for r in results if r['passed'])
          if passed < 4:
              print(f'Quality check failed: {passed}/5 checks passed')
              exit(1)
          print(f'Quality check passed: {passed}/5 checks')
          "
```

---

## Pre-Commit Hook

**`.claude/hooks/pre-commit.sh`:**
```bash
#!/bin/bash
# Validate CLAUDE.md before commit

if [ -f "CLAUDE.md" ]; then
    echo "Validating CLAUDE.md..."

    # Check file length
    lines=$(wc -l < CLAUDE.md)
    if [ $lines -lt 20 ] || [ $lines -gt 400 ]; then
        echo "Error: CLAUDE.md length ($lines lines) outside recommended range (20-300)"
        exit 1
    fi

    # Check required sections
    for section in "Core Principles" "Tech Stack" "Workflow"; do
        if ! grep -q "$section" CLAUDE.md; then
            echo "Error: Missing required section: $section"
            exit 1
        fi
    done

    echo "✅ CLAUDE.md validation passed"
fi
```

**Setup:**
```bash
chmod +x .claude/hooks/pre-commit.sh
git config core.hooksPath .claude/hooks
```

---

## Package.json Scripts

**`package.json`:**
```json
{
  "scripts": {
    "validate:claude": "python3 -m skill.validator CLAUDE.md",
    "update:claude": "echo 'Run: /enhance-claude-md in Claude Code'",
    "precommit": "./.claude/hooks/pre-commit.sh"
  }
}
```

**Usage:**
```bash
npm run validate:claude  # Check CLAUDE.md quality
```

---

## Team Onboarding Automation

**`scripts/onboard-developer.sh`:**
```bash
#!/bin/bash
# Onboard new developer with ClaudeForge

echo "Setting up ClaudeForge for new team member..."

# Install ClaudeForge
curl -fsSL https://raw.githubusercontent.com/alirezarezvani/ClaudeForge/main/install.sh | bash

# Verify CLAUDE.md exists
if [ ! -f "CLAUDE.md" ]; then
    echo "No CLAUDE.md found. Run /enhance-claude-md in Claude Code to create one."
fi

echo "✅ ClaudeForge installed. Restart Claude Code to use."
```

---

## CI/CD Pipeline Integration

**GitLab CI (`.gitlab-ci.yml`):**
```yaml
validate_claude:
  stage: validate
  script:
    - python3 -c "import sys; sys.path.insert(0, 'skill'); from validator import BestPracticesValidator; v = BestPracticesValidator(open('CLAUDE.md').read()); results = v.validate_all(); sys.exit(0 if all(r['passed'] for r in results) else 1)"
  only:
    - merge_requests
```

---

See also:
- [basic-usage.md](basic-usage.md)
- [modular-setup.md](modular-setup.md)
