---
description: Create a session summary file (YYYYMMDD_NN_title_slug.md) in docs/session_summaries/
agent: session-summarizer
---

Create a session summary file for this session.

Title (may be empty): $ARGUMENTS

Repo context:
- Branch: !git rev-parse --abbrev-ref HEAD
- Status: !git status --porcelain
- Diffstat: !git diff --stat
- Recent commits: !git log -10 --oneline --decorate
