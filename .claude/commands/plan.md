Generate an implementation plan from a confirmed spec.

## Input
- Spec location: $ARGUMENTS (default: find the most recent spec in `notes/working-memory/*/spec.md`)

## Process

1. Read the spec file
2. Read relevant project files (README, existing code, configs) to ground the plan
3. Generate a plan at `notes/working-memory/<task-slug>/task_plan.md`:

```
# Task Plan: <task-name>
## Goal — from spec
## Current Phase — planning
## Plan Overview — 1 paragraph: intent, approach, methodology
## Scope — In / Out
## Action Items — 6-12 verb-first atomic steps (discovery → changes → tests → validation)
## Dependencies — which items block others
## Parallelization — group items into Worker assignments
## Validation Strategy — how to verify end-to-end
## Risks — known risks and mitigations
## Phases — [x] Discovery, [x] Design, [ ] Implementation, [ ] Verification, [ ] Delivery
```

4. Present the plan summary, highlighting:
   - Recommended Worker count and assignment
   - Parallelization groups
   - Any open questions

5. Confirm with user before proceeding to dispatch

## Rules
- Each action item must be atomic, verb-first, mentioning specific files/commands
- At least 2 items must be test/validation steps
- Do NOT start implementation or dispatch — this command only produces the plan
