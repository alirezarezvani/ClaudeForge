---
name: claude-md-link-check
description: Verify every @path chain import and every markdown link inside every CLAUDE.md in this project resolves to an existing file. Read-only — returns broken links with file:line refs, never edits.
when_to_use: |
  Use when the user asks "check my CLAUDE.md links", "are the @-imports still valid?",
  "find broken cross-references", or as part of /sync-claude-md --weekly.
argument-hint: "[path-glob]"
context: fork
agent: Explore
allowed-tools:
  - Read
  - Glob
  - Grep
  - "Bash(find:*)"
  - "Bash(test:*)"
  - "Bash(ls:*)"
disable-model-invocation: false
---

# CLAUDE.md Link Check (forked, read-only)

Optional path-glob: `$ARGUMENTS` (default `.` — entire tree).

Run these steps in order. Do not modify any file.

1. **Inventory.** `find <root> -name "CLAUDE.md" -type f -not -path "*/.git/*" -not -path "*/node_modules/*"`. Also include `.claude/rules/*.md`. Record paths.
2. **Extract candidates** from each file:
   - **Chain imports** — lines matching `^@\S+`. The literal after `@` is a relative path.
   - **Markdown links** — `[text](target)` where `target` is not an HTTP(S) URL, not `mailto:`, not a bare anchor `#section`.
3. **Resolve each candidate** relative to the file containing it (use `Read` on the parent file to confirm position, then `test -e <resolved-path>` or `Glob`).
   - For `@../CLAUDE.md` inside `skill/CLAUDE.md`, resolved path is `CLAUDE.md`.
   - For `[Backend](backend/CLAUDE.md)` inside the root, resolved path is `backend/CLAUDE.md`.
4. **Return** the report in this exact shape:

```
## Link Check

Files inspected: <count>
References checked: <chain_imports> @-imports, <md_links> markdown links

### Broken
- <file>:<line> — `<original-target>` → does not resolve (expected `<absolute-path>`)
- ... (omit section if empty)

### Clean
<count> references resolved.
```

5. If everything resolves, return exactly `## Link Check\n\nAll <N> references resolved across <M> files.`. Do not pad.

**Hard rule**: never invent a fix. Report the broken target verbatim. Repair is the user's call (or `/sync-claude-md`'s).
