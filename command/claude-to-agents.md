---
description: Convert the project's CLAUDE.md (and chained sub-files) into an AGENTS.md for Codex / Gemini Code Assist / other tools that follow the AGENTS.md convention. Three modes — symlink for one source of truth, copy for a snapshot, inline-chain for a self-contained flat file that doesn't depend on @-import resolution.
argument-hint: "[--symlink | --copy | --inline-chain] [--force]"
when_to_use: |
  Use when the user asks "make an AGENTS.md", "support codex", "support gemini",
  "convert CLAUDE.md", "share my instructions with non-Claude tools", or when
  adopting ClaudeForge in a repo that already has cross-tool contributors.
allowed-tools:
  - Read
  - Write
  - Glob
  - "Bash(python3:*)"
  - "Bash(ls:*)"
  - "Bash(test:*)"
  - "Bash(readlink:*)"
disallowedTools:
  - WebFetch
  - WebSearch
permissions:
  allow:
    - Read
    - Write
    - Glob
    - "Bash(python3:*)"
    - "Bash(ls:*)"
    - "Bash(test:*)"
    - "Bash(readlink:*)"
---

# /claude-to-agents — convert CLAUDE.md → AGENTS.md

Wraps `hooks/claude-to-agents.py` so non-Claude tools (OpenAI Codex, Gemini Code Assist, anything else honouring the `AGENTS.md` convention) can read the same instructions as Claude.

## Mode selection

Decide first by asking which guarantee the user wants:

- **`--symlink`** (default on macOS / Linux): `AGENTS.md` becomes a symlink to `CLAUDE.md`. One source of truth — edits to CLAUDE.md show up in AGENTS.md instantly. Codex/Gemini read it transparently. On Windows the script falls back to `--copy` and prints a notice.
- **`--copy`**: byte-for-byte snapshot. Use when the user wants to fork the instructions for non-Claude tooling (Codex/Gemini reading a different policy) or when their VCS / build pipeline doesn't follow symlinks.
- **`--inline-chain`**: walk every `@path/.../CLAUDE.md` chain import recursively and write a single flat AGENTS.md with all sub-file content inlined. **Recommended for Codex/Gemini in modular projects** — those tools don't resolve `@`-imports, so without inlining they'd only see the root file.

If the user is silent on mode, default to `--symlink` for simple projects and recommend `--inline-chain` for projects with > 1 CLAUDE.md (run `find . -name CLAUDE.md -type f -not -path '*/.git/*' -not -path '*/node_modules/*' | wc -l` first to decide).

## Execution

1. **Pre-flight.** `test -f CLAUDE.md` — if missing, tell the user `/enhance-claude-md` is the right command first.
2. **Run the script** with the chosen flags from the repo root:
   ```bash
   python3 "${CLAUDE_PLUGIN_ROOT:-${CLAUDE_PROJECT_DIR:-.}}/hooks/claude-to-agents.py" --mode <mode>
   ```
3. **Report.** Echo whether AGENTS.md was created or backed up, its size, and which mode produced it.
4. **Verify** the result:
   - For `--symlink`: `readlink AGENTS.md` should print `CLAUDE.md`.
   - For `--copy`: `diff -q CLAUDE.md AGENTS.md` should return clean.
   - For `--inline-chain`: AGENTS.md must contain content from every chained sub-file; the script strips backlinks and `@`-import lines automatically.

## Safety

- An existing `AGENTS.md` is renamed to `AGENTS.md.backup.<UTC-timestamp>` before overwrite. Pass `--force` to skip the backup (destructive).
- The script never writes outside the current directory tree.
- Read-only modes (`--symlink`) leave CLAUDE.md untouched.
