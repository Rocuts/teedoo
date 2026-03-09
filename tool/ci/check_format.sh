#!/usr/bin/env bash
set -euo pipefail

TARGETS=(lib test)

printf '🔎 Running format check on: %s\n' "${TARGETS[*]}"

if ! command -v dart >/dev/null 2>&1; then
  echo '❌ Dart SDK is not installed or not on PATH.'
  echo 'Install Flutter/Dart and re-run:'
  echo '  dart format lib test'
  exit 127
fi

if dart format --output=none --set-exit-if-changed "${TARGETS[@]}"; then
  echo '✅ Formatting check passed.'
  exit 0
fi

echo
echo '❌ Formatting check failed. The formatter would change files.'
echo 'Run this locally to fix it:'
echo '  dart format lib test'
echo

echo 'Files that need formatting:'
# The formatter already edited files in-place in this environment,
# so show the currently modified Dart files to make debugging easier.
git diff --name-only -- '*.dart' | sed 's/^/  - /'

exit 1
