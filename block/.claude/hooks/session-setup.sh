#!/bin/bash
# Session Setup Hook - Runs when a new Claude Code session starts
# Ensures dependencies are installed and environment is ready

set -e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR"

echo "=== Block Project Session Setup ==="

# Setup web project
if [ -d "web" ] && [ -f "web/package.json" ]; then
  cd web
  if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
    echo "Installing web dependencies..."
    npm ci --silent 2>/dev/null || npm install --silent
  fi
  cd ..
  echo "Web project ready"
fi

# Setup mobile project
if [ -d "mobile" ] && [ -f "mobile/package.json" ]; then
  cd mobile
  if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
    echo "Installing mobile dependencies..."
    npm ci --silent 2>/dev/null || npm install --silent
  fi
  cd ..
  echo "Mobile project ready"
fi

# Add environment variables if env file provided
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "export BLOCK_PROJECT_DIR=\"$PROJECT_DIR\"" >> "$CLAUDE_ENV_FILE"
  echo "export WEB_DIR=\"$PROJECT_DIR/web\"" >> "$CLAUDE_ENV_FILE"
  echo "export MOBILE_DIR=\"$PROJECT_DIR/mobile\"" >> "$CLAUDE_ENV_FILE"
fi

echo "=== Session setup complete ==="
exit 0
