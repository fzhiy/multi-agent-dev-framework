---
name: repo-working-memory
description: Use for complex or long-running tasks in this repository when you need persistent context, phased execution, or interruption-safe progress tracking. Creates and maintains repo-local memory files under notes/working-memory instead of scraping global session history.
---

# Repo Working Memory

Use tracked markdown files in this repository as working memory on disk.

## Core Rule

For any task that will likely take more than 5 tool calls, or span multiple sessions:

1. Create or reuse a task folder under `notes/working-memory/<task-slug>/`
2. Maintain:
   - `task_plan.md`
   - `findings.md`
   - `progress.md`
3. Read these files before major decisions
4. Update `progress.md` after each meaningful batch of work
5. Update `task_plan.md` when phase status changes

## Safety Rule

Do **not** scrape or auto-parse:

- `~/.codex/history.jsonl`
- `~/.codex/state_*.sqlite`
- `~/.codex/logs_*.sqlite`
- browser/session stores
- unrelated home-directory files

This skill is intentionally repo-local and privacy-preserving.

## Quick Start

Initialize a task folder:

```bash
sh .codex/skills/repo-working-memory/scripts/init-worklog.sh <task-slug>
```

Example:

```bash
sh .codex/skills/repo-working-memory/scripts/init-worklog.sh tune-scoring
```

This creates:

```text
notes/working-memory/<task-slug>/task_plan.md
notes/working-memory/<task-slug>/findings.md
notes/working-memory/<task-slug>/progress.md
```

## Operating Pattern

- Before exploration: read `task_plan.md`
- After discoveries: append concise facts to `findings.md`
- After implementation or experiments: append commands, outputs, and status to `progress.md`
- Before closing a task: run the completion check

```bash
sh .codex/skills/repo-working-memory/scripts/check-complete.sh <task-slug>
```

## What Goes in Each File

### `task_plan.md`
- goal
- current phase
- ordered phases
- open decisions
- known risks

### `findings.md`
- facts learned from code, docs, or experiments
- relevant links, benchmarks, constraints
- what changed in your understanding

### `progress.md`
- timestamped action log
- commands run
- tests performed
- errors encountered
- next step

## When To Use

Use for:

- multi-step coding tasks
- repo-wide refactors
- research-heavy changes
- debugging that may span sessions
- any task where losing context would be expensive

Skip for:

- one-shot factual questions
- tiny single-file edits
- quick shell lookups
