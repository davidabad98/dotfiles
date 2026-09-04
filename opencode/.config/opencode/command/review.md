---
description: Perform an independent adversarial review of the staged change
agent: review
---

Review the final staged diff against this context. If no staged diff exists,
stop and ask Build to stage the candidate. Do not run tests or quality suites;
Build owns final affected-scope checks:

$ARGUMENTS
