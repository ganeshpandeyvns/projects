#!/bin/bash
# Verify Completion Hook - Runs before Claude stops working
# Ensures code builds and tests pass

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

echo "=== Verifying Block Project Completion ==="

issues_found=0
issues=""

# Check web project
if [ -d "$PROJECT_DIR/web" ]; then
  cd "$PROJECT_DIR/web"

  # Check for TypeScript errors
  if [ -f "tsconfig.json" ]; then
    echo "Checking web TypeScript..."
    tsc_output=$(npx tsc --noEmit 2>&1)
    if [ $? -ne 0 ]; then
      error_count=$(echo "$tsc_output" | grep -c "error TS" || echo "0")
      if [ "$error_count" -gt 0 ]; then
        issues_found=1
        issues="$issues\n- Web: $error_count TypeScript error(s)"
        echo "Found $error_count TypeScript errors in web"
      fi
    fi
  fi

  # Check for console.log in production code (excluding tests and node_modules)
  debug_logs=$(grep -r "console\.log" --include="*.ts" --include="*.tsx" \
    --exclude-dir=node_modules --exclude-dir=e2e --exclude-dir=__tests__ \
    app/ lib/ components/ 2>/dev/null | wc -l | tr -d ' ')

  if [ "$debug_logs" -gt 5 ]; then
    issues_found=1
    issues="$issues\n- Web: $debug_logs console.log statements found"
  fi

  cd "$PROJECT_DIR"
fi

# Check mobile project
if [ -d "$PROJECT_DIR/mobile" ]; then
  cd "$PROJECT_DIR/mobile"

  # Check for TypeScript errors
  if [ -f "tsconfig.json" ]; then
    echo "Checking mobile TypeScript..."
    tsc_output=$(npx tsc --noEmit 2>&1)
    if [ $? -ne 0 ]; then
      error_count=$(echo "$tsc_output" | grep -c "error TS" || echo "0")
      if [ "$error_count" -gt 0 ]; then
        issues_found=1
        issues="$issues\n- Mobile: $error_count TypeScript error(s)"
        echo "Found $error_count TypeScript errors in mobile"
      fi
    fi
  fi

  cd "$PROJECT_DIR"
fi

# Check for TODO/FIXME in recent changes
todo_count=$(grep -r "TODO\|FIXME" --include="*.ts" --include="*.tsx" \
  "$PROJECT_DIR/web/app" "$PROJECT_DIR/web/components" "$PROJECT_DIR/web/lib" \
  "$PROJECT_DIR/mobile/app" "$PROJECT_DIR/mobile/components" 2>/dev/null | wc -l | tr -d ' ')

if [ "$todo_count" -gt 10 ]; then
  echo "Note: $todo_count TODO/FIXME comments found"
fi

# Report results
if [ $issues_found -eq 1 ]; then
  echo ""
  echo "=== Issues Found ==="
  echo -e "$issues"
  echo ""
  echo '{"decision": "block", "reason": "Please fix the issues listed above before completing."}'
  exit 0
else
  echo "=== All checks passed ==="
fi

exit 0
