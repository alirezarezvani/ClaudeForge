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

DEFAULT_MAX_LINES = 150
DEFAULT_EXEMPT_SUFFIX = ".local.md"
DEFAULT_VIOLATION_RC = 2


def _load_config() -> dict:
    """Merge ``hooks-config.json`` and optional ``hooks-config.local.json``.

    Local file overrides the shared one key-by-key inside ``validateClaudeMd``.
    Missing files are silently ignored — the script falls back to defaults.
    """
    here = os.path.dirname(os.path.abspath(__file__))
    shared = os.path.join(here, "hooks-config.json")
    local = os.path.join(here, "hooks-config.local.json")
    cfg: dict = {}
    for path in (shared, local):
        if not os.path.exists(path):
            continue
        try:
            with open(path, encoding="utf-8") as fh:
                data = json.load(fh)
        except (OSError, json.JSONDecodeError):
            continue
        validate_block = data.get("validateClaudeMd") or {}
        cfg.update(validate_block)
    return cfg


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


def _is_claude_md(path: str, exempt_suffix: str) -> bool:
    base = os.path.basename(path)
    # Personal-tier overrides (CLAUDE.local.md and any matching suffix) are
    # exempt from the cap — they live outside the chained team-shared tree.
    if base.endswith(exempt_suffix):
        return False
    return base == "CLAUDE.md" or "/.claude/rules/" in path


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

    cfg = _load_config()
    if cfg.get("enabled") is False:
        return 0
    max_lines = int(cfg.get("maxLines", DEFAULT_MAX_LINES))
    exempt_suffix = str(cfg.get("exemptFilenameSuffix", DEFAULT_EXEMPT_SUFFIX))
    violation_rc = int(cfg.get("exitCodeOnViolation", DEFAULT_VIOLATION_RC))

    violations: list[tuple[str, int]] = []
    for path in _candidate_paths(payload):
        if not _is_claude_md(path, exempt_suffix) or not os.path.exists(path):
            continue
        try:
            with open(path, encoding="utf-8") as fh:
                line_count = sum(1 for _ in fh)
        except OSError:
            continue
        if line_count > max_lines:
            violations.append((path, line_count))

    if not violations:
        return 0

    for path, line_count in violations:
        print(
            f"ClaudeForge: {path} is {line_count} lines (cap is {max_lines}). "
            "Run /sync-claude-md to split into chained sub-files.",
            file=sys.stderr,
        )
    return violation_rc


if __name__ == "__main__":
    sys.exit(main())
