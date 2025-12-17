# tsgo-lsp

Fast incremental TypeScript type checking for Claude Code via tsgo (TypeScript 7 native port) LSP.

## Features

- **~10x faster** type checking compared to traditional `tsc`
- **Incremental** - LSP maintains project state, subsequent checks are near-instant
- **Stop gate** - Blocks task completion if type errors exist (no false positives mid-edit)
- **On-demand** - Use `/tsgo:check` for manual diagnostics anytime
- **Full LSP tools** - diagnostics, hover, definition, references

## Background

### The Problem

- Running `tsc --noEmit` does a cold-start full type check every time
- Large codebases: 10-60+ seconds per check
- Cursor/VS Code use tsserver (long-running LSP) for incremental checking
- Claude Code currently lacks this capability

### The Solution

tsgo is Microsoft's native Go port of TypeScript with ~10x performance improvement. It exposes an LSP server that maintains incremental state.

## Requirements

- Node.js 18+
- `@typescript/native-preview` (installed automatically via npx)

## Installation

1. Copy the plugin to `~/.claude/plugins/local/tsgo-lsp/`
2. Install dependencies:
   ```bash
   cd ~/.claude/plugins/local/tsgo-lsp/server
   pnpm install
   ```
3. Restart Claude Code

## Usage

### Automatic (via Stop hook)

When Claude considers a task complete and tries to stop, the Stop hook:
1. Checks for type errors via tsgo LSP
2. If errors exist: blocks stopping, lists errors, instructs to fix
3. If clean: allows stopping

This avoids false positives during multi-edit refactors - types are only checked when "done".

### Manual (Optional)

```
/tsgo:check
```

**When to use:** You normally don't need this - the Stop hook handles type checking automatically. Use `/tsgo:check` only if you want to check types *mid-task* before completing, e.g., after a complex refactor when you want early feedback.

## How It Works

```
Edits happen freely -> Claude tries to stop -> Stop hook fires ->
  tsgo LSP diagnostics -> Clean? Allow stop : Block & fix
```

## Architecture

```
+-----------------------------------------------------------------+
|                        Claude Code                              |
|                                                                 |
|  +-------------+    +------------------+    +----------------+  |
|  |   Edit      |--->|  Stop hook       |--->|  Calls tsgo    |  |
|  |   Tool      |    |  triggers        |    |  MCP tools     |  |
|  +-------------+    +------------------+    +-------+--------+  |
|                                                     |           |
+-----------------------------------------------------------------+
                                                      |
                    +-------------------------------  v ----------+
                    |       Custom MCP Server                     |
                    |       (server/dist/index.js)                |
                    +------------------------------+--------------+
                                                   |
                    +------------------------------v--------------+
                    |       tsgo --lsp -stdio                     |
                    |       (long-running, incremental)           |
                    |                                             |
                    |  - Maintains project graph in memory        |
                    |  - Incremental recompilation                |
                    |  - ~10x faster than tsc                     |
                    +---------------------------------------------+
```

The custom MCP server:
- Spawns tsgo LSP as a child process
- Handles LSP protocol framing (Content-Length headers)
- Exposes tools: `diagnostics`, `hover`, `definition`, `references`
- Uses `${CLAUDE_PROJECT_DIR}` as the workspace root

## Components

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin manifest |
| `.mcp.json` | MCP server configuration |
| `server/` | Custom MCP server wrapping tsgo LSP |
| `hooks/hooks.json` | Stop hook for type checking gate |
| `commands/check.md` | `/tsgo:check` command |

## Design Decisions

**Stop hook instead of PostToolUse**:
- Avoids false positives during multi-file refactors
- No interruptions mid-edit
- Works with any edit tool (native, Serena, etc.)
- Only validates when task is "complete"

**Custom MCP server instead of mcp-language-server**:
- mcp-language-server had compatibility issues with tsgo LSP
- Custom server is ~300 LOC, tailored to tsgo
- Direct control over LSP protocol handling

**MCP over direct tool use**:
- Enables incremental LSP state (fast subsequent checks)
- Standard protocol for language server integration

## Troubleshooting

### MCP server not starting

1. Build the server: `cd ~/.claude/plugins/local/tsgo-lsp/server && pnpm build`
2. Check that `@typescript/native-preview` is accessible: `npx -y @typescript/native-preview --version`
3. Verify MCP is running: `/mcp`

### No diagnostics returned

1. Verify the MCP server is running: `/mcp`
2. Check project has a `tsconfig.json`
3. Try `/tsgo:check` manually

### Slow first run

The first invocation downloads packages via npx. Subsequent runs are faster.

## Known Limitations

- tsgo is in preview; some edge cases may differ from tsc
- No downlevel emit below ES2021
- Large projects may still take a few seconds on first check
- Project references support may be incomplete

## Testing

```bash
# Test tsgo LSP directly (should start and wait for input)
tsgo --lsp -stdio

# Test type checking in a project
cd /path/to/ts/project
tsgo --noEmit

# Compare performance
time tsc --noEmit
time tsgo --noEmit
```

## Resources

- [TypeScript Native Port Announcement](https://devblogs.microsoft.com/typescript/typescript-native-port/)
- [TypeScript 7 Progress (Dec 2025)](https://devblogs.microsoft.com/typescript/progress-on-typescript-7-december-2025/)
- [typescript-go GitHub](https://github.com/microsoft/typescript-go)

## Changelog

- 2025-12-16: v0.1.0 - Initial release
  - Custom MCP server wrapping tsgo LSP
  - Stop hook for type-check gate
  - `/tsgo:check` command for manual diagnostics
