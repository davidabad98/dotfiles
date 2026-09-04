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
- Repository-wide or high-cost checks are required for repository-wide,
  shared-package, dependency/lockfile, CI, Docker/Compose, environment,
  validation-script, authentication, authorization, tenant/data, migration,
  public-interface, or cross-service changes, and whenever project rules say so.
- A commit-time hook is a backstop, not a substitute for final evidence. If an
  auto-fixing hook changes files, inspect and stage the change, rerun affected
  checks, rerun `verify` against the new staged candidate, and re-review
  high-risk or production-code deltas. Never use `git commit --no-verify` to
  save time.
- Approval-gated shell access for `review` and `verify` is not a sandbox. They
  must never request mutation-capable commands, and `--auto` must not be used
  when their shell permission is `ask`.

## Lifecycle

The effective lifecycle is: `plan` clarifies and plans; `build` implements an
approved plan with focused checks; `review` performs bounded adversarial
semantic review of the staged diff; `verify` runs final applicable checks with
approval for shell execution; then `build` commits and pushes only with complete
verification evidence. Pull request creation and merge remain explicit user or
hosting-platform actions.
