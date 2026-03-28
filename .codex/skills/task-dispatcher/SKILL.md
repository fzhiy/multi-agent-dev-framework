---
name: task-dispatcher
description: Use after a spec and plan are ready to dispatch implementation tasks to Codex Workers via MCP. Reads the task plan, identifies parallelizable work units, determines worker count and agent config, creates feature branches, and generates MCP dispatch commands. This is the bridge between Claude planning and Codex execution.
---

# Task Dispatcher

Bridge between Claude (Planner) and Codex Workers (Implementers). Transforms a task plan into parallel Worker assignments.

## When to Use

- After `requirement-spec` has produced a confirmed spec
- After the plan has been reviewed and approved
- Before any implementation begins
- When you need to decide how many Workers to use and what each does

## Process

### Step 1: Read the Plan

Read the spec and task plan:
```
notes/working-memory/<task-slug>/spec.md
notes/working-memory/<task-slug>/task_plan.md
```

### Step 2: Identify Work Units

Decompose the plan into independent, parallelizable work units. Each unit must be:
- **Self-contained**: A Worker can complete it without depending on another Worker's output
- **Atomic**: One clear deliverable (a file, a module, a test suite)
- **Testable**: Has a verification command or acceptance check

If tasks have dependencies, mark the dependency chain and dispatch sequentially.

### Step 3: Determine Worker Configuration

For each work unit, decide:

| Factor | Decision |
|--------|----------|
| Complexity | High → `gpt-5.4` / Low → `gpt-5.4-mini` |
| Write needed? | Yes → `write-allow` / No → `read-only` |
| Parallelizable? | Yes → separate Worker / No → same Worker, sequential |
| Tests needed? | Yes → include tester subagent |

**Worker count guidelines:**
- 1 Worker: Simple feature, < 3 files
- 2 Workers: Medium feature, independent components (e.g., backend + frontend)
- 3 Workers: Large feature, 3+ independent modules

Never exceed available GPT Plus account count.

### Step 4: Create Feature Branches

Each Worker gets its own feature branch:
```
feat/<task-slug>-<unit-name>
```

Example:
```
feat/hot-repo-scraper
feat/hot-repo-notifier
feat/hot-repo-ci
```

### Step 5: Generate Worker Specs

For each Worker, create a spec file:
```
notes/working-memory/<task-slug>/worker-<n>-spec.md
```

Each worker spec must include:
1. **Task**: What to implement
2. **Files**: What files to create/modify
3. **Branch**: Which feature branch to work on
4. **Tests**: How to verify the implementation
5. **Constraints**: Coding standards, dependencies, patterns to follow

### Step 6: Dispatch via MCP

Use `codex-sub` MCP to spawn Workers. Template:

```
For single worker:
  mcp__codex-sub__spawn_agent(prompt=<worker-spec>)

For parallel workers:
  mcp__codex-sub__spawn_agents_parallel(agents=[
    {"prompt": <worker-1-spec>},
    {"prompt": <worker-2-spec>},
    {"prompt": <worker-3-spec>}
  ])
```

### Step 7: Record Dispatch

Update `notes/working-memory/<task-slug>/progress.md` with:
- Timestamp
- Workers dispatched (count, branch names)
- Expected deliverables
- Status: DISPATCHED

## After Dispatch

The Planner (Claude) should:
1. Wait for all Workers to complete
2. Review each Worker's diff against the spec
3. Run tests across all branches
4. If issues found → create fix spec → re-dispatch to specific Worker
5. If all pass → merge feature branches to main
6. Update progress.md with final status

## Anti-Patterns

- Don't dispatch without a confirmed spec
- Don't put dependent tasks in parallel Workers
- Don't dispatch more Workers than available GPT Plus accounts
- Don't skip the review step after Workers complete
