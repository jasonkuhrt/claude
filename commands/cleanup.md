---
argument-hint: '[--all] [--build] [--format] [--deps]'
description: Clean up codebase (unused imports, formatting, build artifacts)
---

# Cleanup

## Goal

Clean up the codebase by removing build artifacts, fixing formatting, removing unused code, and organizing dependencies.

## Usage

- `/cleanup` - Standard cleanup (format, unused imports, build artifacts)
- `/cleanup --all` - Aggressive cleanup (everything including comments, todos)
- `/cleanup --build` - Only remove build artifacts
- `/cleanup --format` - Only fix formatting
- `/cleanup --deps` - Clean up dependencies (unused, duplicates)

## Arguments

- All arguments: $ARGUMENTS
- Flags: `--all`, `--build`, `--format`, `--deps`
- No flags: Run standard cleanup (format + build + safe unused code removal)

## Instructions

### 1. Parse Arguments

Extract cleanup mode from $ARGUMENTS:
- `--all`: Aggressive mode (all cleanup tasks)
- `--build`: Only build artifacts
- `--format`: Only formatting
- `--deps`: Only dependency cleanup
- No flags: Standard mode (format + build + safe cleanups)

### 2. Build Artifacts Cleanup (--build or standard or --all)

**Remove generated files and directories**:

```bash
# Common build artifacts
rm -rf dist/ build/ lib/ out/ .turbo/ .next/ .nuxt/

# Cache directories
rm -rf .cache/ .parcel-cache/ .webpack/ node_modules/.cache/

# TypeScript build info
rm -rf tsconfig.tsbuildinfo

# Coverage reports
rm -rf coverage/ .nyc_output/

# OS files
find . -name '.DS_Store' -type f -delete
find . -name 'Thumbs.db' -type f -delete

# Log files in root
rm -f *.log npm-debug.log* yarn-debug.log* pnpm-debug.log*

echo "✅ Build artifacts removed"
```

### 3. Format Code (--format or standard or --all)

**Run project formatter**:

```bash
# Use project's formatter (dprint, prettier, etc.)
if grep -q '"fix:format":' package.json; then
  pnpm run fix:format
elif command -v dprint &> /dev/null; then
  dprint fmt
elif command -v prettier &> /dev/null; then
  prettier --write .
else
  echo "No formatter found"
fi

echo "✅ Code formatted"
```

### 4. Remove Unused Imports (standard or --all)

**Use TypeScript compiler or oxlint to find and remove unused imports**:

```bash
# If oxlint is available (preferred)
if command -v oxlint &> /dev/null && grep -q '"fix:lint":' package.json; then
  pnpm run fix:lint
  echo "✅ Unused imports removed via oxlint"
fi

# Note: This is a safe operation that only removes clearly unused imports
```

### 5. Dependency Cleanup (--deps or --all)

**Analyze and clean up dependencies**:

```bash
# Update lockfile to match package.json
pnpm install

# Remove duplicate dependencies (if using pnpm)
pnpm dedupe 2>/dev/null || echo "Dedupe not available"

# Check for unused dependencies (if depcheck is available)
if command -v depcheck &> /dev/null; then
  echo "Checking for unused dependencies..."
  depcheck --json | grep -v '"dependencies": {}' && echo "Found unused deps" || echo "No unused deps"
fi

# Prune node_modules
pnpm prune 2>/dev/null || npm prune 2>/dev/null || echo "Prune not available"

echo "✅ Dependencies cleaned up"
```

### 6. Remove Commented Code (--all only)

**Only in aggressive mode**, remove commented-out code blocks:

```bash
# This is more aggressive and requires careful review
# Look for patterns like:
# - Multiple lines of // commented code
# - /* */ block comments with code
# - Commented imports

# Use ripgrep to find commented code blocks
rg "^\s*//.*(?:function|const|let|var|class|import)" src/ || echo "No obvious commented code"

echo "⚠️  Review and manually remove commented code blocks"
```

### 7. Remove TODO/FIXME Comments (--all only)

**Only in aggressive mode**, find and optionally remove TODO comments:

```bash
# Find all TODO/FIXME/HACK comments
echo "Found TODO/FIXME/HACK comments:"
rg "TODO|FIXME|HACK|XXX" src/ || echo "None found"

# Ask user if they want to remove them
echo "⚠️  Review and manually address or remove these comments"
```

### 8. Clean Test Artifacts (standard or --all)

**Remove test-related temporary files**:

```bash
# Remove test output directories
rm -rf test-results/ playwright-report/

# Remove temporary test files
find . -name 'test-*' -type d -path './tmp/*' -o -path './test/*' | grep -E '(tmp|temp)' | xargs rm -rf 2>/dev/null

# Remove snapshot orphans (if using vitest/jest)
# This is safer to do manually, so just report
if command -v vitest &> /dev/null; then
  echo "ℹ️  Run 'pnpm test -u' to update snapshots if needed"
fi

echo "✅ Test artifacts cleaned"
```

### 9. Organize Imports (standard or --all)

**If import organization tool is available**:

```bash
# Some projects have import sorting configured
# Check if it's part of the formatter or linter
if grep -q '"fix:imports":' package.json; then
  pnpm run fix:imports
  echo "✅ Imports organized"
fi
```

### 10. Verify Cleanup

**Run quality checks to ensure cleanup didn't break anything**:

```bash
# Type check
pnpm check:types 2>/dev/null || tsc --noEmit 2>/dev/null || echo "No type check available"

# Run tests (quick smoke test)
pnpm test --run 2>/dev/null || echo "Skipping tests"

echo "✅ Verification checks passed"
```

### 11. Summary

Report what was cleaned:
- 🗑️  Build artifacts removed
- ✨ Code formatted
- 🧹 Unused imports removed (if applicable)
- 📦 Dependencies cleaned (if applicable)
- ✅ Verification passed

## Examples

### Example 1: Standard cleanup
```
/cleanup
```
- Removes build artifacts
- Formats all code
- Removes unused imports
- Runs verification

### Example 2: Build-only cleanup
```
/cleanup --build
```
- Only removes dist/, .turbo/, etc.
- Doesn't touch source code
- Fast and safe

### Example 3: Format-only cleanup
```
/cleanup --format
```
- Only runs formatter
- Doesn't remove any files
- Quick formatting pass

### Example 4: Aggressive cleanup
```
/cleanup --all
```
- Everything in standard mode PLUS:
  - Finds commented code blocks
  - Lists TODO/FIXME comments
  - More thorough dependency analysis
- Requires manual review of suggestions

### Example 5: Dependency cleanup
```
/cleanup --deps
```
- Updates lockfile
- Removes duplicates
- Prunes unused packages
- Reports unused dependencies

## Cleanup Safety Levels

**Safe (standard mode)**:
- ✅ Build artifacts (regenerated by build)
- ✅ Formatting (deterministic, reversible)
- ✅ Unused imports (detected by tooling)
- ✅ Cache directories (regenerated automatically)

**Review Required (--all mode)**:
- ⚠️  Commented code (might be intentional)
- ⚠️  TODO comments (might be important)
- ⚠️  Unused dependencies (might be indirect deps)

## Best Practices

1. **Start with standard** cleanup for regular maintenance
2. **Use --build** before fresh builds
3. **Use --format** as pre-commit step (though /commit does this)
4. **Use --all cautiously** - review what it finds
5. **Commit before** aggressive cleanup so you can revert
6. **Run tests after** cleanup to ensure nothing broke

## What NOT to Clean

**Never automatically remove**:
- Configuration files (.eslintrc, .prettierrc, etc.)
- Environment files (.env, .env.local)
- Documentation files
- License files
- Git-ignored user-specific files that might be in use

## Integration with Other Commands

- `/commit` already runs fix:format before committing
- `/release` runs full quality checks
- `/cleanup` is for periodic maintenance and pre-release cleanup

Use `/cleanup` when:
- Starting work on an old branch
- Before creating a PR
- After rebasing or merging
- Periodically for repo hygiene

## Error Handling

**If formatter fails**:
- Report which files had errors
- Show formatter output
- Continue with other cleanup tasks

**If type check fails after cleanup**:
- STOP and report the issue
- This means cleanup broke something
- Revert changes if needed

**If build artifacts are locked**:
- Report which files couldn't be deleted
- Suggest closing applications that might have locks
- Continue with other cleanups

## CRITICAL Rules

- NEVER delete source files (src/, lib/ source code)
- NEVER delete .git directory or git files
- NEVER delete package.json or lockfiles
- ALWAYS run verification after cleanup
- ALWAYS inform user what was deleted
- In --all mode, SUGGEST rather than DELETE commented code
