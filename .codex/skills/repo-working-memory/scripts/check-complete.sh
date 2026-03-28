#!/usr/bin/env sh

set -eu

if [ $# -lt 1 ]; then
  echo "usage: $0 <task-slug>" >&2
  exit 1
fi

slug="$1"
root="notes/working-memory/$slug"

for file in task_plan.md findings.md progress.md; do
  if [ ! -f "$root/$file" ]; then
    echo "missing: $root/$file" >&2
    exit 1
  fi
done

if grep -q '\- \[ \]' "$root/task_plan.md"; then
  echo "incomplete phases remain in $root/task_plan.md"
  exit 2
fi

echo "worklog looks complete: $root"
