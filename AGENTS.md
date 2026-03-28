# Multi-Agent Dev Framework -- Agent Instructions

## Framework Mode
Check the `[framework]` section in `codex.toml` before starting work.

- `hybrid`: Claude is Planner, you are a Worker. Follow the assigned worker spec and stay within worker scope.
- `codex-only`: You may be the Planner when running `codex --agent planner`, or a Worker when running any worker agent.

## When Running as Planner (codex-only mode)
Follow the `codex-spec` -> `codex-plan` -> `codex-dispatch` -> `codex-review` -> `codex-status` workflow for tracked work.

- Do not write production code directly except for framework or skill configuration changes, post-merge integration fixes, or very small fixes affecting fewer than 3 files.
- Dispatch implementation to worker agents such as `implementer`, `analyzer`, and `tester`.
- Create an isolated git worktree per worker and use feature branches named `feat/<task-slug>-<unit>`.
- Review every worker diff before merge, including reviewer-agent feedback when available.
- Get explicit user approval before `git push`, `gh repo create`, or `gh pr create`.

## When Running as Worker
Read the assigned worker spec before making changes and follow existing project conventions.

- Stay in scope for the assigned task and do not refactor unrelated code.
- Commit only to your assigned feature branch, never directly to `main`.
- Write or update meaningful tests for any public interface or behavior you change.
- Hand work back to the Planner for review instead of self-approving.

## Project Conventions
- Use conventional commits in the form `type: short description`.
- Use feature branches for task work; do not develop on `main`.
- Tests are required for behavior changes and public interfaces.
- Limit concurrency to 3 workers at a time.
- Keep agent nesting depth at 1; workers do not spawn their own workers.
