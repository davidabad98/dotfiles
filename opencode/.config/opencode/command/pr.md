---
description: Create a Bitbucket pull request from an already reviewed and pushed branch
agent: pr
---

The branch has already passed independent Review and final checks and has been
pushed using normal Git credentials. Create the Bitbucket pull request using the
local `bitbucket-pr create` helper. First run
`bitbucket-pr auth check --non-interactive`; if it fails, stop and tell the user
to run `bitbucket-pr auth check` in an interactive terminal before retrying.
Never invoke interactive credential resolution from OpenCode. Prepare the title,
summary, verification evidence, affected paths, required reviewers, risks, and
merge checklist for:

$ARGUMENTS

Do not edit, stage, commit, push, approve, decline, merge, or change repository
settings. Do not configure or display credentials.
