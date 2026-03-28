Dispatch implementation tasks to Codex Workers via MCP based on an approved plan.

## Input
- Plan location: $ARGUMENTS (default: find the most recent plan in `notes/working-memory/*/task_plan.md`)

## Process

1. Read the plan and spec files
2. For each parallelization group in the plan:
   a. Create a feature branch: `feat/<task-slug>-<unit-name>`
   b. Write a worker spec to `notes/working-memory/<task-slug>/worker-<n>-spec.md`
   c. Each worker spec must include: Task, Branch, Files, Requirements, Tests, Constraints
3. Present the dispatch plan to the user:
   - How many Workers
   - What each Worker will do
   - Which branches
4. After user confirms, dispatch via MCP:

For single worker:
```
mcp__codex-sub__spawn_agent(prompt=<worker-spec>)
```

For parallel workers:
```
mcp__codex-sub__spawn_agents_parallel(agents=[...])
```

5. Update `notes/working-memory/<task-slug>/progress.md` with dispatch timestamp and worker assignments

## After Workers Complete

1. Review each Worker's diff against the spec
2. Run tests across all branches
3. If issues found → describe fixes → ask user whether to re-dispatch or fix manually
4. If all pass → present results to user for merge approval
5. Do NOT push to remote without explicit user approval

## Rules
- Never dispatch without a confirmed plan
- Never dispatch more Workers than available GPT Plus accounts (max 3)
- Each Worker must work on its own feature branch
- Workers must commit to their branch, not to main
- The review step after Workers complete is mandatory
