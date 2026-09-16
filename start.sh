#!/bin/bash
# Multimedia Explorer — Terminal Startup
set -e
cd "$(dirname "$0")"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Multimedia Explorer — Starting...      ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Install deps if needed
if [ ! -d "node_modules" ]; then
    echo "[1/3] Installing dependencies..."
    if command -v bun &>/dev/null; then
        bun install
    else
        npm install
    fi
    echo ""
fi

# Auto-update from git
if [ -d ".git" ]; then
    echo "[2/3] Checking for updates..."
    git fetch origin 2>/dev/null || true
    LOCAL=$(git rev-parse HEAD 2>/dev/null)
    REMOTE=$(git rev-parse origin/$(git branch --show-current 2>/dev/null || echo main) 2>/dev/null)
    if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
        echo "  → Pulling updates..."
        git stash 2>/dev/null || true
        git pull --quiet 2>/dev/null || true
        if command -v bun &>/dev/null; then bun install 2>/dev/null; else npm install 2>/dev/null; fi
        git stash pop 2>/dev/null || true
        echo "  ✓ Updated"
    else
        echo "  ✓ Up to date"
    fi
    echo ""
fi

# Kill existing dev server
pkill -f "next dev" 2>/dev/null || true
rm -f .next/dev/lock 2>/dev/null || true

echo "[3/3] Starting dev server at http://localhost:3000"
echo "      Press Ctrl+C to stop"
echo ""

# Open browser after 3s
(sleep 3 && (xdg-open http://localhost:3000 2>/dev/null || open http://localhost:3000 2>/dev/null || true)) &

# Start server
if command -v bun &>/dev/null; then
    bun run dev
else
    npm run dev
fi
