---
argument-hint: '[message] [--push] [--staged] [--skip-checks]'
description: Run checks and create semver-compliant commit
---

# Commit

## Goal

Create a well-formatted, semver-compliant commit after running all project quality checks.

## Usage

- `/commit` - Run checks, stage all changes, commit with auto-generated message
- `/commit "message"` - Use specific commit message
- `/commit --push` - Commit and push to remote
- `/commit --staged` - Only commit already-staged files
- `/commit --skip-checks` - Skip quality checks (use cautiously)
- `/commit "feat: add feature" --push` - Custom message with push

## Arguments

- All arguments: $ARGUMENTS
- Flags: `--push`, `--staged`, `--skip-checks`
- Message: Any non-flag argument is treated as commit message

## Instructions

### 1. Parse Arguments

Extract flags and message from $ARGUMENTS:
- `--push`: Will push after commit
- `--staged`: Only commit staged files (skip staging step)
- `--skip-checks`: Skip quality checks
- Remaining text: Custom commit message

### 2. Run Quality Checks (unless --skip-checks)

**CRITICAL**: Intelligently detect and run project quality scripts:

```bash
# Detect available scripts from package.json
SCRIPTS=$(cat package.json | grep -E '"(fix|check|test)[^"]*":' | sed 's/.*"\([^"]*\)".*/\1/')

# Run in order: fix, check, test
# 1. Run all fix:* scripts (formatting, auto-fixes)
pnpm run '/fix:.*/' 2>/dev/null || pnpm fix 2>/dev/null || echo "No fix scripts"

# 2. Run all check:* scripts (types, lint, validation)
pnpm run '/check:.*/' 2>/dev/null || pnpm check 2>/dev/null || echo "No check scripts"

# 3. Run tests with --run flag (never watch mode)
pnpm test --run 2>/dev/null || pnpm test:unit --run 2>/dev/null || echo "No test scripts"
```

**If any check fails**:
- STOP immediately
- Report which check failed
- Show error output
- Ask user how to proceed

### 3. Analyze Changes for Commit Message (if no custom message)

**Only if user didn't provide custom message**, analyze git diff to generate semver commit:

```bash
# Get staged and unstaged changes
git status
git diff HEAD --stat
git diff HEAD
```

**Determine commit type from changes**:
- `feat:` - New features, new functions/exports, significant additions
- `fix:` - Bug fixes, corrections, error handling
- `refactor:` - Code restructuring without behavior change
- `perf:` - Performance improvements
- `test:` - Test additions/changes
- `docs:` - Documentation only
- `chore:` - Maintenance, deps, build config
- `style:` - Formatting, whitespace (no logic change)

**Check recent commits for style**:
```bash
git log --oneline -10
```

**Generate message following patterns**:
- Use conventional commit format: `type(scope): description`
- Scope is optional but useful (e.g., `feat(arr): add partition function`)
- Keep description concise, imperative mood ("add" not "added")
- Multi-line: summary line + blank + details if needed

**Breaking changes**: Add `!` after type if breaking: `feat(api)!: change signature`

### 4. Stage Files (unless --staged)

If NOT using `--staged` flag:
```bash
# Stage all changes (staged + unstaged)
git add -A
```

If using `--staged` flag:
- Skip staging step
- Only commit what's already staged

### 5. Create Commit

**Use heredoc for proper message formatting**:
```bash
git commit -m "$(cat <<'EOF'
<commit message here>
EOF
)"
```

**Verify commit created**:
```bash
git log -1 --oneline
```

### 6. Push (if --push flag)

If `--push` flag present:
```bash
git push
```

### 7. Summary

Report:
- ✅ Checks passed (or skipped)
- ✅ Files staged (or used existing staging)
- ✅ Commit created: `<commit hash and message>`
- ✅ Pushed to remote (if applicable)

## Examples

### Example 1: Auto-commit with checks
```
/commit
```
- Runs all fix/check/test scripts
- Analyzes diff, generates: `feat(obj): add mapValues function`
- Stages all changes
- Creates commit

### Example 2: Custom message with push
```
/commit "fix(test): correct assertion logic" --push
```
- Runs quality checks
- Uses provided message
- Stages all changes
- Commits and pushes

### Example 3: Quick commit without checks
```
/commit "chore: update deps" --skip-checks --push
```
- Skips all quality checks
- Uses provided message
- Stages all, commits, and pushes

### Example 4: Commit only staged files
```
/commit --staged
```
- Runs quality checks
- Only commits files already in staging area
- Auto-generates message from staged changes

## Semver Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

**Types**:
- `feat`: New feature (MINOR version bump)
- `fix`: Bug fix (PATCH version bump)
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes bug nor adds feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `build`: Changes to build system or dependencies
- `ci`: Changes to CI configuration
- `chore`: Other changes that don't modify src or test files
- `revert`: Reverts a previous commit

**Breaking changes** (MAJOR version bump):
- Add `!` after type/scope: `feat!: breaking change`
- Or add `BREAKING CHANGE:` footer

## Best Practices

1. **Always run checks** unless you have a good reason to skip
2. **Review staged changes** before committing
3. **Use descriptive scopes** when relevant (module name, file name)
4. **Keep commits atomic** - one logical change per commit
5. **Push carefully** - review before using `--push`
6. **Test before commit** - the workflow runs tests automatically

## Error Handling

**If quality checks fail**:
- Show which script failed and output
- DO NOT commit
- Ask user: "Fix issues or commit anyway with --skip-checks?"

**If no changes to commit**:
- Report: "No changes to commit"
- Show git status

**If commit fails**:
- Show git error
- Check for issues (empty message, pre-commit hooks, etc.)

## CRITICAL Rules

- NEVER skip quality checks without user explicitly using `--skip-checks`
- NEVER push without `--push` flag
- ALWAYS use heredoc for commit messages (handles multi-line properly)
- ALWAYS verify commit was created with `git log -1`
- Follow project's commit style from recent git log
