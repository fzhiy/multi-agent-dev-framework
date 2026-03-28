---
name: codex-plan
description: Use when a confirmed specification needs to be turned into an implementation plan with atomic action items, dependencies, validation steps, and worker parallelization guidance.
---

# Codex Plan

This skill is the Codex-only equivalent of the Claude Code `/plan` command.

In codex-only mode, the `planner` agent generates this plan directly using native Codex capabilities.

## When to Use

- A spec has been confirmed and work should move into planning
- The task needs explicit sequencing, dependencies, and validation steps
- Work may be split across multiple Workers
- The user wants an implementation roadmap before dispatch

## Input

- Find the most recent spec in `notes/working-memory/*/spec.md`, or use the spec path mentioned by the user

## Process

### Step 1: Read the Spec

Read the target spec file carefully and extract:
- Goal
- Constraints
- Acceptance criteria
- Proposed files and interfaces

### Step 2: Read Relevant Project Files

Read the project files needed to ground the plan in reality, such as:
- `README`
- Existing code
- Config files
- Tests
- Build or lint tooling

### Step 3: Generate the Plan File

Create:

```text
notes/working-memory/<task-slug>/task_plan.md
```

Use this exact structure:

```markdown
# Task Plan: <task-name>
## Goal
## Current Phase
## Plan Overview
## Scope
## Action Items
## Dependencies
## Parallelization
## Validation Strategy
## Risks
## Phases
```

Content expectations:
- `Goal`: copied from or aligned with the spec
- `Current Phase`: `planning`
- `Plan Overview`: one paragraph describing approach and rationale
- `Scope`: in-scope and out-of-scope boundaries
- `Action Items`: 6-12 verb-first atomic steps covering discovery, changes, tests, and validation
- `Dependencies`: which items block others
- `Parallelization`: candidate Worker groupings and why they are safe
- `Validation Strategy`: end-to-end verification commands and checks
- `Risks`: likely failure modes and mitigations
- `Phases`: checklist for Discovery, Design, Implementation, Verification, Delivery

### Step 4: Present and Confirm

Present a plan summary that highlights:
- Recommended Worker count
- Parallelization groups
- Any open questions or blocked assumptions

Confirm with the user before dispatch.

Do not start implementation or dispatch.

## Rules

- Each action item must be atomic, verb-first, and specific about files or commands
- Include at least 2 test or validation steps
- Ground the plan in the actual repository, not generic assumptions
- Do NOT start implementation or dispatch
- Write the plan so a dispatcher can act on it without re-planning
