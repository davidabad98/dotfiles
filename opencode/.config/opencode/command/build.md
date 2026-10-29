---
description: Implement an approved plan with review, final checks, commit, and push
agent: build
---

Implement only the approved plan below. Use focused checks during
implementation, request independent Review before final affected-scope checks,
and commit/push/create the pull request only after Review and all applicable
checks pass. Create the pull request with `bitbucket-pr create` only after the
Review agent reports no actionable findings. Immediately before PR creation,
run `bitbucket-pr auth check --non-interactive`. If it fails, stop and tell the
user to run `bitbucket-pr auth check` in an interactive terminal before
resuming. Never invoke interactive credential resolution from OpenCode. If
approval is not explicit or the current checkout is not an isolated feature
worktree, stop.

$ARGUMENTS
