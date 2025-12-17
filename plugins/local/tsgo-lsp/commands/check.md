---
description: Check TypeScript types now (normally automatic via Stop hook)
allowed-tools: ["mcp__*tsgo*"]
---

# TypeScript Type Check (On-Demand)

**Note:** You normally don't need this command - the Stop hook automatically checks types before task completion. Use this only for early feedback mid-task.

## Instructions

1. Use the tsgo MCP server's `diagnostics` tool
2. Report any type errors with file:line and message
3. If errors exist, offer to fix them
4. If clean, confirm briefly

## When to Use

- After a complex refactor, before you're "done"
- To debug if the tsgo MCP server is working
- When you want type feedback without completing the task
