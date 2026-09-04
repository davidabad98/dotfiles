# Personal OpenCode Rules

These rules apply across repositories. Project and nested `AGENTS.md` files
remain authoritative for repository-specific commands, architecture, security,
and ownership.

## Operating Rules

- Use the installed skills under the user's global skills directory. Load only
  skills relevant to the current phase and task.
- For non-trivial work, begin with the `plan` agent and obtain explicit user
  approval before editing.
- Read the repository's `AGENTS.md`, README, relevant tests, and current build
  commands before making changes.
- Never claim a test, build, review, commit, push, or PR happened without
  command output or an explicit external result.
- Never read, print, copy, or commit secrets, real `.env` files, private keys,
  access tokens, or credential-manager contents.
- Use the current repository's normal Git credentials. Do not invent a
  credential mechanism or add credentials to project configuration.
- Do not merge pull requests or change repository administration.
- Keep commits focused and report intentional scope and known limitations.

## Fast Path

- `/quick` is an explicit fast lane for small, clear, localized, low-risk fixes.
- A Quick Fix may proceed without a separate plan approval only when the
  requested result is unambiguous, the change is localized, behavior is obvious,
  and deterministic targeted validation exists.
- Quick Fix must stop before editing and route to `/plan` → `/build` for
  ambiguity, broad refactors, dependencies or lockfiles, authentication or
  authorization, credentials or secrets, tenant or sensitive-data boundaries,
  database migrations, public API changes, production deployment behavior,
  cross-service architecture, or repository-wide tooling/validation changes.
- Quick Fix uses a dedicated worktree when the active checkout is shared, runs
  only affected-scope checks, stages only intended files, and performs a staged
  diff/self-check. It does not invoke independent Review or Verify agents.
- The default agent remains `plan`; ordinary requests therefore retain the
  normal planning gate unless `/quick` is explicitly selected.

## Efficient Validation

- Validation is incremental. During implementation, run focused checks for the
  affected files or component; do not repeat a successful expensive check unless
  one of its relevant inputs changed.
- Review happens before final expensive verification when review findings could
  change the implementation.
- `review` owns semantic inspection of the complete staged diff. `verify` owns
  final executable evidence. `build` owns implementation and focused checks, not
  routine repository-wide validation.
- Verify must recalculate scope from the final staged paths and apply project
  and nested `AGENTS.md` rules. A denied, failed, timed-out, unavailable, or
  skipped required check blocks commit and push unless the user explicitly
  accepts a documented waiver.
- Shared, CI, Docker, environment, and validation infrastructure changes
  require validation of the affected contract. Broader verification is required
  only when the change can alter multiple components, deployment/runtime
  behavior, credentials, production state, or repository-wide semantics, and
  whenever project rules say so.
- A commit-time hook is a backstop, not a substitute for final evidence. If an
  auto-fixing hook changes files, inspect and stage the change, rerun affected
  checks, rerun `verify` against the new staged candidate, and re-review
  high-risk or production-code deltas. Never use `git commit --no-verify` to
  save time.
- Review and Verify shell access is not a sandbox. They must never request
  mutation-capable commands. Read-only Git inspection is pre-approved; Verify
  requests approval per coherent disclosed validation batch rather than before
  every shell command. `--auto` must not be used for commands that retain
  approval-gated validation or external effects.

## Lifecycle

The normal lifecycle is: `plan` clarifies and plans; `build` implements an
approved plan with focused checks; `review` performs bounded adversarial
semantic review of the staged diff; `verify` runs final applicable checks with
approval for disclosed validation batches; then `build` commits and pushes only
with complete verification evidence. The explicit `/quick` lane is the bounded
exception for eligible small fixes. Pull request creation and merge remain
explicit user or hosting-platform actions.
