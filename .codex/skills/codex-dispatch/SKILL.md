---
name: codex-dispatch
description: Use when an approved task plan should be turned into isolated Codex Worker assignments with per-worktree branches, worker specs, native subagent dispatch, and progress tracking.
---

# Codex Dispatch

This skill is the Codex-only equivalent of the Claude Code `/dispatch` command.

## When to Use

- A spec and task plan have both been confirmed
- The task has parallelizable units that can be isolated safely
- Work should be split across Codex Workers running in separate git worktrees
- `framework.mode` is `codex-only`

## Input

- Plan location: use the plan path mentioned by the user, or find the most recent `notes/working-memory/*/task_plan.md`

## Process

### Step 1: Read the Plan and Spec

Read:

```text
notes/working-memory/<task-slug>/task_plan.md
notes/working-memory/<task-slug>/spec.md
```

Use both files to identify the approved scope, dependencies, and parallelization groups.

### Step 2: Determine Worker Count and Work Units

Split the plan into independent work units only when they can be implemented in parallel without blocking each other.

Worker count guidelines:
- 1 Worker: simple feature, typically fewer than 3 files
- 2 Workers: medium feature with independent components
- 3 Workers: large feature with 3 or more independent modules

Never use more than 3 Workers.

### Step 3: Create Branches, Worktrees, and Worker Specs

For each parallelization group:

1. Create a feature branch:

```text
feat/<task-slug>-<unit-name>
```

2. Create an isolated git worktree:

```bash
git worktree add ../<project>-<unit> feat/<task-slug>-<unit-name>
```

3. Write a worker spec:

```text
notes/working-memory/<task-slug>/worker-<n>-spec.md
```

4. Each worker spec must include these sections:
- `Task`
- `Branch`
- `Files`
- `Requirements`
- `Tests`
- `Constraints`
- `Interface Contract`

Use a concrete worker spec format like:

```markdown
# Worker <n> Spec: <unit-name>
## Task
## Branch
## Working Directory
## Files
## Requirements
## Tests
## Constraints
## Interface Contract
```

### Step 4: Define Interface Contracts

If any Worker produces code that other Workers will import or call, define the contract before dispatch.

Use this format:

```markdown
## Interface Contract
Other Workers may depend on this output.
Implement these exact interfaces:

- `functionName(param1: type, param2: type) -> return_type`
- `ClassName.method(param: type) -> return_type`

Expected config keys:
- `framework.mode`: `"hybrid" | "codex-only"`
- `framework.enhanced_review`: `bool`

Integration notes:
- Which files or modules will consume this interface
- What must remain stable across Workers
```

Workers that depend on cross-worker outputs must receive the interface contract in their own spec as well.

### Step 5: Present the Dispatch Plan

Before dispatch, present:
- How many Workers will run
- What each Worker owns
- Which branch each Worker uses
- Which worktree path each Worker uses

Get explicit user confirmation before dispatching.

### Step 6: Dispatch via Native Subagents

For each worker, spawn a Codex subagent using the appropriate agent config:

- Implementation tasks: use the `implementer` agent at `.codex/agents/implementer.toml`
- Analysis-only tasks: use the `analyzer` agent at `.codex/agents/analyzer.toml`
- Test-writing tasks: use the `tester` agent at `.codex/agents/tester.toml`

Each subagent receives:
- Prompt: the full content of `worker-<n>-spec.md`
- Working directory: the Worker's isolated git worktree path, such as `../<project>-<unit>`

Dispatch workers sequentially so each one starts in its own isolated worktree:

```text
Spawn implementer subagent with worker-1-spec in worktree ../project-unit1
Spawn implementer subagent with worker-2-spec in worktree ../project-unit2
Spawn tester subagent with worker-3-spec in worktree ../project-unit3
```

Do NOT run multiple Workers in the same directory.

### Step 7: Update Progress

Update:

```text
notes/working-memory/<task-slug>/progress.md
```

Record:
- Dispatch timestamp
- Worker count
- Worker assignments
- Branch names
- Worktree paths
- Expected deliverables
- Status: `DISPATCHED`

## After Workers Complete

1. Review each Worker's diff with `git diff main..<branch>`
2. Run tests across all Worker branches
3. If issues are found, describe the fixes and ask the user whether to re-dispatch or fix manually
4. If all checks pass, present results to the user for merge approval
5. Clean up worktrees with `git worktree remove ../<project>-<unit>` when appropriate
6. Do NOT push to remote without explicit user approval

## Anti-Patterns

- Never dispatch without a confirmed plan
- Never put dependent tasks in parallel Workers
- Never exceed 3 Workers
- Never reuse the same working directory for multiple Workers
- Never omit interface contracts when cross-worker dependencies exist
- Never skip the mandatory review step after Workers complete
- Workers must commit only to their assigned feature branch, never directly to main
