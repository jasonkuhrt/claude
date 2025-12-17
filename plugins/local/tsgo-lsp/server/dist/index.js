#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";
import { exec } from "child_process";
import { existsSync } from "fs";
import { dirname, resolve } from "path";
import { promisify } from "util";
import * as Effect from "effect/Effect";
const execAsync = promisify(exec);
// ============================================================================
// Workspace Detection
// ============================================================================
const findWorkspaceRoot = (filePath) => {
    let dir = filePath.startsWith("/") ? dirname(filePath) : dirname(resolve(filePath));
    while (dir !== "/") {
        if (existsSync(resolve(dir, "tsconfig.json"))) {
            return dir;
        }
        const parent = dirname(dir);
        if (parent === dir)
            break;
        dir = parent;
    }
    return process.env.CLAUDE_PROJECT_DIR || process.cwd();
};
const parseTsgoOutput = (output) => {
    const diagnostics = [];
    const lines = output.split("\n");
    for (const line of lines) {
        // Format: src/file.ts(10,5): error TS2322: Type 'string' is not assignable to type 'number'.
        const match = line.match(/^(.+)\((\d+),(\d+)\): (error|warning) (TS\d+): (.+)$/);
        if (match) {
            diagnostics.push({
                file: match[1],
                line: parseInt(match[2], 10),
                character: parseInt(match[3], 10),
                code: match[5],
                message: match[6],
            });
        }
    }
    return diagnostics;
};
const getDiagnostics = (filePath) => Effect.gen(function* () {
    const workspace = findWorkspaceRoot(filePath);
    console.error("[tsgo-mcp] Running diagnostics in:", workspace);
    const result = yield* Effect.tryPromise({
        try: () => execAsync("tsgo --noEmit", { cwd: workspace, maxBuffer: 10 * 1024 * 1024 }),
        catch: (e) => {
            // tsgo exits with code 2 when there are errors, but stderr has the output
            if (e.stderr || e.stdout) {
                return { stdout: e.stdout || "", stderr: e.stderr || "" };
            }
            throw e;
        },
    }).pipe(Effect.catchAll((e) => {
        if (e.stdout !== undefined || e.stderr !== undefined) {
            return Effect.succeed(e);
        }
        return Effect.fail(new Error(String(e)));
    }));
    const output = result.stdout || result.stderr || "";
    return parseTsgoOutput(output);
});
// ============================================================================
// MCP Server
// ============================================================================
const tools = [
    {
        name: "diagnostics",
        description: "Get TypeScript diagnostics (type errors) for a file. Automatically detects the project from the file path.",
        inputSchema: {
            type: "object",
            properties: {
                filePath: {
                    type: "string",
                    description: "Absolute path to the TypeScript file to check",
                },
            },
            required: ["filePath"],
        },
    },
];
const main = Effect.gen(function* () {
    const server = new Server({ name: "tsgo-mcp", version: "0.3.0" }, { capabilities: { tools: {} } });
    server.setRequestHandler(ListToolsRequestSchema, async () => ({ tools }));
    server.setRequestHandler(CallToolRequestSchema, async (request) => {
        const { name, arguments: args } = request.params;
        const filePath = args?.filePath;
        if (!filePath) {
            return { content: [{ type: "text", text: "Error: filePath is required" }], isError: true };
        }
        if (name !== "diagnostics") {
            return { content: [{ type: "text", text: `Unknown tool: ${name}` }], isError: true };
        }
        const program = Effect.gen(function* () {
            const diagnostics = yield* getDiagnostics(filePath);
            if (diagnostics.length === 0) {
                return { content: [{ type: "text", text: "No type errors found." }] };
            }
            const formatted = diagnostics.map((d) => `${d.file}:${d.line}:${d.character} - ${d.code}: ${d.message}`).join("\n");
            return {
                content: [{
                        type: "text",
                        text: `Found ${diagnostics.length} type error(s):\n\n${formatted}`,
                    }],
            };
        });
        return Effect.runPromise(program).catch((error) => ({
            content: [{ type: "text", text: `Error: ${error}` }],
            isError: true,
        }));
    });
    const transport = new StdioServerTransport();
    yield* Effect.promise(() => server.connect(transport));
    console.error("[tsgo-mcp] Server started");
});
Effect.runPromise(main).catch((e) => {
    console.error("[tsgo-mcp] Fatal error:", e);
    process.exit(1);
});
