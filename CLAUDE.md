# Claude Memory - @jasonkuhrt

**Note**: All referenced documentation paths in this file are relative to this file's location (`~/.claude/`).

## Core Principles

### Communication & Collaboration

- Be direct about limitations or concerns
- Challenge me with better system design and software techniques
- Propose multiple solutions when trade-offs exist
- Flag potential tech debt explicitly
- Ask clarifying questions early
- Don't flatter or routinely congratulate - we're collaborators
- When stating opinions, distinguish facts from guesses
- When I say "tell me" or "teach me", explain without modifying code
- Let me make commits unless explicitly asked
- Avoid use of emojis in text like markdown titles and code comments

### Work Style

- I have ADHD - help me break down work into smaller shippable iterations
- After several failed solutions, stop guessing - research or ask for help
- Make better decisions independently
- Understand priorities and work efficiently with my setup

### Decision Making

- Prefer existing patterns over introducing new ones
- Choose readability over cleverness
- Document non-obvious decisions
- Err on the side of type safety
- Ask before making architectural changes

## Technical Preferences

### Language & Runtime

#### TypeScript

- **ALWAYS** use ESM modules, never CJS
- **ALWAYS** verify type checks before running code
- Prefer function expressions over declarations (except overloaded functions)
- Don't use TS enums
- Prefer `unknown` over `any`
- **Type Parameter Naming Convention**:
  - **Type aliases and interfaces**: ALWAYS use `$` prefix
    - ✅ `type Transform<$Input> = $Input extends string ? number : boolean`
    - ✅ `interface Container<$T> { value: $T }`
    - ❌ `type Transform<Input> = Input extends string ? number : boolean`

  - **Functions and methods** - apply these rules in order:
    1. **Mapped to value parameter**: Use the value parameter's name
       - ✅ `function process<value>(value: value): value`
       - ✅ `function map<item, result>(item: item, fn: (item) => result): result`
       - **EXCEPTION - Type guards**: Add `_` suffix to type param
         - ✅ `function isString<value_>(value: unknown): value is value_`
         - ❌ `function isString<value>(value: unknown): value is value`

    2. **NOT mapped to value parameter**: Use `$` prefix
       - ✅ `function create<$T>(): $T`
       - ✅ `function compose<$A, $B, $C>(f: ($a: $A) => $B, g: ($b: $B) => $C): ($a: $A) => $C`
       - ❌ `function create<T>(): T`

  - **EXCEPTION - Type utility internals**: Parameters with `___` prefix are implementation details
    - ✅ Keep as-is: `type Utility<$T, ___Internal = SomeDefault<$T>> = ...`
    - ❌ Don't change: `type Utility<$T, $Internal = SomeDefault<$T>> = ...`
    - These are "private" to the type implementation and conventionally marked with triple underscore

  - **Mapped types**: Use specific single-letter iterators
    - For objects: Use `k` (key)
      - ✅ `{ [k in keyof $T]: $T[k] }`
      - ✅ `{ [k in ___Keys[number] & keyof $Schema]: $Schema[k] }`
      - ❌ `{ [K in keyof $T]: $T[K] }`
    - For tuples/arrays: Use `i` (index)
      - ✅ `{ [i in keyof $T]: Transform<$T[i]> }`
      - ❌ `{ [I in keyof $T]: Transform<$T[I]> }`

  - **Infer clauses**: Use `__lowercase__` pattern
    - ✅ `$T extends Array<infer __element__> ? __element__ : never`
    - ✅ `$T extends { tag: infer __tag__ } ? __tag__ : never`
    - ❌ `$T extends Array<infer Element> ? Element : never`
    - ❌ `$T extends Array<infer $Element> ? $Element : never`
- When using complex conditional return types, cast implementation to `any` with comment

#### Code Style

- Short-circuit early (return/continue) over if-else chains
- Use proper JSDoc tags like `@default`
- Long conditional types: align on `?` and `:` with `//dprint-ignore`
- Handle state combinations: calculate enum, then switch
- Extract magic numbers to named constants
- In JSDoc, use `{@link identifier}` syntax for references to other functions/types (enables IDE navigation)
- **JSDoc Placement Rules**:
  - **DO**: Add JSDoc to interfaces, functions, classes, type aliases, exported constants
  - **DON'T**: Add JSDoc to namespace exports (`export * as Name`), barrel exports, re-exports
  - **DON'T**: Add JSDoc to implementations that already inherit documentation from their interfaces/types
  - **CRITICAL**: Never use multiple JSDoc blocks for the same declaration - only the closest one is effective
  - **CRITICAL**: Avoid duplicate JSDoc - if a const implements an interface with JSDoc, don't repeat it
  - **Focus**: Place JSDoc where tooling will actually pick it up (hover info, auto-complete, docs)
  - **DO**: NAMESPACE EXPORT HACK: For export * as Name, use @ts-expect-error with duplicate namespace: //
    @ts-expect-error Duplicate identifier export * as Utils from './utils' /** * ... */ export namespace Utils {}
- **Test Organization Rules**:
  - **Avoid redundant top-level describe blocks** that repeat information already in the file path
  - Example: In `src/arr/traits/eq.test.ts`, don't use `describe('Arr.Eq implementation')` - the file path already
    indicates this
  - Focus describe blocks on behavior groupings, not restating what's being tested
- **Type-Level Transformations**: Use conditional types over function overloads for type mappings
  - Define type-level utilities (e.g., `type Abs<T>`) that map input types to output types
  - Use these in function signatures: `abs<T>(value: T): Abs<T>`
  - Benefits: Cleaner API, better type inference, no overload resolution issues
  - Example: `type Sign<T> = T extends Positive ? 1 : T extends Negative ? -1 : ...`

#### Node.js & Package Management

- Use pnpm (not npm)
- Use `pnpm env` (not nvm)
- Prefer `pnpm run --concurrently` over concurrently package
- Use `node:` prefix for built-ins
- Prefer zx package for scripts over bash

### Project Structure

- `/lib` - Domain-agnostic code (potential standalone packages)
- `/helpers` - Domain-coupled abstractions
- `sandbox.ts` - Temporary work file, use freely
- Learn from: DEVELOPMENT.md, CONTRIBUTING.md, README.md
- **NEVER** use or modify main package exports (index.ts) - only use package.json exports field

### Frameworks & Tools

#### React

- One component per module
- Component name matches module name
- Props interface named `Props`
- Define as: `export const Name: React.FC<Props> = ({...}) => {}`
- Use design tokens when available

#### Build Tools

- Vite: Use Rolldown (not Rollup)
- Use project formatter (dprint, prettier, etc.)

#### Testing

- 1:1 test file mapping (`foo.ts` → `foo.test.ts`)
- Prefer property-based testing with fast-check
- Few high-impact tests over exhaustive coverage
- Minimal mock data to focus on patterns
- `describe` blocks for each export (unless single export)
- No top-level describes repeating module name
- **ALWAYS** add a test case when fixing a bug in tested code

## Development Workflow

### Before Changes

- Read TypeScript types and JSDoc for APIs
- Check existing patterns
- Verify property names exist
- Respect configuration patterns

### Making Changes

- Verify after each change:
  - No TypeScript errors
  - No syntax errors
  - Correct imports
- Never spread configs without understanding merge behavior
- Make small, incremental changes

### After Changes

- Run type checks: `pnpm check:types`
- Run tests: `pnpm test [path]`
- Format code: `pnpm fix:format`
- State what TypeScript checking was done
- Be explicit about uncertainties

### Git & GitHub

- Never push to main branch
- Feature branches: `feat/description`
- Bug branches: `fix/description`
- Reusable workflows: prefix with `_`
- GH issues: write to tmp file first to avoid shell issues
- When debugging CI issues, use the `gh` CLI to investigate logs, workflows, and deployments directly
- Check workflow runs, deployment statuses, and logs yourself before asking for debug information

## Error Handling & Debugging

- Don't suppress logs as a "solution"
- Use Result/Either for expected errors
- Throw Error objects, not strings
- Include context in error messages
- Never swallow errors silently
- Don't hide errors with spreading or optional chaining

## Package Preferences

- `@wollybeard/kit` - Use when installed
- `playwright/test` over `@playwright/test`
- `rg` (ripgrep) over grep
- ESM over CommonJS
- Perl regex over sed
- `zod/v4` - Always use zod/v4 instead of zod

## Session Management

- Check for `CLAUDE_SESSION.md` and restore
- Update on "checkpoint" command
- Keep track of work in progress

## Editor Specific

### Zed

- Change global config in ~/.config/zed unless specified

## Performance Considerations

- Avoid unnecessary iterations
- Use early returns
- Consider memory usage for large structures
- Profile before optimizing

## Common Pitfalls

- Don't use `any` unless absolutely necessary
- Don't mutate function parameters
- Don't create files without explicit request
- Don't assume file paths exist
- Don't make assumptions about APIs

## CRITICAL RULES

- **NEVER GUESS APIs** - Always look up the actual API in the source code
- When using any library (especially @wollybeard/kit), ALWAYS check:
  - The actual exports
  - The actual method signatures
  - The JSDoc documentation
- If you don't know an API, traverse the source code to find it
- Guessing APIs wastes time and is extremely annoying

## Local Libraries

**IMPORTANT**: Follow all conventions detailed in:

- Base conventions: `docs/conventions/library.md`
- ADT patterns: `docs/conventions/library-adt.md`

## Temporary Directories

- When creating temporary test projects or demos, always use local directories within the current project (e.g.,
  `test-*`, `tmp/*`, `demo-*`)
- Never attempt to use OS-level `/tmp` directory as Claude Code cannot cd outside the original working directory due to
  security restrictions
- Clean up temporary directories after use unless they contain valuable reference material
