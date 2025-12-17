---
argument-hint: '[focus-area]'
description: Remind Claude of project conventions mid-conversation
---

# Remind Conventions

## Goal

- Refresh Claude's awareness of project and personal conventions during an ongoing conversation
- Provide a quick reset when conventions might have drifted from focus
- Optionally focus on specific convention areas

## Usage

- `/remind-conventions` - Refresh all conventions
- `/remind-conventions [focus-area]` - Focus on specific area (e.g., `/remind-conventions effect`, `/remind-conventions testing`)

## Arguments

- First argument ($1): Optional focus area (effect, testing, library, async, types, etc.)

## Instructions

1. **Silently re-read convention files**:
   - Personal: ~/.claude/CLAUDE.md (always exists)
   - Project: ./CLAUDE.md (check existence first with `test -f`)
   - Focus-specific docs if applicable:
     - For "library": ~/.claude/docs/conventions/library-*.md
     - For "testing": ~/.claude/docs/conventions/testing.md
     - For "effect": Review Effect-specific sections in project CLAUDE.md
   - DO NOT show file contents or errors

2. **Provide concise confirmation** (5-7 lines max):
   - State: "✓ Conventions refreshed"
   - List 3-5 key conventions relevant to current work or focus area
   - Use bullet points for clarity
   - Keep descriptions to one line each

3. **Focus area handling**:
   If focus area provided: "$ARGUMENTS"
   - Emphasize conventions for that specific area
   - Example focus areas:
     - "effect" - Effect patterns, Schema conventions, no async rules
     - "testing" - Test.suite usage, TDD for bugs, type testing patterns
     - "library" - $.ts/$$.ts structure, ADT patterns, import rules
     - "async" - No async in src/api and src/lib rules
     - "types" - TypeScript conventions, type parameter naming

4. **Return to work**:
   - End with: "Ready to continue with [current focus/task]"
   - Don't repeat full conventions unless specifically asked

## Example Output

```
✓ Conventions refreshed

Key reminders:
• ESM only - use .js extensions on all relative imports
• Effect Schema - use module pattern with make constructors, not classes
• Testing - use Test.suite for table-driven tests, never raw test.for
• No async in src/api or src/lib except at framework boundaries with comment
• Type params - $prefix for types/interfaces, value names for functions

Ready to continue with current task.
```

## When to Use

- When Claude starts using wrong patterns
- After context switches or long discussions
- When working in a new area of the codebase
- Before critical implementations
- When unsure if conventions are being followed correctly