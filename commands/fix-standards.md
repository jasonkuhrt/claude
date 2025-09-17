---
argument-hint: '[path] [domain]'
description: Enforce project standards and conventions
---

# Fix Project Standard Violations

## Goal

- Ensure all code meets the project's standards and conventions
- Allow focused checking of specific domains of standards
- Fix violations automatically (not just report them)

## Usage

- `/fix-standards` - Check all standards in all src/ files
- `/fix-standards [path]` - Check all standards in specified path
- `/fix-standards [path] [domain]` - Check specific domain standards in specified path

## Examples

- `/fix-standards src/lib testing` - Check test standards in src/lib
- `/fix-standards . layout` - Check layout/import standards in entire project
- `/fix-standards src/template types` - Check TypeScript standards in template

## Arguments

- First argument ($1): Path to check (default: "src/")
- Second argument ($2): Domain to check (default: "all")
- Domains: `all` or any top-level heading (#) from CLAUDE.md files

## Required Reading

1. Fully read ~/.claude/docs/prompts/serena.md
2. Fully read ~/.claude/CLAUDE.md
3. If exists, fully read ./CLAUDE.md

## Instructions

1. **Validate inputs**:
   - Ensure path exists and is within project
   - Ensure domain is valid (tests/testing/imports/libraries/types/all)

2. **Apply domain-specific checks**:
   - Search ./CLAUDE.md (if exists) and ~/.claude/CLAUDE.md
   - Local CLAUDE.md takes precedence
   - If domain is 'all': enforce all conventions
   - Otherwise: enforce only conventions under matching heading

3. **Fix all violations found**