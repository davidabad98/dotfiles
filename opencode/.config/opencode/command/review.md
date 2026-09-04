---
description: Perform an approval-gated adversarial review of the staged change
agent: review
---

Review the final staged diff against this context. If no staged diff exists,
stop and ask Build to stage the candidate. Do not run tests or quality suites;
report verification gaps for `/verify`:

$ARGUMENTS
