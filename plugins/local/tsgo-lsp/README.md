# tsgo

Fast TypeScript type checking for Claude Code via tsgo (TypeScript 7 native Go port).

## Features

- **~10x faster** type checking compared to traditional `tsc`
- **Stop gate** - Blocks task completion if type errors exist
- **On-demand** - Use `/tsgo:check` for manual diagnostics anytime

## How It Works

Uses `tsgo --noEmit` CLI for project-wide type checking. The tsgo compiler is Microsoft's native Go port of TypeScript, providing significant performance improvements over the JavaScript-based tsc.

```
Edits happen freely -> Claude tries to stop -> Stop hook fires ->
  tsgo --noEmit -> Clean? Allow stop : Block & fix
```

## Requirements

- `tsgo` CLI installed globally (`npm install -g @typescript/native-preview`)

## Installation

```bash
/plugin marketplace add https://github.com/jasonkuhrt/claude
/plugin install tsgo-lsp@jasonkuhrt
```

## Usage

### Automatic (via Stop hook)

When Claude considers a task complete and tries to stop, the Stop hook:
1. Checks if any TypeScript/JavaScript files were modified
2. If yes, runs `tsgo --noEmit` for type checking
3. If errors exist: blocks stopping, lists errors
4. If clean: allows stopping

### Manual

```
/tsgo:check
```

## Components

| File | Purpose |
|------|---------|
| `server/` | MCP server that runs tsgo CLI |
| `hooks/hooks.json` | Stop hook for type checking gate |
| `commands/check.md` | `/tsgo:check` command |

## Why CLI instead of LSP?

tsgo's LSP supports per-file diagnostics (`textDocument/diagnostic`) but not project-wide workspace diagnostics yet. For checking an entire project before task completion, running `tsgo --noEmit` is simpler and gives us full project coverage.

## Resources

- [TypeScript Native Port Announcement](https://devblogs.microsoft.com/typescript/typescript-native-port/)
- [typescript-go GitHub](https://github.com/microsoft/typescript-go)
