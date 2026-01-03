#!/bin/bash
# Block Project Health Check
# Quick assessment of project status

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Block Project Health Check ==="
echo "Date: $(date)"
echo ""

# Web checks
echo "## Web Project"
cd "$PROJECT_DIR/web"

# Dependencies
if [ -d "node_modules" ]; then
  echo "- Dependencies: Installed"
else
  echo "- Dependencies: MISSING (run npm install)"
fi

# TypeScript
echo -n "- TypeScript: "
tsc_errors=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || echo "0")
if [ "$tsc_errors" -eq 0 ]; then
  echo "No errors"
else
  echo "$tsc_errors errors"
fi

# Console logs
debug_count=$(grep -r "console\.log" --include="*.ts" --include="*.tsx" \
  --exclude-dir=node_modules --exclude-dir=e2e --exclude-dir=__tests__ \
  app/ lib/ components/ 2>/dev/null | wc -l | tr -d ' ')
echo "- Debug logs: $debug_count console.log statements"

# Tests
test_count=$(find e2e -name "*.spec.ts" 2>/dev/null | wc -l | tr -d ' ')
echo "- E2E Tests: $test_count specs"

echo ""

# Mobile checks
echo "## Mobile Project"
cd "$PROJECT_DIR/mobile"

# Dependencies
if [ -d "node_modules" ]; then
  echo "- Dependencies: Installed"
else
  echo "- Dependencies: MISSING (run npm install)"
fi

# TypeScript
echo -n "- TypeScript: "
tsc_errors=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || echo "0")
if [ "$tsc_errors" -eq 0 ]; then
  echo "No errors"
else
  echo "$tsc_errors errors"
fi

# Maestro tests
maestro_count=$(find .maestro -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
echo "- Maestro Tests: $maestro_count flows"

echo ""
echo "## Summary"

# Count lines of code
web_loc=$(find "$PROJECT_DIR/web/app" "$PROJECT_DIR/web/components" "$PROJECT_DIR/web/lib" \
  -name "*.ts" -o -name "*.tsx" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
mobile_loc=$(find "$PROJECT_DIR/mobile/app" "$PROJECT_DIR/mobile/components" "$PROJECT_DIR/mobile/services" \
  -name "*.ts" -o -name "*.tsx" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')

echo "- Web LOC: ~$web_loc"
echo "- Mobile LOC: ~$mobile_loc"
echo "- Total LOC: ~$((web_loc + mobile_loc))"

echo ""
echo "=== Health Check Complete ==="
