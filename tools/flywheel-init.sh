#!/usr/bin/env bash

set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: bash tools/flywheel-init.sh <slug>"
  exit 1
fi

slug="$1"
date_prefix="$(date +%F)"
run_dir=".agentic-flywheel/runs/${date_prefix}-${slug}"

if [ -e "$run_dir" ]; then
  echo "Run already exists: $run_dir"
  exit 1
fi

mkdir -p "$run_dir"
cp ".agentic-flywheel/templates/run.md" "$run_dir/run.md"

echo "Created $run_dir"
echo "Next:"
echo "  - Fill in $run_dir/run.md"
echo "  - Add any recommendation files next to it or under .agentic-flywheel/recommendations/"
