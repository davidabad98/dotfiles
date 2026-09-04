---
description: Run and fix pre-commit failures without committing
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
- Never commit or push. Return control to Build after checks pass.
