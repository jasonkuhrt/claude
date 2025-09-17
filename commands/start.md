---
allowed-tools: Read
argument-hint: '[focus-area]'
description: Initialize Claude session with project awareness
---

# Start

## Goal

- Initialize a Claude Code session with full awareness of project standards and conventions
- Confirm awareness of personal configuration already in context
- Optionally focus on a specific area of the codebase

## Usage

- `/start` - Start with general project awareness
- `/start [focus-area]` - Start with specific focus (e.g., `/start effect implementation`)

## Arguments

- First argument ($1): Optional focus area for the session
- When no arguments: General project awareness

## Required Reading

1. Fully read ~/.claude/docs/prompts/serena.md
2. Fully read ~/.claude/CLAUDE.md
3. If exists, fully read ./CLAUDE.md
4. If exists, fully read ./.claude/serena-prompt.md (project-specific Serena overrides)

## Instructions

After reading the required files:

1. **Confirm Serena awareness**:
   - State: "✓ Serena MCP tools instructions loaded"
   - If project has ./.claude/serena-prompt.md, note: "✓ Project-specific Serena instructions loaded"

2. **Confirm personal configuration awareness**:
   - Explicitly state: "✓ Personal configuration from ~/.claude/CLAUDE.md is active"
   - List 2-3 key principles from the user's personal CLAUDE.md to prove awareness, such as:
     - Core work style preferences (e.g., ADHD considerations, no flattery)
     - Key technical preferences (e.g., ESM modules, TypeScript patterns)
     - Important rules (e.g., never guess APIs, verify everything)
   - Confirm: "✓ Personal commands from ~/.claude/commands/ are available"

3. **Acknowledge project configuration**:
   - If ./CLAUDE.md exists: Confirm project-specific standards are loaded
   - Note any available MCP servers (ref, serena, effect-docs, etc.)
   - Reference the current project name from the working directory

4. **Focus area handling**:
   If focus area is provided: "$ARGUMENTS"
   - Pay special attention to code and patterns related to the specified focus area
   - Proactively mention relevant standards and patterns for that area
   - Be ready to work on tasks related to the focus area

   If no focus area is provided:
   - Provide a brief acknowledgment that all configurations are active
   - Be ready to assist with any aspect of the codebase

## Example Output

```
✓ Serena MCP tools instructions loaded
✓ Personal configuration from ~/.claude/CLAUDE.md is active, including:
  - ADHD-aware work style: breaking down tasks into smaller iterations
  - Technical preferences: ESM modules only, no CJS, prefer unknown over any
  - Critical rule: Never guess APIs - always verify in source code
✓ Personal commands from ~/.claude/commands/ are available
✓ Project standards from ./CLAUDE.md loaded (if present)
✓ MCP servers available: ref (docs), serena (code analysis), effect-docs (Effect documentation)

Ready to assist with [current project name] development.
```