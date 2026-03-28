---
name: codex-status
description: Use when the user wants a read-only status summary of codex-only workflow tasks, working-memory progress, action-item completion, test state, and related feature branches.
---

# Codex Status

This skill is the Codex-only equivalent of the Claude Code `/status` command.

## When to Use

- The user wants an overview of current task progress
- The user asks for the status of a specific task slug
- You need a read-only summary of working memory and feature branches

## Input

- Task slug: use the task slug mentioned by the user, or show all tasks if none is specified

## Process

### Step 1: List Tasks

List all task directories under:

```text
notes/working-memory/
```

### Step 2: Summarize Each Task

For each task, read and summarize:
- `task_plan.md`: current phase and completion of action items
- `progress.md`: latest log entries, test results, and next step
- `spec.md`: goal from the first line or goal section

For a specific task, read from:

```text
notes/working-memory/<task-slug>/
```

### Step 3: Check Branch Status

Check git branches for `feat/*` branches and summarize their status relative to `main`.

### Step 4: Present the Summary Table

Use this format:

```markdown
## Multi-Agent Task Status

| Task | Phase | Action Items | Tests | Branches | Next Step |
|------|-------|--------------|-------|----------|-----------|
| <slug> | Implementation | 7/10 done | 9 pass | feat/xxx, feat/yyy | Review |
```

### Step 5: Show Detailed Progress When Requested

If the user requested a specific task, show detailed progress including:
- Current phase
- Latest timestamps from `progress.md`
- Recent test outcomes
- Open blockers
- Recommended next step

## Rules

- Read-only: do not modify files
- Show timestamps from `progress.md` for context
- Prefer the latest working-memory state over memory or assumptions
- In codex-only mode, summarize native Worker progress the same way
