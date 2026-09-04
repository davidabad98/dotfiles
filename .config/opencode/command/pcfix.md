---
description: Run + fix pre-commit failures (ruff/mypy/etc). Optionally commit if you pass a message.
agent: precommit-fixer
---

You are going to make this repo pass all pre-commit hooks without changing runtime behavior.

Context:
- Git status (porcelain):
!`git status --porcelain=v1`
- Staged files:
!`git diff --name-only --cached`
- Unstaged files:
!`git diff --name-only`

Instructions:
1) Run pre-commit appropriately (staged if staged files exist; otherwise --all-files).
2) Fix all failures with minimal diffs; no functional changes.
3) Re-run until clean.

Commit rule:
- If $ARGUMENTS is non-empty, treat it as the commit subject and proceed to stage + commit after checks pass.
- If $ARGUMENTS is empty, ask me for the commit subject and optional body before committing.
- Never push.
