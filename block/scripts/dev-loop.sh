#!/bin/bash
# Block Project - Continuous Development Loop
# Runs web and mobile in parallel with auto-reload

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Block Project Development Environment ==="
echo "Project: $PROJECT_DIR"
echo ""

# Kill any existing processes
cleanup() {
  echo ""
  echo "Shutting down..."
  lsof -ti tcp:3000 | xargs kill -9 2>/dev/null || true
  lsof -ti tcp:8081 | xargs kill -9 2>/dev/null || true
  pkill -f "expo start" 2>/dev/null || true
  exit 0
}

trap cleanup SIGINT SIGTERM

# Start web
echo "Starting web server..."
cd "$PROJECT_DIR/web"
npm run dev &
WEB_PID=$!

# Wait for web to be ready
echo "Waiting for web server..."
for i in {1..30}; do
  if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "Web server ready at http://localhost:3000"
    break
  fi
  sleep 1
done

# Start mobile (optional)
if [ "$1" == "--with-mobile" ]; then
  echo ""
  echo "Starting mobile (Expo)..."
  cd "$PROJECT_DIR/mobile"
  npx expo start --ios &
  MOBILE_PID=$!
  echo "Mobile dev server starting..."
fi

echo ""
echo "=== Development servers running ==="
echo "Web:    http://localhost:3000"
[ -n "$MOBILE_PID" ] && echo "Mobile: http://localhost:8081"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

# Keep running
wait
