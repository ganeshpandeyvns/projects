#!/bin/bash
# Auto-Format Hook - Formats code after Write/Edit operations
# Runs prettier on TypeScript/JavaScript files

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Parse file path from hook input (JSON on stdin)
file_path=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Exit if no file path
[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

# Determine which project the file belongs to
if [[ "$file_path" == *"/web/"* ]]; then
  cd "$PROJECT_DIR/web"
elif [[ "$file_path" == *"/mobile/"* ]]; then
  cd "$PROJECT_DIR/mobile"
else
  exit 0
fi

# Format TypeScript/JavaScript files
if [[ "$file_path" =~ \.(ts|tsx|js|jsx)$ ]]; then
  if command -v npx &> /dev/null && [ -f "node_modules/.bin/prettier" ]; then
    npx prettier --write "$file_path" --log-level error 2>/dev/null && \
      echo "Formatted: $(basename "$file_path")" || true
  fi
fi

# Format JSON files
if [[ "$file_path" =~ \.json$ ]] && [[ ! "$file_path" =~ (package-lock|node_modules) ]]; then
  if command -v npx &> /dev/null && [ -f "node_modules/.bin/prettier" ]; then
    npx prettier --write "$file_path" --log-level error 2>/dev/null || true
  fi
fi

exit 0
