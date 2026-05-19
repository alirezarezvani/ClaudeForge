---
name: karpathy-guidelines
description: Behavioral guardrails for LLM-assisted coding. Use when writing, reviewing, or refactoring code in any project to avoid overcomplication, keep changes surgical, surface assumptions early, and execute against verifiable success criteria.
license: MIT
paths:
  - "**/*.py"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.go"
  - "**/*.rs"
  - "**/*.java"
  - "**/*.kt"
  - "**/*.rb"
  - "**/*.php"
  - "**/*.swift"
  - "**/*.c"
  - "**/*.cc"
  - "**/*.cpp"
  - "**/*.h"
  - "**/*.hpp"
  - "**/*.cs"
  - "**/*.scala"
  - "**/*.sh"
  - "**/*.bash"
  - "**/*.zsh"
  - "**/*.sql"
allowed-tools:
  - Read
  - Glob
  - Grep
permissions:
  allow:
    - Read
    - Glob
    - Grep
---

# Karpathy Guidelines for LLM Coding

Behavioral guardrails for code generation in Claude Code projects, distilled from observations on common LLM coding failure modes. Apply these to every editing, reviewing, and refactoring task.

> Attribution: adapted from the MIT-licensed `karpathy-guidelines` skill by Forrest Chang
> (https://github.com/forrestchang/andrej-karpathy-skills), inspired by Andrej Karpathy's
> commentary on where LLM-generated code typically goes wrong.
> ClaudeForge integrates these principles so every project initialised or enhanced through
> `/enhance-claude-md` ships with them in its CLAUDE.md.

---

## When to Apply

Apply on every non-trivial task: writing new code, editing existing code, code review, refactoring, and bug fixing. They are intentionally conservative — bias toward caution over speed.

---

## 1. Think Before Coding

Surface what is uncertain. Do not paper over confusion with plausible-sounding code.

- State assumptions before implementing; if any are load-bearing and you are not sure, ask.
- If the request admits more than one reasonable interpretation, list them rather than silently picking one.
- If a simpler approach exists than the one the user proposed, say so and explain the tradeoff.
- When something is genuinely unclear, stop. Identify what is unclear in concrete terms, then ask.

---

## 2. Simplicity First

Write the minimum code that solves the stated problem. Nothing speculative.

- Do not add features that were not requested.
- Do not introduce abstractions when there is only one call site.
- Do not add configuration knobs or extension points on speculation.
- Do not add error handling for conditions that cannot occur in this code path.
- If the first draft is 200 lines and a 50-line version would do, rewrite it before shipping.

Self-check: a senior engineer skimming this diff — would they say it is overcomplicated for what was asked? If yes, simplify.

---

## 3. Surgical Changes

Touch only what the task requires. Do not opportunistically refactor.

- Do not "improve" adjacent code, comments, or formatting that the task did not require touching.
- Do not refactor code that is working, even when you would have written it differently.
- Match the surrounding code's style and conventions, even when they differ from your defaults.
- If you notice unrelated dead code or bugs, surface them in the response — do not silently delete or fix them.

When your own changes leave orphans:

- Remove imports, variables, and helpers that your edits made unreachable.
- Do not remove pre-existing dead code unless explicitly asked.

Diff test: every changed line should be traceable to the user's request. If a line is not, drop it.

---

## 4. Goal-Driven Execution

Turn the task into a verifiable goal, then iterate until the verification passes.

- Convert vague requests into checkable success criteria before coding:
  - "Add validation" → write the failing tests for invalid inputs first, then make them pass.
  - "Fix the bug" → write a test that reproduces the bug, then make it pass.
  - "Refactor X" → confirm the existing tests pass, refactor, confirm they still pass.
- For multi-step tasks, state the plan inline with verification per step:

```
1. <step> → verify: <how you will check>
2. <step> → verify: <how you will check>
3. <step> → verify: <how you will check>
```

Strong success criteria let you loop without supervision. Vague ones ("make it work") force the user back into the loop.

---

## Integration with ClaudeForge

- The slash command `/enhance-claude-md` injects a `## Behavioral Guidelines` section into every generated or enhanced `CLAUDE.md`, summarising these four principles with a link back to this skill.
- The `claude-md-guardian` agent preserves the section across automated maintenance updates.
- `skill/generator.py` and `skill/template_selector.py` insert the section unconditionally — these principles are not opt-in.

## Effectiveness Indicators

The guidelines are working when diffs trend smaller, rewrites caused by overcomplication drop, and clarifying questions arrive before implementation rather than after a failed attempt.
