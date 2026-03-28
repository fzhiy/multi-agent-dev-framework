#!/usr/bin/env sh

set -eu

if [ $# -lt 1 ]; then
  echo "usage: $0 <task-slug>" >&2
  exit 1
fi

slug="$1"
root="notes/working-memory/$slug"

mkdir -p "$root"

task_plan="$root/task_plan.md"
findings="$root/findings.md"
progress="$root/progress.md"

if [ ! -f "$task_plan" ]; then
  cat > "$task_plan" <<'EOF'
# Task Plan

## Goal
-

## Current Phase
- discovery

## Phases
- [ ] Discovery
- [ ] Design
- [ ] Implementation
- [ ] Verification
- [ ] Delivery

## Open Decisions
-

## Risks
-
EOF
fi

if [ ! -f "$findings" ]; then
  cat > "$findings" <<'EOF'
# Findings

## Facts
-

## Constraints
-

## Notes
-
EOF
fi

if [ ! -f "$progress" ]; then
  cat > "$progress" <<'EOF'
# Progress

## Log
- Initialized worklog

## Tests
-

## Next Step
-
EOF
fi

printf '%s\n' "$root"
