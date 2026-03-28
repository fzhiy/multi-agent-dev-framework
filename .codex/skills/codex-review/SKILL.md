---
name: codex-review
description: Use when completed Codex Worker branches need structured review, reviewer subagent evaluation, optional enhanced codex-review review, and approval or change-request decisions before merge.
---

# Codex Review

This skill is the Codex-only equivalent of the Claude Code `/review-workers` command.

## When to Use

- One or more Worker branches have completed implementation
- The task needs structured approval or change requests before merge
- A fresh-eyes review is required against the original worker specs
- `framework.mode` is `codex-only`

## Input

- Task slug: use the task slug mentioned by the user, or find the most recent task under `notes/working-memory/`

## Review Process

### Step 1: Read Task Context

Read:

```text
notes/working-memory/<task-slug>/task_plan.md
notes/working-memory/<task-slug>/worker-<n>-spec.md
notes/working-memory/<task-slug>/progress.md
```

Use these files to determine expected branch names, scope, tests, and prior review history.

### Step 2: Review Each Worker Branch

For each Worker's feature branch:

1. Generate the diff:

```bash
git diff main..<branch>
```

2. Check:
- Does the implementation match the worker spec?
- Are there hardcoded paths?
- Are there credentials or sensitive data?
- Are interface contracts respected?

3. Run tests if the branch defines or touches them.

### Step 3: Default Review via Reviewer Subagent

For each Worker, spawn a `reviewer` subagent using the expected config:

```text
.codex/agents/reviewer.toml
```

The reviewer receives:
- The diff content
- The original `worker-<n>-spec.md`
- No broader implementation context beyond the diff and the spec

The reviewer must use its mandatory 8-point checklist. At minimum, the checklist must cover:
- Requirement correctness
- Scope compliance
- Interface contract compliance
- Regression risk
- Test adequacy
- Security and sensitive data handling
- Hardcoded path and config hygiene
- Code quality and maintainability

Collect a reviewer verdict of `APPROVED` or `CHANGES_REQUESTED` with specific issues.

### Step 4: Optional Enhanced Review

If `codex.toml` has:

```toml
[framework]
enhanced_review = true
```

and the `codex-review` review server is available, trigger a second-round review:

```text
mcp__codex-review__review_start(prompt=<diff + spec summary>)
```

Combine findings from the reviewer subagent and the enhanced review before deciding status.

### Step 5: Present Findings

Present results in this format:

```markdown
## Worker Review Summary

### Worker 1 (feat/xxx)
- Status: APPROVED / CHANGES_REQUESTED
- Tests: X passed, Y failed
- Issues: [list]

### Worker 2 (feat/yyy)
- Status: APPROVED / CHANGES_REQUESTED
- Tests: X passed, Y failed
- Issues: [list]
```

### Step 6: Decide Next Action

If any Worker is `CHANGES_REQUESTED`:
- Write a fix spec
- Ask the user whether to re-dispatch the Worker or fix manually

If all Workers are `APPROVED`:
- Ask the user whether to merge to `main`
- Only merge after explicit approval

### Step 7: Update Progress

Document all review findings in:

```text
notes/working-memory/<task-slug>/progress.md
```

Include timestamps, reviewer verdicts, test results, and next step.

## Rules

- Never merge without user approval
- Never push to remote without user approval
- Document all review findings in `progress.md`
- Max 3 review iterations per Worker before escalating to the user
- Treat reviewer findings as the default decision path unless the user overrides
