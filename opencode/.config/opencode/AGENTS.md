# Personal OpenCode Rules

These rules apply across repositories. Project and nested `AGENTS.md` files
remain authoritative for repository-specific commands, architecture, security,
and ownership.

## Operating Rules

* Use the installed skills under the user's global skills directory. Load only
  skills relevant to the current phase and task.
* For non-trivial work, begin with the `plan` agent and obtain explicit user
  approval before editing.
* Follow all applicable repository and nested `AGENTS.md` instructions. Read the
  README, relevant tests, and current build commands before making changes.
* Never claim a test, build, review, commit, push, or PR happened without
  command output or an explicit external result.
* Never read, print, copy, or commit secrets, real `.env` files, private keys,
  access tokens, or credential-manager contents.
* Use the current repository's normal Git credentials. Do not invent a
  credential mechanism or add credentials to project configuration.
* Agents may create a pull request after Review and final checks pass by using
  the local `bitbucket-pr create` helper. Agents must not approve, decline, or
  merge pull requests or change repository administration.
* Credential preflights from OpenCode must use
  `bitbucket-pr auth check --non-interactive`. If it fails, stop and tell the
  user to run `bitbucket-pr auth check` in an interactive terminal; never open
  or work around a pinentry prompt from OpenCode. `bitbucket-pr create` must
  also fail without prompting if its GPG credential is unavailable.
* Keep commits focused and report intentional scope and known limitations.

## Fast Path

* `/quick` is an explicit fast lane for small, clear, localized, low-risk fixes.
* Use Quick Fix only when the requested result is unambiguous, the change is
  localized, behavior is obvious, and deterministic targeted validation exists.
  Otherwise route to `/plan` → `/build`.
* The default agent remains `plan`; ordinary requests therefore retain the
  normal planning gate unless `/quick` is explicitly selected.

## Efficient Validation

* Validation is incremental. During implementation, run focused checks for the
  affected files or component; do not repeat a successful expensive check unless
  one of its relevant inputs changed.
* A denied, failed, timed-out, unavailable, or skipped required check blocks
  commit and push unless the user explicitly accepts a documented waiver.
* Shared, CI, Docker, environment, and validation infrastructure changes
  require validation of the affected contract. Broader verification is required
  only when the change can alter multiple components, deployment/runtime
  behavior, credentials, production state, or repository-wide semantics, and
  whenever project rules say so.
* A commit-time hook is a backstop, not a substitute for final evidence. If an
  auto-fixing hook changes files, inspect and stage the change and rerun affected
  checks. Never use `git commit --no-verify` to save time.

## Lifecycle

The normal lifecycle is: `plan` clarifies and plans; one explicit approval of
the bounded plan authorizes `build` to implement the scope in an isolated
repository-local worktree, invoke independent `review`, run final applicable
checks, commit and push the feature branch, and create the pull request.
Detailed implementation, review, remediation, synchronization, and delivery
rules belong to their respective agents.

Approval is required only for ambiguous requirements, material scope changes,
credentials or secrets, sensitive external effects, destructive operations,
force-push, merge, repository administration, or a persistent failure requiring
a waiver. The explicit `/quick` lane is the bounded exception for eligible
small fixes. Pull request creation is an automated post-review delivery step;
merge and repository administration remain protected user or hosting-platform
actions.
