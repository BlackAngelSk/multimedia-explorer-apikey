#!/bin/bash
# ============================================
#  Multimedia Explorer - Setup & Start Script
#  For Linux / macOS
# ============================================

# If not running in a terminal, relaunch in one
if [ -t 0 ]; then
    # Already in a terminal, continue
    :
else
    # Not in a terminal — open a new one and run this same script
    if command -v konsole &>/dev/null; then
        konsole -e bash "$(realpath "$0")" "$@"
    elif command -v gnome-terminal &>/dev/null; then
        gnome-terminal -- bash "$(realpath "$0")" "$@"
    elif command -v xterm &>/dev/null; then
        xterm -e bash "$(realpath "$0")" "$@"
    else
        echo "Error: Cannot find a terminal emulator."
        echo "Please run this script from a terminal: bash setup.sh"
        exit 1
    fi
    exit 0
fi

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Multimedia Explorer - Setup Script     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# ---- Step 1: Check if bun is installed ----
echo -e "${YELLOW}[1/5]${NC} Checking for bun..."
if ! command -v bun &> /dev/null; then
    echo -e "${RED}Error: bun is not installed.${NC}"
    echo ""
    echo "Install bun first:"
    echo "  curl -fsSL https://bun.sh/install | bash"
    echo ""
    echo "Or visit: https://bun.sh"
    exit 1
fi
echo -e "${GREEN}  ✓ bun found: $(bun --version)${NC}"
echo ""

# ---- Step 2: Install dependencies ----
echo -e "${YELLOW}[2/5]${NC} Installing dependencies..."
if [ -d "node_modules" ]; then
    echo -e "${GREEN}  ✓ Dependencies already installed (node_modules exists)${NC}"
else
    echo -e "${CYAN}  → Running bun install...${NC}"
    bun install
    echo -e "${GREEN}  ✓ Dependencies installed successfully${NC}"
fi
echo ""

# ---- Step 3: Auto-update from GitHub ----
echo -e "${YELLOW}[3/5]${NC} Checking for updates from GitHub..."
REPO_URL="https://github.com/BlackAngelSk/multimedia-explorer-apikey.git"
if [ -d ".git" ]; then
    # Temporarily disable set -e so git errors don't kill the script
    set +e
    # Ensure the remote points to the correct repo
    CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null)
    if [ "$CURRENT_REMOTE" != "$REPO_URL" ] && [ "$CURRENT_REMOTE" != "${REPO_URL%.git}" ]; then
        echo -e "${CYAN}  → Setting remote origin to $REPO_URL${NC}"
        git remote set-url origin "$REPO_URL" 2>/dev/null
    fi
    git fetch origin 2>/dev/null
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/$(git branch --show-current 2>/dev/null || echo "main") 2>/dev/null)
    if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
        echo -e "${CYAN}  → New updates available. Pulling...${NC}"
        git stash 2>/dev/null
        git pull origin "$(git branch --show-current 2>/dev/null || echo "main")" --quiet 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}  ✓ Updated to latest version${NC}"
            # Re-install dependencies in case packages changed
            echo -e "${CYAN}  → Running bun install after update...${NC}"
            bun install 2>/dev/null
            echo -e "${GREEN}  ✓ Dependencies updated${NC}"
            # Restore any stashed changes
            git stash pop 2>/dev/null
        else
            echo -e "${RED}  ✗ Could not pull updates (merge conflict?)${NC}"
            echo -e "${YELLOW}  → Continuing with local version${NC}"
            git stash pop 2>/dev/null
        fi
    else
        echo -e "${GREEN}  ✓ Already up to date${NC}"
    fi
    set -e
else
    echo -e "${YELLOW}  ⚠ Not a git repository — skipping update${NC}"
fi
echo ""

# ---- Step 4: Create .env file if missing ----
echo -e "${YELLOW}[4/5]${NC} Checking environment configuration..."
if [ -f ".env" ]; then
    echo -e "${GREEN}  ✓ .env file already exists${NC}"
else
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}  ✓ Created .env from .env.example${NC}"
    else
        touch .env
        echo -e "${GREEN}  ✓ Created empty .env file${NC}"
    fi
fi
echo ""

# ---- Step 5: Start dev server ----
echo -e "${YELLOW}[5/5]${NC} Starting development server..."
echo -e "${CYAN}  → Server will start at http://localhost:3000${NC}"
echo -e "${CYAN}  → Press Ctrl+C to stop${NC}"
echo ""

# Kill any existing next dev processes to avoid lock conflicts
pkill -f "next dev" 2>/dev/null || true
rm -f .next/dev/lock 2>/dev/null || true

# Open browser after a short delay (in background)
(sleep 3 && (xdg-open http://localhost:3000 2>/dev/null || open http://localhost:3000 2>/dev/null || true)) &

# Start the dev server
bun run dev