#!/bin/bash
# ============================================
#  Multimedia Explorer - Setup & Start Script
#  For Linux / macOS
# ============================================

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
echo -e "${YELLOW}[1/4]${NC} Checking for bun..."
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
echo -e "${YELLOW}[2/4]${NC} Installing dependencies..."
if [ -d "node_modules" ]; then
    echo -e "${GREEN}  ✓ Dependencies already installed (node_modules exists)${NC}"
else
    echo -e "${CYAN}  → Running bun install...${NC}"
    bun install
    echo -e "${GREEN}  ✓ Dependencies installed successfully${NC}"
fi
echo ""

# ---- Step 3: Create .env file if missing ----
echo -e "${YELLOW}[3/4]${NC} Checking environment configuration..."
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

# ---- Step 4: Start dev server ----
echo -e "${YELLOW}[4/4]${NC} Starting development server..."
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
