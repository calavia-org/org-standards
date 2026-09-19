#!/usr/bin/env bash
set -euo pipefail

# verify-agents.sh - Validate AGENTS.md files across the organization
# Usage: ./verify-agents.sh [BASE_DIR]
# Default BASE_DIR: ~/Development/Github

BASE_DIR="${1:-$HOME/Development/Github}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo "🔍 Verifying AGENTS.md files in: $BASE_DIR"
echo "================================================"

# Check if base AGENTS.md exists
if [[ ! -f "$BASE_DIR/AGENTS.md" ]]; then
    echo -e "${RED}✗ MISSING${NC}: Base AGENTS.md not found at $BASE_DIR/AGENTS.md"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓${NC} Base AGENTS.md found"
fi

# Find all AGENTS.md files
AGENTS_FILES=$(find "$BASE_DIR" -name "AGENTS.md" -type f | sort)
TOTAL=$(echo "$AGENTS_FILES" | wc -l | tr -d ' ')

echo ""
echo "Found $TOTAL AGENTS.md files"
echo ""

# Check each AGENTS.md
while IFS= read -r file; do
    REL_PATH="${file#$BASE_DIR/}"
    IS_BASE=false
    
    if [[ "$REL_PATH" == "AGENTS.md" ]]; then
        IS_BASE=true
    fi
    
    echo "Checking: $REL_PATH"
    
    # Check for mandatory read notice (skip base file)
    if [[ "$IS_BASE" == false ]]; then
        if grep -q "MANDATORY READ" "$file" && grep -q "AGENTS.md" "$file"; then
            echo -e "  ${GREEN}✓${NC} References parent AGENTS.md"
        else
            echo -e "  ${RED}✗ MISSING${NC}: Mandatory read notice not found"
            echo -e "  ${YELLOW}  Add:${NC} > **MANDATORY READ**: This repository is governed by [...]"
            ERRORS=$((ERRORS + 1))
        fi
    fi
    
    # Check for conventional commits reference
    if grep -q "conventional commit" "$file" || grep -q "Conventional Commits" "$file"; then
        echo -e "  ${GREEN}✓${NC} References conventional commits"
    else
        echo -e "  ${YELLOW}⚠ WARNING${NC}: No conventional commits reference"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check for branch naming reference
    if grep -q "feat/" "$file" || grep -q "fix/" "$file" || grep -q "branch naming" "$file"; then
        echo -e "  ${GREEN}✓${NC} References branch naming conventions"
    else
        echo -e "  ${YELLOW}⚠ WARNING${NC}: No branch naming conventions reference"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check file is not empty
    if [[ ! -s "$file" ]]; then
        echo -e "  ${RED}✗ EMPTY${NC}: File is empty"
        ERRORS=$((ERRORS + 1))
    fi
    
done <<< "$AGENTS_FILES"

# Check manifest references
echo ""
echo "================================================"
echo "📋 Checking manifest..."

if [[ -f "$SCRIPT_DIR/../manifest.md" ]]; then
    MANIFEST="$SCRIPT_DIR/../manifest.md"
    
    while IFS= read -r file; do
        REL_PATH="${file#$BASE_DIR/}"
        
        # Skip base file in manifest check
        if [[ "$REL_PATH" == "AGENTS.md" ]]; then
            continue
        fi
        
        # Check if repo is in manifest
        REPO_NAME=$(basename "$(dirname "$file")")
        if grep -q "$REPO_NAME" "$MANIFEST" || grep -q "$REL_PATH" "$MANIFEST"; then
            echo -e "${GREEN}✓${NC} $REL_PATH listed in manifest"
        else
            echo -e "${YELLOW}⚠ WARNING${NC}: $REL_PATH not found in manifest.md"
            WARNINGS=$((WARNINGS + 1))
        fi
    done <<< "$AGENTS_FILES"
else
    echo -e "${YELLOW}⚠ WARNING${NC}: manifest.md not found"
    WARNINGS=$((WARNINGS + 1))
fi

# Summary
echo ""
echo "================================================"
echo "📊 Summary"
echo "================================================"
echo "Files checked: $TOTAL"
echo -e "Errors: ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [[ $ERRORS -gt 0 ]]; then
    echo ""
    echo -e "${RED}❌ FAILED${NC}: Fix errors before continuing"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠ PASSED with warnings${NC}"
    exit 0
else
    echo ""
    echo -e "${GREEN}✅ ALL CHECKS PASSED${NC}"
    exit 0
fi
