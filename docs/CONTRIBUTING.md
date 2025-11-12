# Contributing to ClaudeForge

Thank you for your interest in contributing to ClaudeForge! This guide will help you get started.

---

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](../.github/CODE_OF_CONDUCT.md).

---

## How Can I Contribute?

### 1. Reporting Bugs

**Before submitting a bug report:**
- Check existing issues to avoid duplicates
- Collect information about the bug
- Test with the latest version

**Submit a bug report:**
- Use the bug report template
- Provide clear title and description
- Include steps to reproduce
- Add relevant logs or screenshots
- Mention your environment (OS, Claude Code version)

**Template:** https://github.com/alirezarezvani/ClaudeForge/issues/new?template=bug_report.md

---

### 2. Suggesting Enhancements

**Before submitting:**
- Check if the feature already exists
- Review planned features in CHANGELOG.md
- Consider if it fits project scope

**Submit an enhancement:**
- Use the feature request template
- Explain the use case
- Describe proposed solution
- Consider alternatives

**Template:** https://github.com/alirezarezvani/ClaudeForge/issues/new?template=feature_request.md

---

### 3. Contributing Code

#### Quick Start

```bash
# Fork the repository
# Clone your fork
git clone https://github.com/YOUR-USERNAME/ClaudeForge.git
cd ClaudeForge

# Create a branch
git checkout -b feature/amazing-feature

# Make your changes
# Test your changes
./install.sh  # Test installation
/enhance-claude-md  # Test in Claude Code

# Commit your changes
git commit -m "Add amazing feature"

# Push to your fork
git push origin feature/amazing-feature

# Open a Pull Request
```

#### Development Setup

```bash
# Install development dependencies
# (None required - Python standard library only)

# Test Python modules
python3 -c "from skill.analyzer import CLAUDEMDAnalyzer; print('OK')"

# Test installation scripts
./install.sh
# Choose option 2 (project-level) for testing
```

---

## Development Guidelines

### Python Code Style

**Follow PEP 8:**
```python
# Good
def analyze_file(self, content: str) -> Dict[str, Any]:
    """Analyze CLAUDE.md file content."""
    pass

# Bad
def analyzeFile(self,content):
    pass
```

**Type Hints:**
```python
# Always use type hints
def calculate_score(sections: List[str]) → int:
    return len(sections) * 10
```

**Docstrings:**
```python
def validate_length(self, content: str) -> bool:
    """
    Validate CLAUDE.md file length.

    Args:
        content: File content as string

    Returns:
        True if length is valid, False otherwise
    """
    pass
```

---

### Markdown Style

**Headings:**
```markdown
# H1 - Document title
## H2 - Main sections
### H3 - Subsections
```

**Code Blocks:**
```markdown
```bash
# Use language-specific syntax highlighting
command here
```
```

**Links:**
```markdown
# Prefer relative links for internal docs
[Architecture](ARCHITECTURE.md)

# Use absolute URLs for external
[GitHub](https://github.com/alirezarezvani/ClaudeForge)
```

---

### Testing Your Changes

#### Test Python Modules

```bash
# Test analyzer
python3 << EOF
from skill.analyzer import CLAUDEMDAnalyzer
content = open('test-CLAUDE.md').read()
analyzer = CLAUDEMDAnalyzer(content)
report = analyzer.analyze_file()
print(f"Quality Score: {report['quality_score']}")
EOF
```

#### Test Installation

```bash
# Test install.sh
./install.sh
# Choose option 2 (project-level)
# Verify all components copied correctly

# Test uninstall
rm -rf ./.claude
```

#### Test in Claude Code

```bash
# Install your changes
./install.sh

# Restart Claude Code

# Test slash command
/enhance-claude-md

# Verify output matches expected behavior
```

---

## Contribution Areas

### 1. Adding New Templates

**Location:** `skill/examples/`

**Steps:**
1. Create new template file (e.g., `rust-cli-CLAUDE.md`)
2. Follow native format structure
3. Update `skill/examples/README.md`
4. Update `template_selector.py` detection logic
5. Add test case to `sample_input.json`

**Example:**
```bash
# Create Rust template
vim skill/examples/rust-cli-CLAUDE.md

# Update selector
vim skill/template_selector.py
# Add: if 'Cargo.toml' in files: return 'rust-cli'

# Test
# Create test Rust project, run /enhance-claude-md
```

---

### 2. Improving Detection Logic

**Location:** `skill/workflow.py`

**Methods to enhance:**
- `_detect_project_type()`
- `_detect_tech_stack()`
- `_estimate_team_size()`
- `_detect_development_phase()`

**Example:**
```python
# Add Flutter detection
def _detect_project_type(self, results):
    files = results.get('files', [])

    # Add Flutter check
    if 'pubspec.yaml' in files:
        return 'mobile'

    # ... existing logic
```

---

### 3. Enhancing Quality Scoring

**Location:** `skill/analyzer.py`

**Method:** `calculate_quality_score()`

**Ideas:**
- Add more granular checks
- Weight sections by importance
- Detect project-specific customization

**Example:**
```python
def calculate_quality_score(self) -> int:
    score = 0

    # Add new check: Has examples
    if self._has_code_examples():
        score += 5  # Bonus points

    # ... existing logic
    return min(score, 100)
```

---

### 4. Adding New Validation Rules

**Location:** `skill/validator.py`

**Steps:**
1. Add new validation method
2. Call from `validate_all()`
3. Return standard validation result

**Example:**
```python
def validate_examples(self) -> Dict[str, Any]:
    """Validate code examples are present."""
    code_blocks = re.findall(r'```.*?```', self.content, re.DOTALL)

    return {
        'passed': len(code_blocks) >= 3,
        'message': 'At least 3 code examples required',
        'severity': 'low'
    }
```

---

### 5. Documentation Improvements

**Areas:**
- Fix typos or unclear explanations
- Add missing examples
- Improve installation instructions
- Translate to other languages (future)

**Process:**
1. Edit markdown files in `docs/`
2. Test markdown rendering locally
3. Submit pull request

---

## Pull Request Process

### 1. Before Submitting

- [ ] Code follows project style guidelines
- [ ] All tests pass (manual testing required)
- [ ] Documentation updated if needed
- [ ] CHANGELOG.md updated with your changes
- [ ] Commit messages are clear and descriptive

### 2. Submitting

1. **Create Pull Request** from your fork
2. **Fill out PR template** completely
3. **Link related issues** (if any)
4. **Request review** from maintainers
5. **Respond to feedback** promptly

### 3. After Submission

- **CI checks** will run automatically
- **Maintainers** will review your code
- **Address feedback** by pushing new commits
- **Don't force-push** after review started
- **Be patient** - reviews may take a few days

### 4. Merging

Once approved:
- Maintainer will merge your PR
- Your contribution will be in the next release
- You'll be added to contributors list

---

## Commit Message Guidelines

### Format

```
type(scope): Short description

Longer description if needed.

Fixes #123
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (no logic change)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### Examples

```
feat(analyzer): Add code example detection

Adds check for code examples in CLAUDE.md files.
Contributes to quality score calculation.

Fixes #45
```

```
fix(installer): Resolve Windows path issues

Fixes path separator issues on Windows platforms.
Updates install.ps1 to use platform-specific paths.

Fixes #67
```

```
docs(quick-start): Clarify installation steps

Adds more detailed explanations for each step.
Includes troubleshooting for common issues.
```

---

## Release Process

(For maintainers)

### Version Numbering

Follow Semantic Versioning (MAJOR.MINOR.PATCH):
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

### Release Checklist

1. **Update version:**
   - `CHANGELOG.md` - Add new version section
   - `README.md` - Update version badge
   - `skill/SKILL.md` - Update version footer

2. **Create release:**
   ```bash
   git tag -a v1.1.0 -m "Release v1.1.0"
   git push origin v1.1.0
   ```

3. **GitHub Release:**
   - Create release from tag
   - Copy CHANGELOG excerpt to description
   - Attach any binaries if needed

4. **Announce:**
   - GitHub Discussions
   - Social media (if applicable)
   - Update documentation site

---

## Community

### Getting Help

- **GitHub Discussions:** Ask questions, share ideas
- **GitHub Issues:** Report bugs, request features
- **Documentation:** Comprehensive guides in `docs/`

### Staying Updated

- **Watch Repository:** Get notifications for releases
- **Star Repository:** Show support, stay informed
- **Follow Updates:** Check CHANGELOG.md for changes

---

## Recognition

Contributors are recognized in:
- **README.md** - Contributors section
- **CHANGELOG.md** - Version-specific contributors
- **GitHub** - Automatic contributors graph

Every contribution matters, from code to documentation to bug reports!

---

## Questions?

- **General Questions:** GitHub Discussions
- **Bug Reports:** GitHub Issues
- **Security Issues:** Email maintainers directly (see SECURITY.md if created)
- **Feature Requests:** GitHub Issues with feature template

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

See [LICENSE](../LICENSE) for details.

---

**Thank you for contributing to ClaudeForge!** 🎉

Your contributions help make CLAUDE.md management better for everyone in the Claude Code community.
