#!/bin/bash
# Type Check Hook - Runs TypeScript compiler after code changes
# Reports type errors to Claude for fixing

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Parse file path from hook input
file_path=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Exit if no TypeScript file
[ -z "$file_path" ] && exit 0
[[ ! "$file_path" =~ \.(ts|tsx)$ ]] && exit 0

# Determine which project
if [[ "$file_path" == *"/web/"* ]]; then
  cd "$PROJECT_DIR/web"
  PROJECT_NAME="web"
elif [[ "$file_path" == *"/mobile/"* ]]; then
  cd "$PROJECT_DIR/mobile"
  PROJECT_NAME="mobile"
else
  exit 0
fi

# Run TypeScript check
if [ -f "tsconfig.json" ] && command -v npx &> /dev/null; then
  echo "Type checking $PROJECT_NAME..."

  # Run tsc and capture output
  output=$(npx tsc --noEmit 2>&1)
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    # Filter to show only errors related to the changed file
    file_errors=$(echo "$output" | grep -A 2 "$(basename "$file_path")" | head -20)

    if [ -n "$file_errors" ]; then
      echo "Type errors in $(basename "$file_path"):"
      echo "$file_errors"
      # Exit code 2 = blocking error, fed back to Claude
      exit 2
    fi
  else
    echo "No type errors"
  fi
fi

exit 0
