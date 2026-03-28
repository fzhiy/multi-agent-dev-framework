---
name: requirement-spec
description: Use when a user describes a new feature, project, or task that needs structured requirements before implementation. Transforms vague requests into a formal spec with goal, constraints, acceptance criteria, and technical notes. Outputs a spec file that workers can consume directly.
---

# Requirement Spec

Transform a user request into a structured, implementation-ready specification.

## When to Use

- User describes a new feature or project
- Requirements are vague or incomplete
- Before starting any implementation planning
- When multiple workers will need to understand the same task

## Process

### Step 1: Understand the Request

Read the user's description carefully. Identify:
- What they want to build
- Why they want it (motivation/context)
- Any constraints mentioned (tech stack, timeline, dependencies)
- Any examples or references provided

### Step 2: Clarify (max 3 questions)

Ask at most 3 clarifying questions. Prefer multiple-choice. Focus on:
- Ambiguities that would lead to wrong implementation
- Missing technical decisions (language, framework, deployment)
- Scope boundaries (what's NOT included)

If reasonable defaults exist, state your assumption instead of asking.

### Step 3: Generate Spec

Create a spec file using the template at `templates/spec.md`. Save it to:

```
notes/working-memory/<task-slug>/spec.md
```

Also initialize the working memory folder if it doesn't exist:

```bash
sh .codex/skills/repo-working-memory/scripts/init-worklog.sh <task-slug>
```

### Step 4: Confirm with User

Present the spec summary and ask for confirmation before proceeding to planning.

## Output Format

The spec file must be self-contained — a Worker reading only this file should understand exactly what to build.

## Template

See `templates/spec.md` for the output structure.
