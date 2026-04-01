#!/usr/bin/env bash

set -eu

echo "== Preferences =="
sed -n '1,200p' ".agentic-flywheel/memory/preferences.md"

echo
echo "== Domain Rules =="
sed -n '1,220p' ".agentic-flywheel/memory/domain-rules.md"

echo
echo "== Harness Rules =="
sed -n '1,220p' ".agentic-flywheel/memory/harness-rules.md"

echo
echo "== Backlog Recommendations =="
find ".agentic-flywheel/recommendations/backlog" -type f -name '*.md' ! -name 'README.md' | sort || true
