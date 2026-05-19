#!/usr/bin/env python3
"""ClaudeForge hook: validate every touched CLAUDE.md against the 150-line cap.

Wired into the plugin's ``hooks/hooks.json`` for both ``PostToolUse`` (after
``Edit`` or ``Write``) and ``InstructionsLoaded`` (after any of the five
``load_reason`` values fire). Reads the hook payload from stdin, extracts any
referenced file path, and exits non-zero with stderr feedback when the file
exists and exceeds the cap.

Exit codes follow the Claude Code hook contract:
- ``0``  pass
- ``2``  surface stderr to Claude as actionable feedback (do not block)
"""
from __future__ import annotations

import json
import os
import sys

MAX_LINES = 150


def _candidate_paths(payload: dict) -> list[str]:
    """Extract every file path the hook payload might be referring to.

    We accept several payload shapes so the same script works for ``PostToolUse``
    (tool_input.file_path) and ``InstructionsLoaded`` (path / file).
    """
    paths: list[str] = []

    tool_input = payload.get("tool_input") or {}
    for key in ("file_path", "path", "target_file"):
        value = tool_input.get(key)
        if isinstance(value, str):
            paths.append(value)

    for key in ("path", "file", "file_path"):
        value = payload.get(key)
        if isinstance(value, str):
            paths.append(value)

    return paths


def _is_claude_md(path: str) -> bool:
    base = os.path.basename(path)
    return base == "CLAUDE.md" or base.endswith(".claude/rules") or "/.claude/rules/" in path


def main() -> int:
    if sys.stdin.isatty():
        return 0

    raw = sys.stdin.read().strip()
    if not raw:
        return 0
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        return 0

    violations: list[tuple[str, int]] = []
    for path in _candidate_paths(payload):
        if not _is_claude_md(path) or not os.path.exists(path):
            continue
        try:
            with open(path, encoding="utf-8") as fh:
                line_count = sum(1 for _ in fh)
        except OSError:
            continue
        if line_count > MAX_LINES:
            violations.append((path, line_count))

    if not violations:
        return 0

    for path, line_count in violations:
        print(
            f"ClaudeForge: {path} is {line_count} lines (cap is {MAX_LINES}). "
            "Run /sync-claude-md to split into chained sub-files.",
            file=sys.stderr,
        )
    return 2


if __name__ == "__main__":
    sys.exit(main())
