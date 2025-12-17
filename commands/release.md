---
argument-hint: '[version] [--dry-run] [--no-push]'
description: Release new version with automated workflow
---

# Release

## Goal

Automate the release process with version bumping, quality checks, git tagging, and publishing.

## Usage

- `/release` - Auto-determine version bump (patch/minor/major) and release
- `/release patch` - Release patch version (e.g., 1.2.3 → 1.2.4)
- `/release minor` - Release minor version (e.g., 1.2.3 → 1.3.0)
- `/release major` - Release major version (e.g., 1.2.3 → 2.0.0)
- `/release 2.0.0` - Release specific version
- `/release --dry-run` - Preview what would happen without making changes
- `/release --no-push` - Create release locally but don't push

## Arguments

- All arguments: $ARGUMENTS
- First argument ($1): Version bump type (`patch`, `minor`, `major`) or specific version (e.g., `2.0.0`)
- Flags: `--dry-run`, `--no-push`

## Instructions

### 1. Parse Arguments

Extract version and flags from $ARGUMENTS:
- Version: First non-flag argument (patch/minor/major/X.Y.Z)
- `--dry-run`: Preview mode, no actual changes
- `--no-push`: Skip push to remote

### 2. Determine Version Bump

**If no version argument provided**, analyze commits since last tag:

```bash
# Get current version from package.json
CURRENT=$(cat package.json | grep '"version"' | sed 's/.*"version": "\(.*\)".*/\1/')

# Get commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Determine bump type from conventional commits:
# - Contains "BREAKING CHANGE" or "!" after type: MAJOR
# - Contains "feat:": MINOR
# - Contains "fix:" or other types: PATCH
```

**If specific version provided** (e.g., `2.0.0`):
- Use that version directly
- Validate it's higher than current version

### 3. Dry Run Preview (if --dry-run)

If `--dry-run` flag present:
- Show current version
- Show what new version would be
- Show commits that would be included
- Show what commands would run
- EXIT without making changes

### 4. Run Quality Checks

**Full quality check suite**:

```bash
# 1. Run all fix scripts
pnpm run '/fix:.*/' || pnpm fix || echo "No fix scripts"

# 2. Run all check scripts
pnpm run '/check:.*/' || pnpm check || echo "No check scripts"

# 3. Run tests with --run flag
pnpm test --run || pnpm test:unit --run || echo "No test scripts"

# 4. Check for circular dependencies if script exists
pnpm check:package:circular 2>/dev/null || echo "No circular check"

# 5. Build the project to ensure it compiles
pnpm build || echo "No build script"
```

**If any check fails**:
- STOP immediately
- Report which check failed
- Show error output
- Ask user how to proceed

### 5. Update Version

**Check if using a version management tool**:

```bash
# Check for dripip (preferred in CLAUDE.md)
if command -v dripip &> /dev/null; then
  # Use dripip for stable release
  dripip stable
else
  # Manual version bump
  # Update package.json version
  npm version $NEW_VERSION --no-git-tag-version

  # If using pnpm workspace, update lockfile
  pnpm install --lockfile-only
fi
```

### 6. Generate Changelog Entry

**Create or update CHANGELOG.md**:

```bash
# Get commits since last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"- %s (%h)" --reverse)

# Categorize by conventional commit type
# - Breaking Changes
# - Features
# - Bug Fixes
# - Other Changes
```

**Format**:
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Breaking Changes
- feat!: breaking change description (abc123)

### Features
- feat(scope): feature description (def456)

### Bug Fixes
- fix(scope): fix description (ghi789)

### Other Changes
- chore: other change (jkl012)
```

### 7. Commit Version Changes

```bash
# Stage version-related files
git add package.json package-lock.json pnpm-lock.yaml CHANGELOG.md

# Commit with release message
git commit -m "$(cat <<'EOF'
chore(release): v$NEW_VERSION
EOF
)"
```

### 8. Create Git Tag

```bash
# Create annotated tag with version
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

# Verify tag created
git tag -l "v$NEW_VERSION"
```

### 9. Push (unless --no-push)

If NOT using `--no-push` flag:

```bash
# Push commits and tags together
git push && git push --tags
```

### 10. Publish (if publish script exists)

**Check for publish script**:

```bash
# If package has publish script, run it
if grep -q '"publish":' package.json; then
  pnpm publish
fi
```

### 11. Summary

Report:
- ✅ Quality checks passed
- ✅ Version bumped: `$OLD_VERSION → $NEW_VERSION`
- ✅ CHANGELOG.md updated
- ✅ Git commit created
- ✅ Git tag created: `v$NEW_VERSION`
- ✅ Pushed to remote (if applicable)
- ✅ Published to npm (if applicable)

## Examples

### Example 1: Auto-release with patch
```
/release
```
- Analyzes commits (finds only fixes)
- Bumps patch: 1.2.3 → 1.2.4
- Runs full quality checks
- Updates changelog
- Commits, tags, pushes

### Example 2: Minor release preview
```
/release minor --dry-run
```
- Shows: 1.2.3 → 1.3.0
- Lists commits to include
- Shows what would happen
- Makes NO changes

### Example 3: Major release without push
```
/release major --no-push
```
- Bumps major: 1.2.3 → 2.0.0
- Runs checks, updates files
- Commits and tags locally
- Does NOT push to remote

### Example 4: Specific version
```
/release 2.0.0-beta.1
```
- Sets version to exactly 2.0.0-beta.1
- Runs full workflow
- Tags and pushes

## Version Bump Rules

**Semantic Versioning (semver)**:
- **MAJOR** (X.0.0): Breaking changes, incompatible API changes
- **MINOR** (0.X.0): New features, backward-compatible
- **PATCH** (0.0.X): Bug fixes, backward-compatible

**Pre-release versions**:
- `2.0.0-alpha.1` - Alpha release
- `2.0.0-beta.1` - Beta release
- `2.0.0-rc.1` - Release candidate

**Build metadata**:
- `2.0.0+20250107` - Build metadata (doesn't affect precedence)

## Best Practices

1. **Always run dry-run first** for major releases: `/release major --dry-run`
2. **Review CHANGELOG** before finalizing release
3. **Test thoroughly** - the workflow runs full test suite
4. **Use conventional commits** to enable automatic version determination
5. **Don't skip checks** - they prevent broken releases
6. **Coordinate with team** for major releases
7. **Check CI** passes before releasing

## Error Handling

**If quality checks fail**:
- STOP immediately
- Show which check failed
- DO NOT proceed with release
- User must fix issues first

**If version is invalid**:
- Show error: "New version must be higher than current"
- Show current version
- Ask user to specify valid version

**If git tag already exists**:
- Show error: "Tag v$VERSION already exists"
- List existing tags
- Ask user to use different version

**If uncommitted changes exist**:
- Show git status
- Ask user to commit or stash changes first

## CRITICAL Rules

- NEVER release without passing all quality checks
- NEVER skip tests before release
- ALWAYS create annotated git tags (not lightweight)
- ALWAYS use conventional commit format for release commit
- VERIFY build succeeds before releasing
- Only auto-push after user confirmation (unless --no-push)
- Respect --dry-run flag - make NO changes in dry-run mode

## Integration with /commit

The `/release` command builds on `/commit` patterns but adds:
- Version management
- Changelog generation
- Git tagging
- Publishing workflow

For regular development, use `/commit`. For releases, use `/release`.
