#!/bin/bash

# Script to check and fix library layout conventions
# Usage: fix-library-layout.sh [--fix]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FIX_MODE=false
if [[ "$1" == "--fix" ]]; then
    FIX_MODE=true
fi

ERRORS=0
FIXED=0

echo "🔍 Checking library layout conventions..."
echo

# Check if we're in a project with src/lib
if [ ! -d "src/lib" ]; then
    echo "No src/lib directory found. Skipping library checks."
    exit 0
fi

# Function to check if file exists
check_file() {
    local file="$1"
    local required="$2"

    if [ ! -f "$file" ]; then
        if [ "$required" == "true" ]; then
            echo -e "${RED}✗${NC} Missing required file: $file"
            return 1
        else
            echo -e "${YELLOW}⚠${NC}  Missing optional file: $file"
            return 2
        fi
    fi
    return 0
}

# Function to check namespace export pattern
check_namespace_export() {
    local file="$1"
    local lib_name="$2"
    local pascal_name="$3"

    if [ -f "$file" ]; then
        if ! grep -q "export \* as $pascal_name from './\$\$" "$file"; then
            echo -e "${RED}✗${NC} Invalid namespace export in $file"
            echo "    Expected: export * as $pascal_name from './\$\$.js' (or .ts)"
            return 1
        fi
    fi
    return 0
}

# Function to check package.json import mappings
check_import_mappings() {
    local lib_name="$1"

    if [ ! -f "package.json" ]; then
        return 0
    fi

    local expected_namespace="#lib/$lib_name"
    local expected_barrel="#lib/$lib_name/$lib_name"

    if ! grep -q "\"$expected_namespace\":" package.json; then
        echo -e "${RED}✗${NC} Missing import mapping: $expected_namespace"
        return 1
    fi

    if ! grep -q "\"$expected_barrel\":" package.json; then
        echo -e "${RED}✗${NC} Missing import mapping: $expected_barrel"
        return 1
    fi

    return 0
}

# Function to convert kebab-case to PascalCase
to_pascal_case() {
    echo "$1" | perl -pe 's/(^|-)(\w)/\U$2/g'
}

# Function to create namespace file
create_namespace_file() {
    local lib_dir="$1"
    local pascal_name="$2"

    cat > "$lib_dir/$.ts" << EOF
/**
 * Namespace export for $pascal_name
 */
export * as $pascal_name from './\$\$.js'
EOF
    echo -e "${GREEN}✓${NC} Created $lib_dir/$.ts"
    ((FIXED++))
}

# Function to create barrel file
create_barrel_file() {
    local lib_dir="$1"

    cat > "$lib_dir/\$\$.ts" << EOF
/**
 * Barrel exports
 */
export * from './${lib_name}.js'
EOF
    echo -e "${GREEN}✓${NC} Created $lib_dir/\$\$.ts"
    ((FIXED++))
}

# Process each library
for lib_dir in src/lib/*/; do
    if [ ! -d "$lib_dir" ]; then
        continue
    fi

    lib_name=$(basename "$lib_dir")
    pascal_name=$(to_pascal_case "$lib_name")

    echo "📦 Checking library: $lib_name"

    # Check for required files
    namespace_file="$lib_dir\$.ts"
    barrel_file="$lib_dir\$\$.ts"

    # Check namespace file
    if ! check_file "$namespace_file" "true"; then
        ((ERRORS++))
        if [ "$FIX_MODE" == "true" ]; then
            create_namespace_file "$lib_dir" "$pascal_name"
        fi
    else
        # Check namespace export pattern
        if ! check_namespace_export "$namespace_file" "$lib_name" "$pascal_name"; then
            ((ERRORS++))
            if [ "$FIX_MODE" == "true" ]; then
                echo -e "${YELLOW}⚠${NC}  Cannot auto-fix namespace export pattern. Please fix manually."
            fi
        else
            echo -e "${GREEN}✓${NC} Namespace file valid: $namespace_file"
        fi
    fi

    # Check barrel file
    if ! check_file "$barrel_file" "true"; then
        ((ERRORS++))
        if [ "$FIX_MODE" == "true" ]; then
            create_barrel_file "$lib_dir"
        fi
    else
        echo -e "${GREEN}✓${NC} Barrel file exists: $barrel_file"
    fi

    # Check for bad patterns
    for bad_file in "$lib_dir"types.ts "$lib_dir"utils.ts "$lib_dir"helpers.ts; do
        if [ -f "$bad_file" ]; then
            echo -e "${YELLOW}⚠${NC}  Found generic module name: $bad_file"
            echo "    Consider using domain-specific names"
        fi
    done

    # Check import mappings
    if ! check_import_mappings "$lib_name"; then
        ((ERRORS++))
        if [ "$FIX_MODE" == "true" ]; then
            echo -e "${YELLOW}⚠${NC}  Cannot auto-fix package.json mappings. Add manually:"
            echo "    \"#lib/$lib_name\": \"./src/lib/$lib_name/\$.ts\""
            echo "    \"#lib/$lib_name/$lib_name\": \"./src/lib/$lib_name/\$\$.ts\""
        fi
    else
        echo -e "${GREEN}✓${NC} Import mappings configured"
    fi

    echo
done

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$FIX_MODE" == "true" ]; then
    echo "📊 Fixed $FIXED issue(s)"
    if [ $ERRORS -gt $FIXED ]; then
        echo "⚠️  $((ERRORS - FIXED)) issue(s) require manual fixes"
    fi
else
    if [ $ERRORS -gt 0 ]; then
        echo "❌ Found $ERRORS issue(s)"
        echo "   Run with --fix to auto-fix some issues"
    else
        echo "✅ All libraries follow conventions!"
    fi
fi

exit $([ $ERRORS -eq 0 ] && echo 0 || echo 1)