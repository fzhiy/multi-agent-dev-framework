---
name: create-plan
description: Use when a confirmed spec exists and you need a precise implementation plan before dispatching workers. Generates 6-12 atomic action items with dependencies, validation steps, and a testing strategy. Reads the codebase first to ground the plan in reality. Based on the experimental openai/skills create-plan pattern.
---

# Create Plan

Generate a precise, implementation-ready plan from a confirmed spec.

## When to Use

- After `requirement-spec` has produced a confirmed spec
- Before `task-dispatcher` dispatches workers
- When you need to break a feature into atomic, ordered steps

## Process

### Step 1: Research

Before planning, gather context:
1. Read the spec: `notes/working-memory/<task-slug>/spec.md`
2. Read relevant project files (README, existing code, configs)
3. Identify constraints (language, frameworks, test commands, CI)

### Step 2: Generate Plan

Produce a plan in this exact format and save to `notes/working-memory/<task-slug>/task_plan.md`:

```markdown
# Task Plan: <task-name>

## Goal
[1 sentence from spec]

## Current Phase
- planning

## Plan Overview
[1 paragraph: intent, approach, methodology]

## Scope
- In: [what's included]
- Out: [what's excluded]

## Action Items
- [ ] [Verb-first atomic action, mentioning files/commands]
- [ ] [Next step following: discovery → changes → tests → validation]
[6-12 items total]

## Dependencies
[Which items must complete before others can start]
- Item N blocks Item M

## Parallelization
[Which items can run simultaneously]
- Parallel group A: Items 1, 2, 3
- Parallel group B: Items 4, 5 (after group A)

## Validation Strategy
- [ ] [How to verify the whole feature works end-to-end]

## Open Questions
- [Max 3, if any]

## Risks
- [Known risks and mitigations]
```

### Step 3: Review with User

Present the plan summary. Key questions:
1. Does the parallelization grouping look right?
2. Are the scope boundaries correct?
3. Any missing steps?

Only proceed to dispatch after user confirms.

## Action Item Rules

- **Verb-first**: Add..., Create..., Implement..., Test..., Configure...
- **Atomic**: Each item is a single unit of work
- **Concrete**: Mention specific files, commands, modules
- **Ordered**: Follow discovery → changes → tests → validation
- **Testable**: At least 2 items must be test/validation steps
- **Count**: 6-12 items (fewer for simple tasks, more for complex)
