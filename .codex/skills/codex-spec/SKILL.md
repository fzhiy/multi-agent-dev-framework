---
name: codex-spec
description: Use when a user request needs to be turned into a structured specification with clear requirements, constraints, scope, and acceptance criteria before planning or implementation.
---

# Codex Spec

This skill is the Codex-only equivalent of the Claude Code `/spec` command.

## When to Use

- A user describes a feature, workflow, or project in natural language
- Requirements are incomplete, ambiguous, or scattered across the conversation
- The team needs a self-contained spec before planning or dispatch
- Multiple agents or Workers will need a shared source of truth

## Process

### Step 1: Read the Request

Read the user's request from the conversation. Identify:
- What to build
- Why it should be built
- Constraints, assumptions, and references
- Anything explicitly in scope or out of scope

### Step 2: Clarify at Most 3 Questions

Ask at most 3 clarifying questions. Prefer multiple-choice where possible. Focus only on ambiguities that would materially change implementation.

If a reasonable default exists, state the assumption instead of asking.

### Step 3: Initialize Working Memory

Initialize working memory for the task:

```bash
sh .codex/skills/repo-working-memory/scripts/init-worklog.sh <task-slug>
```

Use a concise, stable `<task-slug>` derived from the task name.

### Step 4: Generate the Spec File

Create:

```text
notes/working-memory/<task-slug>/spec.md
```

Use this exact structure:

```markdown
# Spec: <task-name>
## Goal
## Background
## Requirements
### Functional
### Non-Functional
## Scope
## Technical Decisions
## Acceptance Criteria
## File Structure
## Open Questions
```

Content expectations:
- `Goal`: one-sentence statement of the outcome
- `Background`: context for the implementer
- `Requirements / Functional`: numbered behaviors the system must support
- `Requirements / Non-Functional`: performance, security, reliability, usability, or maintenance constraints
- `Scope`: clear in-scope and out-of-scope boundaries
- `Technical Decisions`: language, dependencies, target environment, integration points
- `Acceptance Criteria`: testable checks
- `File Structure`: proposed files or directories to create or modify
- `Open Questions`: only unresolved items that genuinely remain

### Step 5: Present and Confirm

Present a concise spec summary to the user and confirm before proceeding to planning.

Do not start implementation.

## Rules

- The spec must be self-contained
- Do NOT start implementation
- Keep technical terms in English
- Prefer explicit assumptions over vague wording
- Write for a Worker who will read only this file plus working memory
