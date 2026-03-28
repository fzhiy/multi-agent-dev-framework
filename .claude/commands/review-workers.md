Review the output of completed Codex Workers and decide next steps.

## Input
- Task slug: $ARGUMENTS (default: find the most recent task in `notes/working-memory/`)

## Process

1. Read the task plan and worker specs from `notes/working-memory/<task-slug>/`
2. For each Worker's feature branch:
   a. `git diff main..<branch>` — review the diff
   b. Check: does the implementation match the worker spec?
   c. Check: are there hardcoded paths, credentials, or sensitive data?
   d. Run tests if the branch has them
3. Optionally dispatch an adversarial review via `mcp__codex-review__review_start`
4. Present findings:

```
## Worker Review Summary

### Worker 1 (feat/xxx)
- Status: APPROVED / CHANGES_REQUESTED
- Tests: X passed, Y failed
- Issues: [list]

### Worker 2 (feat/yyy)
- Status: ...
```

5. If CHANGES_REQUESTED:
   - Write a fix spec
   - Ask user: re-dispatch to Worker or fix manually?
6. If all APPROVED:
   - Ask user: merge to main?
   - Only merge after explicit approval
   - Update progress.md with final status

## Rules
- Never merge without user approval
- Never push to remote without user approval
- Document all review findings in progress.md
- Max 3 review iterations per Worker before escalating to user
