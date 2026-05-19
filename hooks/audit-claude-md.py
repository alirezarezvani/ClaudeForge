#!/usr/bin/env python3
"""ClaudeForge Stop hook: print a 1-line CLAUDE.md health summary.

Walks the project tree from ``CLAUDE_PROJECT_DIR`` (or the cwd) and prints a
single line to stderr summarising how many CLAUDE.md files exist, how close
they are to the 150-line cap, and whether any are over. Designed to be the
last signal before a session's context is lost — drift visible to the user
without forcing them to run ``/sync-claude-md`` blindly.

Honours ``hooks/hooks-config.json`` and ``hooks/hooks-config.local.json``:
when ``stopAuditLine.enabled`` is ``false``, this script exits silently.
"""
from __future__ import annotations

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_MAX_LINES = 150


def _load_config() -> dict:
    cfg: dict = {}
    for name in ("hooks-config.json", "hooks-config.local.json"):
        path = os.path.join(HERE, name)
        if not os.path.exists(path):
            continue
        try:
            with open(path, encoding="utf-8") as fh:
                data = json.load(fh)
        except (OSError, json.JSONDecodeError):
            continue
        cfg.update(data.get("stopAuditLine") or {})
        cfg.setdefault("maxLines", (data.get("validateClaudeMd") or {}).get("maxLines"))
    return cfg


def _project_root() -> str:
    return os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()


def _iter_claude_md(root: str):
    skip_dirs = {".git", "node_modules", ".venv", "venv", "dist", "build", "vendor"}
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        for name in filenames:
            if name == "CLAUDE.md":
                yield os.path.join(dirpath, name)


def main() -> int:
    cfg = _load_config()
    if cfg.get("enabled") is False:
        return 0
    cap = int(cfg.get("maxLines") or DEFAULT_MAX_LINES)
    warn_at = max(1, int(cap * 0.8))

    total = 0
    over = 0
    near = 0
    for path in _iter_claude_md(_project_root()):
        try:
            with open(path, encoding="utf-8") as fh:
                lines = sum(1 for _ in fh)
        except OSError:
            continue
        total += 1
        if lines > cap:
            over += 1
        elif lines >= warn_at:
            near += 1

    if total == 0:
        return 0

    suffix = ""
    if over:
        suffix = f" — {over} OVER {cap}-line cap; run /sync-claude-md"
    elif near:
        suffix = f" — {near} near cap ({warn_at}+)"
    print(f"ClaudeForge: {total} CLAUDE.md tracked{suffix}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
