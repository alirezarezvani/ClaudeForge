"""
CLAUDE.md Content Generator

Generates new CLAUDE.md files or enhances existing ones based on templates and analysis.
Supports modular architecture with context-specific files.
"""

from typing import Dict, List, Any, Optional
from template_selector import TemplateSelector
import re


class ContentGenerator:
    """Generates and enhances CLAUDE.md files based on project context."""

    def __init__(self, project_context: Dict[str, Any]):
        """
        Initialize content generator with project context.

        Args:
            project_context: Dictionary containing project type, tech_stack, team_size, etc.
        """
        self.project_context = project_context
        self.template_selector = TemplateSelector(project_context)

    def generate_root_file(self) -> str:
        """
        Generate root CLAUDE.md file (navigation hub).

        When the surrounding project already contains ``AGENTS.md``,
        ``.cursorrules``, or ``.windsurfrules`` (passed via
        ``project_context['existing_instruction_files']``), the generated root
        file prepends ``@`` imports for them so Claude inherits their content
        instead of duplicating it.

        Returns:
            Complete CLAUDE.md content as string.
        """
        template = self.template_selector.select_template()

        if template.get('modular_recommended'):
            body = self._generate_modular_root(template)
        else:
            body = self._generate_standalone_file(template)

        return self._prepend_existing_instruction_imports(body)

    def _prepend_existing_instruction_imports(self, body: str) -> str:
        """Insert ``@`` import lines for any AGENTS.md / cursor / windsurf files."""
        existing = self.project_context.get('existing_instruction_files') or []
        supported = ('AGENTS.md', '.cursorrules', '.windsurfrules')
        imports = [name for name in supported if name in existing]
        if not imports:
            return body

        # Insert right after the intro paragraph (first blank line after the H1).
        lines = body.split('\n')
        out: List[str] = []
        inserted = False
        for i, line in enumerate(lines):
            out.append(line)
            if not inserted and i > 0 and line == '' and lines[i - 1].strip():
                out.append('## External Instructions')
                out.append('')
                out.append('Chained from sibling instruction files in this repo:')
                out.append('')
                for name in imports:
                    out.append(f"@{name}")
                out.append('')
                inserted = True
        return '\n'.join(out) if inserted else body

    def _generate_modular_root(self, template: Dict[str, Any]) -> str:
        """Generate root file for modular architecture (navigation hub)."""
        lines = []

        # Title
        lines.append("# CLAUDE.md")
        lines.append("")
        lines.append(f"This file provides top-level guidance for Claude Code when working with this {self.project_context.get('type', 'project')}.")
        lines.append("")

        # Quick Navigation
        lines.append("## Quick Navigation")
        lines.append("")
        lines.extend(self._generate_navigation_section(template))
        lines.append("")

        # Core Principles (concise, 5-7 principles)
        lines.append("## Core Principles")
        lines.append("")
        principles = self._generate_core_principles(template, max_count=5)
        lines.extend(principles)
        lines.append("")

        # Behavioral Guidelines (Karpathy principles - applied to every project)
        lines.append("## Behavioral Guidelines")
        lines.append("")
        lines.extend(self._generate_karpathy_guidelines())
        lines.append("")

        # Tech Stack (summary only)
        if self.project_context.get('tech_stack'):
            lines.append("## Tech Stack")
            lines.append("")
            lines.extend(self._generate_tech_stack_summary())
            lines.append("")

        # Key Commands/Shortcuts
        lines.append("## Quick Reference")
        lines.append("")
        lines.extend(self._generate_quick_reference())
        lines.append("")

        # Footer
        lines.append("---")
        lines.append("")
        lines.append("For detailed guidelines, see context-specific CLAUDE.md files in subdirectories.")

        return '\n'.join(lines)

    def _generate_standalone_file(self, template: Dict[str, Any]) -> str:
        """Generate standalone CLAUDE.md file (all-in-one)."""
        return self.template_selector.customize_template(template)

    def generate_context_file(self, context: str) -> str:
        """
        Generate context-specific CLAUDE.md file (e.g., backend, frontend).

        Args:
            context: Context name ('backend', 'frontend', 'database', etc.)

        Returns:
            Context-specific CLAUDE.md content with a back-link to the root
            CLAUDE.md so Claude can navigate back up the chain.
        """
        generators = {
            'backend': self._generate_backend_file,
            'frontend': self._generate_frontend_file,
            'database': self._generate_database_file,
            'docs': self._generate_docs_file,
            '.github': self._generate_github_file
        }

        generator = generators.get(context, self._generate_generic_context_file)
        body = generator()

        # Depth-aware back-link: most context dirs are one level deep, but
        # ``.github`` may sit at the repo root next to the root CLAUDE.md.
        rel_root = "../CLAUDE.md"
        backlink = (
            "> Parent context: see the root [CLAUDE.md]"
            f"({rel_root}) for project-wide guidelines and behavioural rules.\n"
            f"> Chained import: `@{rel_root}`\n\n"
        )
        return backlink + body

    def generate_rules_file(
        self,
        name: str,
        description: str,
        paths: List[str],
        body: str,
    ) -> str:
        """Emit a path-scoped ``.claude/rules/*.md`` instruction file.

        Anthropic loads these conditionally when Claude accesses files matching
        any of the ``paths:`` globs. Use this for sections that would otherwise
        bloat the root CLAUDE.md — e.g. backend-only standards that only matter
        when editing files under ``src/backend/**``.

        Args:
            name: Skill-style identifier, kebab-case (e.g. ``backend-rules``).
            description: Single-sentence summary (used by Claude for matching).
            paths: List of glob patterns that trigger the load.
            body: Markdown content (excluding frontmatter and title).

        Returns:
            Complete file content ready to write to ``.claude/rules/<name>.md``.
            Stays within the 150-line cap unless the caller passes a body that
            already exceeds it; the cap is enforced by the validator hook.
        """
        if not paths:
            raise ValueError("paths must be a non-empty list of glob patterns")

        lines: List[str] = ["---"]
        lines.append(f"name: {name}")
        lines.append(f"description: {description}")
        lines.append("paths:")
        for glob in paths:
            lines.append(f"  - {glob}")
        lines.append("---")
        lines.append("")
        lines.append(f"# {name.replace('-', ' ').title()}")
        lines.append("")
        lines.append(body.strip())
        lines.append("")
        return "\n".join(lines)

    def _generate_backend_file(self) -> str:
        """Generate backend-specific CLAUDE.md."""
        lines = []
        lines.append("# Backend Development Guidelines")
        lines.append("")
        lines.append("This file provides guidance for backend development in this project.")
        lines.append("")

        # API Design
        lines.append("## API Design")
        lines.append("")
        lines.append("- Use RESTful conventions for API endpoints")
        lines.append("- Implement proper HTTP status codes (200, 201, 400, 404, 500)")
        lines.append("- Version APIs when breaking changes are needed (/api/v1/, /api/v2/)")
        lines.append("- Document all endpoints with OpenAPI/Swagger")
        lines.append("")

        # Database Guidelines
        lines.append("## Database Operations")
        lines.append("")
        lines.append("- Use migrations for all schema changes")
        lines.append("- Implement proper indexes for query performance")
        lines.append("- Use transactions for multi-step operations")
        lines.append("- Avoid N+1 queries - use joins or batch loading")
        lines.append("")

        # Error Handling
        lines.append("## Error Handling")
        lines.append("")
        lines.append("- Implement global error handling middleware")
        lines.append("- Log errors with context (request ID, user ID, timestamp)")
        lines.append("- Return consistent error response format")
        lines.append("- Never expose stack traces to clients in production")
        lines.append("")

        # Testing
        lines.append("## Testing Requirements")
        lines.append("")
        lines.append("- Write unit tests for business logic")
        lines.append("- Write integration tests for API endpoints")
        lines.append("- Mock external services in tests")
        lines.append("- Aim for 80%+ code coverage")
        lines.append("")

        return '\n'.join(lines)

    def _generate_frontend_file(self) -> str:
        """Generate frontend-specific CLAUDE.md."""
        lines = []
        lines.append("# Frontend Development Guidelines")
        lines.append("")
        lines.append("This file provides guidance for frontend development in this project.")
        lines.append("")

        # Component Standards
        lines.append("## Component Standards")
        lines.append("")
        tech_stack = [t.lower() for t in self.project_context.get('tech_stack', [])]

        if 'react' in tech_stack:
            lines.append("- Prefer functional components with hooks over class components")
            lines.append("- Use TypeScript for type safety")
            lines.append("- Keep components small and focused (< 200 lines)")
            lines.append("- Extract reusable logic into custom hooks")
        elif 'vue' in tech_stack:
            lines.append("- Use Composition API for complex components")
            lines.append("- Keep components small and focused (< 200 lines)")
            lines.append("- Use TypeScript with Vue 3")
            lines.append("- Extract reusable logic into composables")
        else:
            lines.append("- Keep components small and focused")
            lines.append("- Extract reusable logic into utilities")
            lines.append("- Use TypeScript for type safety")
        lines.append("")

        # State Management
        lines.append("## State Management")
        lines.append("")
        lines.append("- Keep component state local when possible")
        lines.append("- Use global state only for truly shared data")
        lines.append("- Avoid prop drilling - use context/store for deep state")
        lines.append("- Document state shape and update patterns")
        lines.append("")

        # Styling
        lines.append("## Styling Guidelines")
        lines.append("")
        lines.append("- Use consistent naming conventions (BEM, CSS Modules, etc.)")
        lines.append("- Avoid inline styles except for dynamic values")
        lines.append("- Use design tokens for colors, spacing, typography")
        lines.append("- Ensure responsive design for all breakpoints")
        lines.append("")

        # Performance
        lines.append("## Performance Optimization")
        lines.append("")
        lines.append("- Lazy load routes and heavy components")
        lines.append("- Optimize images (use WebP, lazy loading)")
        lines.append("- Minimize bundle size - code split where possible")
        lines.append("- Use memoization for expensive calculations")
        lines.append("")

        return '\n'.join(lines)

    def _generate_database_file(self) -> str:
        """Generate database-specific CLAUDE.md."""
        lines = []
        lines.append("# Database Guidelines")
        lines.append("")
        lines.append("This file provides guidance for database operations and migrations.")
        lines.append("")

        # Schema Design
        lines.append("## Schema Design")
        lines.append("")
        lines.append("- Use meaningful table and column names")
        lines.append("- Always include created_at and updated_at timestamps")
        lines.append("- Use proper foreign key constraints")
        lines.append("- Add indexes for frequently queried columns")
        lines.append("")

        # Migrations
        lines.append("## Migration Guidelines")
        lines.append("")
        lines.append("- Never edit existing migrations - create new ones")
        lines.append("- Test migrations on copy of production data")
        lines.append("- Include both up and down migrations")
        lines.append("- Document breaking changes in migration comments")
        lines.append("")

        # Query Optimization
        lines.append("## Query Optimization")
        lines.append("")
        lines.append("- Use EXPLAIN to analyze slow queries")
        lines.append("- Avoid SELECT * - specify needed columns")
        lines.append("- Use appropriate JOIN types")
        lines.append("- Limit result sets with pagination")
        lines.append("")

        return '\n'.join(lines)

    def _generate_docs_file(self) -> str:
        """Generate documentation-specific CLAUDE.md."""
        lines = []
        lines.append("# Documentation Guidelines")
        lines.append("")
        lines.append("This file provides guidance for project documentation.")
        lines.append("")

        lines.append("## Documentation Standards")
        lines.append("")
        lines.append("- Keep README.md updated with setup instructions")
        lines.append("- Document all public APIs with examples")
        lines.append("- Include architecture diagrams for complex systems")
        lines.append("- Maintain changelog with semantic versioning")
        lines.append("")

        return '\n'.join(lines)

    def _generate_github_file(self) -> str:
        """Generate .github-specific CLAUDE.md for CI/CD."""
        lines = []
        lines.append("# CI/CD Workflows")
        lines.append("")
        lines.append("This file provides guidance for GitHub Actions and CI/CD processes.")
        lines.append("")

        lines.append("## Workflow Guidelines")
        lines.append("")
        lines.append("- Run linting and tests on all pull requests")
        lines.append("- Automate deployments to staging on main branch")
        lines.append("- Require manual approval for production deployments")
        lines.append("- Cache dependencies to speed up builds")
        lines.append("")

        return '\n'.join(lines)

    def _generate_generic_context_file(self) -> str:
        """Generate generic context-specific file."""
        return "# Context-Specific Guidelines\n\n[Add guidelines specific to this context]\n"

    def generate_section(self, section_name: str) -> str:
        """
        Generate a specific section for CLAUDE.md.

        Args:
            section_name: Name of section to generate

        Returns:
            Section content as string
        """
        generators = {
            'Core Principles': self._generate_core_principles_section,
            'Tech Stack': self._generate_tech_stack_section,
            'Workflow Instructions': self._generate_workflow_section,
            'Testing Requirements': self._generate_testing_section,
            'Error Handling': self._generate_error_handling_section,
            'Documentation Standards': self._generate_documentation_section
        }

        generator = generators.get(section_name, self._generate_generic_section)
        return generator(section_name)

    def _generate_core_principles_section(self, section_name: str) -> str:
        """Generate Core Principles section."""
        template = self.template_selector.select_template()
        lines = [f"## {section_name}", ""]
        lines.extend(self._generate_core_principles(template, max_count=7))
        return '\n'.join(lines)

    def _generate_tech_stack_section(self, section_name: str) -> str:
        """Generate Tech Stack section."""
        lines = [f"## {section_name}", ""]
        lines.extend(self._generate_tech_stack_summary())
        return '\n'.join(lines)

    def _generate_workflow_section(self, section_name: str) -> str:
        """Generate Workflow Instructions section."""
        lines = [f"## {section_name}", ""]

        workflows = self.project_context.get('workflows', [])
        if workflows:
            for i, workflow in enumerate(workflows, 1):
                workflow_title = workflow.replace('_', ' ').title()
                lines.append(f"{i}. **{workflow_title}**: [Add {workflow} workflow description]")
        else:
            lines.append("[Add workflow instructions specific to your project]")

        return '\n'.join(lines)

    def _generate_testing_section(self, section_name: str) -> str:
        """Generate Testing Requirements section."""
        lines = [f"## {section_name}", ""]
        lines.append("- Write tests before or alongside feature implementation")
        lines.append("- Maintain minimum 80% code coverage")
        lines.append("- Include unit, integration, and e2e tests")
        lines.append("- Mock external dependencies in tests")
        return '\n'.join(lines)

    def _generate_error_handling_section(self, section_name: str) -> str:
        """Generate Error Handling section."""
        lines = [f"## {section_name}", ""]
        lines.append("- Implement comprehensive error handling from the start")
        lines.append("- Log errors with context (user ID, request ID, timestamp)")
        lines.append("- Provide helpful error messages to users")
        lines.append("- Never expose sensitive information in error messages")
        return '\n'.join(lines)

    def _generate_documentation_section(self, section_name: str) -> str:
        """Generate Documentation Standards section."""
        lines = [f"## {section_name}", ""]
        lines.append("- Keep documentation in sync with code")
        lines.append("- Document all public APIs and interfaces")
        lines.append("- Include code examples in documentation")
        lines.append("- Update README.md with setup and usage instructions")
        return '\n'.join(lines)

    def _generate_generic_section(self, section_name: str) -> str:
        """Generate generic section placeholder."""
        return f"## {section_name}\n\n[Add {section_name.lower()} guidelines specific to your project]\n"

    def merge_with_existing(self, existing_content: str, new_sections: List[str]) -> str:
        """
        Merge new sections with existing CLAUDE.md content.

        Args:
            existing_content: Current CLAUDE.md content
            new_sections: List of new sections to add

        Returns:
            Merged content as string
        """
        lines = existing_content.split('\n')
        existing_sections = self._extract_existing_sections(existing_content)

        # Add new sections that don't already exist
        for new_section in new_sections:
            section_name = new_section.split('\n')[0].replace('## ', '')
            if section_name not in existing_sections:
                lines.append("")
                lines.append(new_section)

        # Always ensure the Karpathy behavioral guidelines section is present
        if "Behavioral Guidelines" not in existing_sections:
            lines.append("")
            lines.append("## Behavioral Guidelines")
            lines.append("")
            lines.extend(self._generate_karpathy_guidelines())

        return '\n'.join(lines)

    def _extract_existing_sections(self, content: str) -> List[str]:
        """Extract section names from existing content."""
        sections = []
        for line in content.split('\n'):
            if line.startswith('## '):
                sections.append(line[3:].strip())
        return sections

    def _generate_navigation_section(self, template: Dict[str, Any]) -> List[str]:
        """Generate navigation section for modular architecture.

        Emits both human-readable markdown links and Claude Code ``@`` imports
        so the chained CLAUDE.md files are loaded automatically when the root
        file is read.
        """
        project_type = self.project_context.get('type')
        targets: List[tuple] = []  # (label, relative_path)

        if project_type == 'fullstack':
            targets.append(("Backend Guidelines", "backend/CLAUDE.md"))
            targets.append(("Frontend Guidelines", "frontend/CLAUDE.md"))
            targets.append(("Database Operations", "database/CLAUDE.md"))

        if 'cicd' in self.project_context.get('workflows', []):
            targets.append(("CI/CD Workflows", ".github/CLAUDE.md"))

        if not targets:
            return ["- [Add links to context-specific CLAUDE.md files]"]

        lines: List[str] = []
        for label, path in targets:
            lines.append(f"- [{label}]({path})")
        lines.append("")
        lines.append("Chained context (Claude Code auto-imports these):")
        lines.append("")
        for _, path in targets:
            lines.append(f"@{path}")

        return lines

    def _generate_core_principles(self, template: Dict[str, Any], max_count: int = 7) -> List[str]:
        """Generate core principles list."""
        principles = []
        workflows = self.project_context.get('workflows', [])

        # Add workflow-based principles
        if 'tdd' in workflows:
            principles.append("1. **Test-Driven Development**: Write tests before implementation")

        # Add tech-specific principles
        tech_custom = template.get('tech_customization', {})
        for guideline in tech_custom.get('specific_guidelines', [])[:3]:
            principle_num = len(principles) + 1
            principles.append(f"{principle_num}. **{guideline.split(':')[0] if ':' in guideline else 'Guideline'}**: {guideline}")

        # Add generic essential principles
        generic = [
            "**Code Quality**: Maintain high code quality with clear, readable implementations",
            "**Documentation**: Keep documentation in sync with code changes",
            "**Error Handling**: Implement comprehensive error handling from the start",
            "**Performance**: Consider performance implications in implementation decisions",
            "**Security**: Follow security best practices and avoid common vulnerabilities"
        ]

        for principle in generic:
            if len(principles) >= max_count:
                break
            principle_num = len(principles) + 1
            principles.append(f"{principle_num}. {principle}")

        return principles

    def _generate_karpathy_guidelines(self) -> List[str]:
        """Emit the embedded Karpathy guidelines section.

        Distilled summary applied to every generated CLAUDE.md. The full skill
        text lives in the ``karpathy-guidelines`` skill installed alongside
        ClaudeForge.
        """
        return [
            "Behavioral guardrails applied to every coding, review, and refactoring task.",
            "Full skill: `~/.claude/skills/karpathy-guidelines/SKILL.md`.",
            "",
            "1. **Think before coding.** State load-bearing assumptions; if a request "
            "has multiple reasonable interpretations, surface them instead of picking "
            "silently. Stop and ask when something is genuinely unclear.",
            "2. **Simplicity first.** Write the minimum code that solves the stated "
            "problem. No speculative abstractions, no unrequested configuration, no "
            "error handling for conditions that cannot occur. If the first draft is "
            "much larger than necessary, rewrite before shipping.",
            "3. **Surgical changes.** Touch only what the task requires. Do not "
            "opportunistically reformat or refactor adjacent code, and match the "
            "surrounding style. Every changed line should trace directly to the "
            "user's request.",
            "4. **Goal-driven execution.** Convert vague requests into verifiable "
            "success criteria before coding (e.g. failing test first), and state a "
            "step-by-step plan with per-step verification for multi-step work.",
        ]

    def _generate_tech_stack_summary(self) -> List[str]:
        """Generate tech stack summary."""
        lines = []
        template = self.template_selector.select_template()
        tech_custom = template.get('tech_customization', {})

        if tech_custom.get('languages'):
            lines.append(f"- **Languages**: {', '.join(tech_custom['languages'])}")

        if tech_custom.get('frameworks'):
            lines.append(f"- **Frameworks**: {', '.join(tech_custom['frameworks'])}")

        if tech_custom.get('tools'):
            lines.append(f"- **Tools**: {', '.join(tech_custom['tools'])}")

        if not lines:
            lines.append("- [Add your tech stack details here]")

        return lines

    def _generate_quick_reference(self) -> List[str]:
        """Generate quick reference commands."""
        lines = []
        lines.append("```bash")
        lines.append("# Common development commands")
        lines.append("npm test          # Run tests")
        lines.append("npm run lint      # Run linter")
        lines.append("npm run build     # Build for production")
        lines.append("```")
        return lines
