# Hybrid Mode Guide

## Overview

Hybrid mode uses Claude Code as the Level 0 Planner and Codex CLI workers as the Level 1 implementation pool, connected by the `codex-as-mcp` MCP bridge. This provides the strongest review quality through cross-model adversarial critique: Claude reviews GPT output.

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Level 0 planner/reviewer | `npm i -g @anthropic-ai/claude-code` |
| [Codex CLI](https://github.com/openai/codex) | Level 1 workers | `npm i -g @openai/codex` |
| [codex-as-mcp](https://github.com/kky42/codex-as-mcp) | MCP bridge | auto-installed via `uvx` |
| tmux (optional) | Session management | `apt install tmux` / `brew install tmux` |

### Subscriptions

- 1x **Claude Max** (Opus) -- planner and reviewer
- 1-3x **ChatGPT Plus** -- worker pool (each account = 1 concurrent Codex worker)

## Setup

```bash
# 1. Install Codex CLI
npm i -g @openai/codex

# 2. Login to your GPT Plus account(s)
codex login

# 3. Register the MCP bridge in Claude Code
claude mcp add codex-sub -- uvx codex-as-mcp@latest
```

Done. Claude Code can now dispatch Codex workers via MCP.

**Optional**: Set project-level git identity to avoid leaking your global config:

```bash
cd /path/to/your-project
git config user.name "Your Name"
git config user.email "your-public-email@example.com"
```

## Usage

Start Claude Code in the project directory:

```bash
claude
```

Drive the workflow with slash commands:

| Command | Purpose | Stage |
|---------|---------|-------|
| `/spec <description>` | Transform a request into a structured spec with acceptance criteria | Requirements |
| `/plan [spec-path]` | Generate 6-12 atomic action items with parallelization groups | Planning |
| `/dispatch [plan-path]` | Create feature branches, dispatch Codex Workers via MCP | Implementation |
| `/review-workers [task]` | Review Worker diffs, run adversarial review via GPT-5.4 | Review |
| `/status [task]` | Show progress across all active multi-agent tasks | Monitoring |

Full development cycle:

```
/spec "build feature X"  ->  /plan  ->  /dispatch  ->  /review-workers  ->  merge
```

Every command has a confirmation gate -- no automatic pushes, no merges without approval.

## Workflow Patterns

### Pattern A: Single Feature

```
You -> Claude: "Implement feature X"
Claude -> Plans the approach
Claude -> Dispatches implementer worker via MCP
Claude -> Reviews the diff
Claude -> Approves or requests changes
```

### Pattern B: Parallel Implementation

Best for larger tasks with independent components.

```
You -> Claude: "Implement features X, Y, Z in parallel"

Claude dispatches:
  Worker 1 (implementer) -> Feature X
  Worker 2 (implementer) -> Feature Y
  Worker 3 (implementer) -> Feature Z

Claude reviews all diffs -> merge
```

### Pattern C: Full Pipeline with Subagents

```
You -> Claude: "Implement feature X with analysis first"

Claude dispatches Worker 1:
  analyzer subagent -> reports dependencies and interfaces
  implementer subagent -> writes code based on analysis
  tester subagent -> writes and runs tests

Claude reviews combined output -> merge
```

## How Dispatch Works

1. Claude reads the approved plan and identifies parallelization groups
2. Creates feature branches: `feat/<task-slug>-<unit-name>`
3. Creates isolated git worktrees: `git worktree add ../<project>-<unit> <branch>`
4. Generates worker specs with interface contracts
5. Dispatches via MCP with per-worker cwd:
   ```
   mcp__codex__codex(prompt=<worker-spec>, cwd=<worktree-path>)
   ```
6. Each worker runs in isolation, commits to its feature branch

**Important**: Use `mcp__codex__codex` with explicit `cwd` per worker for true isolation. `spawn_agents_parallel` shares cwd and causes branch pollution.

## How Review Works

1. Claude reviews each worker's diff: `git diff main..<branch>`
2. Checks implementation against worker spec
3. Checks for hardcoded paths, credentials, sensitive data
4. Runs tests if the branch has them
5. Optionally dispatches adversarial review via `mcp__codex-review__review_start`
6. Presents findings: APPROVED or CHANGES_REQUESTED
7. Max 3 review iterations per worker before escalating to user

## Trade-offs

| Aspect | Hybrid Mode |
|--------|-------------|
| Review quality | Strongest -- cross-model adversarial (Claude reviews GPT) |
| Subscriptions | Claude Max + GPT Plus |
| Interaction | Slash commands (`/spec`, `/plan`, `/dispatch`, etc.) |
| Dispatch mechanism | MCP bridge (`codex-as-mcp`) |
| Setup complexity | Moderate -- requires MCP bridge registration |
