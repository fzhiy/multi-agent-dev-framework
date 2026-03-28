Show the current status of multi-agent development tasks.

## Input
- Task slug: $ARGUMENTS (default: show all tasks)

## Process

1. List all task directories under `notes/working-memory/`
2. For each task, read and summarize:
   - `task_plan.md` — current phase, completion of action items
   - `progress.md` — latest log entries, test results, next step
   - `spec.md` — goal (first line)
3. Check git branches for any `feat/*` branches and their status relative to main
4. Present a summary table:

```
## Multi-Agent Task Status

| Task | Phase | Action Items | Tests | Branches | Next Step |
|------|-------|-------------|-------|----------|-----------|
| <slug> | Implementation | 7/10 done | 9 pass | feat/xxx, feat/yyy | Review |
```

5. If a specific task is requested, show detailed progress including full log

## Rules
- Read-only command — do not modify any files
- Show timestamps from progress.md for context
