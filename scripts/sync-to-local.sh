#!/usr/bin/env bash
set -euo pipefail

# sync-to-local.sh - Sync organization standards to local development directories
# Usage: ./sync-to-local.sh [TARGET_DIR]
# Default TARGET_DIR: ~/Development/Github

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORG_STANDARDS_DIR="$SCRIPT_DIR/.."
TARGET_DIR="${1:-$HOME/Development/Github}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🔄 Syncing organization standards"
echo "=================================="
echo "Source: $ORG_STANDARDS_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Copy base AGENTS.md
if [[ -f "$ORG_STANDARDS_DIR/github-harness/AGENTS.md" ]]; then
    echo "📄 Copying base AGENTS.md..."
    cp "$ORG_STANDARDS_DIR/github-harness/AGENTS.md" "$TARGET_DIR/AGENTS.md"
    echo -e "${GREEN}✓${NC} Base AGENTS.md synced"
else
    echo "⚠ Source AGENTS.md not found at $ORG_STANDARDS_DIR/github-harness/AGENTS.md"
    exit 1
fi

# Verify all per-repo AGENTS.md files reference the base
echo ""
echo "🔍 Verifying per-repo AGENTS.md references..."

find "$TARGET_DIR" -mindepth 2 -name "AGENTS.md" -type f | while read -r file; do
    REL_PATH="${file#$TARGET_DIR/}"
    
    if grep -q "MANDATORY READ" "$file" && grep -q "AGENTS.md" "$file"; then
        echo -e "  ${GREEN}✓${NC} $REL_PATH"
    else
        echo -e "  ${YELLOW}⚠${NC} $REL_PATH - missing mandatory read notice"
        echo "    To fix, add this at the top of the file:"
        echo '    > **MANDATORY READ**: This repository is governed by [`~/Development/Github/AGENTS.md`](../AGENTS.md) (organization-wide rules). Per-repo rules below provide project-specific details but **cannot override** organization rules.'
    fi
done

echo ""
echo -e "${GREEN}✅ Sync complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Commit with: git add AGENTS.md && git commit -m 'chore(standards): sync org-wide AGENTS.md'"
echo "  3. Push to remote: git push"
