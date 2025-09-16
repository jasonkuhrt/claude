# Fix Library Conventions

Review the current project's library structure against the documented conventions and fix any violations.

## Instructions

1. **Read the convention documents**:
   - Review `~/.claude/docs/conventions/library.md` for base library conventions
   - Review `~/.claude/docs/conventions/library-adt.md` for ADT-specific patterns if applicable

2. **Analyze the current project structure**:
   - Scan all directories under `src/lib/` (or similar library directories)
   - Identify the type of each library (Namespace Simple, Namespace Complex, Barrel, ADT Union)
   - Check for proper file structure ($.ts, $$.ts files)
   - Verify import/export patterns
   - Check package.json import mappings

3. **Identify violations**:
   - Missing required files ($.ts, $$.ts)
   - Incorrect namespace exports
   - Wrong import patterns (e.g., importing from own $.ts)
   - Missing or incorrect package.json import mappings
   - Generic module names at library root (types.ts, utils.ts, helpers.ts)
   - Incorrect ADT structure if applicable

4. **Fix violations**:
   - Create missing $.ts and $$.ts files with correct export patterns
   - Fix namespace export statements
   - Update package.json import mappings
   - Rename generic modules to domain-specific names
   - Reorganize files if structure is fundamentally wrong
   - Fix import statements that violate conventions

5. **Report what was done**:
   - List all violations found
   - Describe each fix applied
   - Note any issues that require manual intervention
   - Suggest any architectural improvements

## Context

This command replaces the old bash script approach with intelligent, context-aware fixing using Claude's understanding of the codebase and conventions. Unlike a script that can only pattern match, this approach understands the intent and can make appropriate decisions based on the actual code structure and purpose.