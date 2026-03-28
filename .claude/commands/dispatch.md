Dispatch implementation tasks to Codex Workers via MCP based on an approved plan.

## Input
- Plan location: $ARGUMENTS (default: find the most recent plan in `notes/working-memory/*/task_plan.md`)

## Process

1. Read the plan and spec files
2. For each parallelization group in the plan:
   a. Create a feature branch: `feat/<task-slug>-<unit-name>`
   b. Create an isolated git worktree for each Worker:
      ```bash
      git worktree add ../<project>-<unit> feat/<task-slug>-<unit-name>
      ```
   c. Write a worker spec to `notes/working-memory/<task-slug>/worker-<n>-spec.md`
   d. Each worker spec must include: Task, Branch, Files, Requirements, Tests, Constraints, Interface Contract
3. Present the dispatch plan to the user:
   - How many Workers
   - What each Worker will do
   - Which worktree paths
4. After user confirms, dispatch via MCP with **per-worker cwd**:

For single worker:
```
mcp__codex__codex(prompt=<worker-spec>, cwd=<worktree-path>)
```

For parallel workers (each in its own worktree):
```
# Dispatch sequentially with different cwd, or use spawn_agent per worktree
mcp__codex__codex(prompt=<worker-1-spec>, cwd="../project-unit1")
mcp__codex__codex(prompt=<worker-2-spec>, cwd="../project-unit2")
```

Note: `spawn_agents_parallel` shares cwd — use `mcp__codex__codex` with explicit `cwd` for true isolation.

5. Update `notes/working-memory/<task-slug>/progress.md` with dispatch timestamp and worker assignments

## After Workers Complete

1. Review each Worker's diff: `git diff main..<branch>`
2. Run tests across all branches
3. If issues found → describe fixes → ask user whether to re-dispatch or fix manually
4. If all pass → present results to user for merge approval
5. Clean up worktrees: `git worktree remove ../<project>-<unit>`
6. Do NOT push to remote without explicit user approval

## Rules
- Never dispatch without a confirmed plan
- Never dispatch more Workers than available GPT Plus accounts (max 3)
- Each Worker must work in its own git worktree (not shared cwd)
- Workers must commit to their feature branch, not to main
- Include Interface Contract in worker spec when modules have cross-dependencies
- The review step after Workers complete is mandatory
