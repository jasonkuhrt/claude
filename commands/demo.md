---
# YAML Frontmatter Configuration
# Documentation: https://docs.claude.com/en/docs/claude-code/slash-commands#frontmatter

# Restricts which tools Claude can use
allowed-tools: Read, Grep, Glob, Bash(ls:*), Bash(echo:*), Bash(pwd), Bash(date), Edit, MultiEdit

# Displayed in parentheses after command name to communicate expected argument format to users
argument-hint: '[topic] [optional-flags]'

# Brief explanation shown in /help
description: Comprehensive demo of all slash command capabilities

# Override the default model (optional)
model: claude-opus-4-1-20250805
---

# Claude Code Slash Command Demo

# Documentation: https://docs.anthropic.com/en/docs/claude-code/slash-commands

This is a comprehensive demonstration of slash command capabilities. Created as a learning resource with 100% verified
accuracy.

## 1. Argument Placeholders

Docs: https://docs.anthropic.com/en/docs/claude-code/slash-commands#arguments

You provided these arguments:

- All arguments: $ARGUMENTS
- First argument: $1
- Second argument: $2

## 2. Bash Command Execution

Docs: https://docs.anthropic.com/en/docs/claude-code/slash-commands#bash-command-execution

The syntax uses exclamation mark + backticks to execute bash commands. The command output will be included in the
prompt.

Current directory: !`pwd` Current date: !`date` Your shell: !`echo $SHELL`

## 3. File References

Docs: https://docs.anthropic.com/en/docs/claude-code/slash-commands#file-references

File references use the at symbol (@) followed by a file path. Can reference multiple files in one command.

Contents of this demo command: @~/.claude/commands/demo.md

## 4. Command Organization

# Commands can be organized in subdirectories for namespacing

# Example: ~/.claude/commands/git/commit.md creates /git/commit

# Docs: https://docs.anthropic.com/en/docs/claude-code/slash-commands#organizing-commands

## 5. Tool Restrictions in Frontmatter

# VERIFIED allowed-tools patterns from documentation:

# - Read, Grep, Glob: Standard tools

# - Bash(command:*): Specific command with wildcards

# - Bash(git add:*): Git add with any arguments

# Examples from docs: Bash(git add:_), Bash(git status:_)

# Docs: https://docs.anthropic.com/en/docs/claude-code/slash-commands

## 6. Personal vs Project Commands

# Personal: ~/.claude/commands/ - shown as "(user)" in /help

# Project: .claude/commands/ - shown as "(project)" in /help

# Personal commands work across all projects

# Docs: https://docs.anthropic.com/en/docs/claude-code/slash-commands#project-commands-vs-personal-commands

## 7. Command Discovery

# Use /help to list all available commands

# Commands show their source (user/project)

# Docs: https://docs.anthropic.com/en/docs/claude-code/slash-commands#built-in-commands

## 8. Extended Thinking Mode

# Commands can trigger extended thinking with special keywords

# Docs: https://docs.anthropic.com/en/docs/claude-code/slash-commands

## Advanced Usage Notes

### Dynamic Content

Commands can combine multiple features:

- Bash output + file contents + arguments
- Multiple file references in one command
- Conditional logic based on arguments

### Best Practices

1. Keep commands focused on a single purpose
2. Use descriptive filenames (becomes command name)
3. Document expected arguments clearly
4. Restrict tools appropriately for safety
5. Test commands before relying on them

### VERIFIED Limitations

- Conflicts between user and project commands not supported
- MCP commands do not support wildcards
- File references must be valid paths
- Arguments are text-only (no structured data)
- Cannot reference commands from other commands

## Available YAML Frontmatter Fields (VERIFIED)

1. allowed-tools: Tool restrictions
2. argument-hint: Expected arguments display
3. description: Command description
4. model: Specific model selection

## Example Task

Based on the topic "$1", I will now demonstrate my understanding by providing relevant information or performing
appropriate actions within the allowed tools specified in the frontmatter.

---

# This demo command is 100% accurate per official documentation

# Every syntax element has been verified against:

# https://docs.anthropic.com/en/docs/claude-code/slash-commands

# https://docs.anthropic.com/en/docs/claude-code/sdk/sdk-slash-commands
