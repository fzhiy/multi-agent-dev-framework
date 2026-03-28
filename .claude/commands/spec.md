Transform the user's request into a structured, implementation-ready specification.

## Process

1. Read the user's description: $ARGUMENTS
2. Identify: what to build, why, constraints, references
3. Ask at most 3 clarifying questions (prefer multiple-choice, assume reasonable defaults)
4. Initialize working memory: `sh .codex/skills/repo-working-memory/scripts/init-worklog.sh <task-slug>`
5. Generate spec file at `notes/working-memory/<task-slug>/spec.md` using this structure:

```
# Spec: <task-name>
## Goal — one sentence
## Background — context for implementer
## Requirements
### Functional — numbered list of what the system must do
### Non-Functional — performance, security, usability constraints
## Scope — In / Out of Scope
## Technical Decisions — language, dependencies, target environment
## Acceptance Criteria — testable checkboxes
## File Structure (Proposed)
## Open Questions
```

6. Present the spec summary and confirm with user before proceeding

## Rules
- The spec must be self-contained: a Worker reading only this file should understand exactly what to build
- Do NOT start implementation — this command only produces the spec
- Keep technical terms in English, explanations can be in user's preferred language
