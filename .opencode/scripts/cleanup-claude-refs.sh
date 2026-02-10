#!/usr/bin/env bash
set -euo pipefail

# cleanup-claude-refs.sh
# Replaces all "OpenCode" references with "OpenCode" throughout the repository
# This script performs the following replacements:
#   - "OpenCode" -> "OpenCode"
#   - ".opencode/" -> ".opencode/"
#   - "OPENCODE_" -> "OPENCODE_"
#   - "@opencode" -> "@opencode"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🧹 OpenCode Reference Cleanup Script"
echo "====================================="
echo "Project root: $PROJECT_ROOT"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
total_files=0
total_replacements=0

# Arrays to track changes
declare -a modified_files=()

# Files to exclude from replacement
EXCLUDE_DIRS=(
  "node_modules"
  ".git"
  "dist"
  "build"
  ".next"
  ".opencode/data"
  ".opencode/logs"
)

# File extensions to process
INCLUDE_EXTS=(
  "*.md"
  "*.ts"
  "*.js"
  "*.json"
  "*.yaml"
  "*.yml"
  "*.sh"
  "*.txt"
)

# Build exclude pattern for find command
exclude_pattern=""
for dir in "${EXCLUDE_DIRS[@]}"; do
  exclude_pattern="$exclude_pattern -path '*/$dir/*' -prune -o"
done

# Build include pattern for find command
include_pattern=""
for ext in "${INCLUDE_EXTS[@]}"; do
  if [ -z "$include_pattern" ]; then
    include_pattern="-name '$ext'"
  else
    include_pattern="$include_pattern -o -name '$ext'"
  fi
done

echo "📂 Scanning for files to process..."
echo ""

# Function to process a single file
process_file() {
  local file="$1"
  local changes=0
  local temp_file="${file}.tmp"

  # Skip if file doesn't exist or is not readable
  if [ ! -f "$file" ] || [ ! -r "$file" ]; then
    return 0
  fi

  # Create temporary file with replacements
  sed -E \
    -e 's/OpenCode/OpenCode/g' \
    -e 's/\.claude\//\.opencode\//g' \
    -e 's/OPENCODE_/OPENCODE_/g' \
    -e 's/@opencode/@opencode/g' \
    -e 's/opencode/opencode/g' \
    "$file" >"$temp_file"

  # Check if file was modified
  if ! cmp -s "$file" "$temp_file"; then
    # Count number of changes
    changes=$(diff -U 0 "$file" "$temp_file" | grep -c '^[+-]' || true)
    changes=$((changes / 2)) # Each change shows as 2 lines (- and +)

    # Move temp file over original
    mv "$temp_file" "$file"

    # Track modified file
    modified_files+=("$file")
    total_replacements=$((total_replacements + changes))

    echo -e "${GREEN}✓${NC} $(basename "$file") - $changes replacements"
  else
    # No changes, remove temp file
    rm -f "$temp_file"
  fi

  total_files=$((total_files + 1))
}

# Find and process all matching files
while IFS= read -r -d '' file; do
  # Skip binary files
  if file "$file" | grep -q "text"; then
    process_file "$file"
  fi
done < <(find "$PROJECT_ROOT" \
  $exclude_pattern \
  -type f \( -name "*.md" -o -name "*.ts" -o -name "*.js" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.sh" -o -name "*.txt" \) \
  -print0)

echo ""
echo "======================================="
echo -e "${GREEN}✓ Cleanup Complete!${NC}"
echo ""
echo "📊 Summary:"
echo "   Files processed: $total_files"
echo "   Files modified: ${#modified_files[@]}"
echo "   Total replacements: $total_replacements"
echo ""

# List modified files
if [ ${#modified_files[@]} -gt 0 ]; then
  echo "📝 Modified files:"
  for file in "${modified_files[@]}"; do
    relative_path="${file#$PROJECT_ROOT/}"
    echo "   - $relative_path"
  done
  echo ""
fi

# Manual review checklist
echo "📋 Manual Review Checklist:"
echo ""
echo "   [ ] Review git diff to verify changes"
echo "   [ ] Check that no unintended replacements were made"
echo "   [ ] Verify all documentation is consistent"
echo "   [ ] Test OpenCode with new configuration"
echo "   [ ] Update any external references (URLs, links)"
echo ""

# Suggest next steps
echo "💡 Next Steps:"
echo ""
echo "   1. Review changes:  git diff"
echo "   2. Test plugins:    cd .opencode && bun install"
echo "   3. Commit changes:  git add -A && git commit -m 'refactor: replace OpenCode references with OpenCode'"
echo ""

# Exit successfully
exit 0
