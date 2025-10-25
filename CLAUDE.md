# Claude Memory - @jasonkuhrt

**Note**: All referenced documentation paths in this file are relative to this file's location (`~/.claude/`).

## CRITICAL: Local Context Files

**If local context files exist in the working directory**, read them immediately. Local context files are more specific to the current work and take precedence over these global instructions when conflicts arise.

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
    - ✅ `$T extends { tag: infer __tag__} ? __tag__ : never`
    - ❌ `$T extends Array<infer Element> ? Element : never`
    - ❌ `$T extends Array<infer $Element> ? $Element : never`

- **Type Parameter Defaults - Widest Variant Rule**:
  - **DEFAULT**: Type parameters should default to their widest possible variant
  - **CONSTRAINT POSITION**: Using `any` in extends constraints is usually a code smell
    - ❌ `$Context extends ParserContext<any, any, any>` - Ugly hack!
    - ✅ `$Context extends ParserContext` - Clean, uses default widest type
  - **RATIONALE**:
    - Makes type signatures cleaner and more maintainable
    - Allows the type to accept its full range without explicit parameters
    - Reduces cognitive overhead when reading type constraints
  - **EXCEPTIONS**: TypeScript's complexity means exceptions exist
    - Sometimes type errors aren't worth fixing and `any` is pragmatic
    - This is a good default starting point, not an absolute rule
  - **EXAMPLE**:
    ```typescript
    // ✅ GOOD - Defaults to widest
    type ParserContext<
      $Schema = Schema | undefined,  // Union = widest
      $SDDM = any,
      $TypeHooks = never
    > = ...

    // Usage with clean constraints
    function parse<$Context extends ParserContext>(...) // ✅ Clean!

    // ❌ BAD - Cluttered constraint
    function parse<$Context extends ParserContext<any, any, any>>(...) // ❌ Ugly!
    ```

- When using complex conditional return types, cast implementation to `any` with comment
- **CRITICAL**: When implementing functions with conditional types:
  - Keep internal implementation simple - cast to `any` directly, NOT through `unknown`
  - Don't overcomplicate with `as unknown as ComplexType<T>` chains
  - Simple `as any` is preferred for internal implementation when type safety is enforced by the signature
  - Example:
    ```typescript
    // WRONG - overcomplicated casting
    return Ef.gen(() => input as Generator<any, any, any>) as unknown as NormalizeResult<T>

    // RIGHT - simple internal casting
    return Ef.gen(() => input as any) as any
    ```

#### Code Style

- Short-circuit early (return/continue) over if-else chains
- Use proper JSDoc tags like `@default`
- Long conditional types: align on `?` and `:` with `//dprint-ignore`
- **TypeScript Conditional Type Formatting**:
  - **Goal**: Enable commenting out individual cases without breaking syntax (useful for debugging)
  - **Two patterns**: Flat (for mutually exclusive cases) vs Nested (for inherent logic nesting)

  **FLAT PATTERN** (prefer when possible):
  - Use for mutually exclusive top-level cases
  - All top-level conditions start at **same indentation**
  - Place `:` at **end of line** for each case
  - Next condition returns to **base indentation**
  - Align `?` symbols vertically within each case

  **NESTED PATTERN** (only when logic requires it):
  - Use when conditions are inherently nested (one inside another)
  - Each nesting level increases indentation
  - Align `?` and `:` symbols at each level

  **Examples**:
    ```typescript
    // ✅ GOOD - FLAT pattern for mutually exclusive cases
    // Each top-level case can be commented out safely
    type Result<$T> =
      $T extends string                   ? 'string' :
      $T extends number                   ? 'number' :
      // $T extends boolean                  ? 'boolean' :  // ← Can comment out
      $T extends undefined                ? 'undefined' :
                                            'unknown'  // ← Final else, aligned

    // ✅ GOOD - FLAT pattern with inner ternary
    type LengthSlow<$S, $Acc> =
      $S extends `${string}${string}${string}${string}${infer __r__}`
        ? string extends __r__              // Inner ternary (nested logic)
          ? number
          : LengthSlow<__r__, [...$Acc, 0, 0, 0, 0]> :  // ← : at end
      $S extends `${string}${string}${string}${infer __r__}`  // ← Back to base
        ? string extends __r__
          ? number
          : [...$Acc, 0, 0, 0]['length'] :  // ← : at end
      $Acc['length']  // ← Final else

    // ✅ GOOD - NESTED pattern (inherent logic requires it)
    type DeepCheck<$S> =
      $S extends `${infer __c__}${infer __rest__}` ? (
        string extends __rest__                       ? number :
        __rest__ extends ''                           ? 1 :
        __rest__ extends `${infer __c2__}${infer __r2__}` ? (
          string extends __r2__                        ? number :
          __r2__ extends ''                           ? 2 :
          never
        ) : never
      ) : 0

    // ❌ BAD - Misaligned flat pattern
    type Bad<$T> =
      $T extends string ? 'string' :  // ← Alignment lost
      $T extends number ? 'number' :  // ← Alignment lost
      'unknown'

    // ❌ BAD - Using nested when flat would work
    type Bad2<$T> =
      $T extends string                   ? 'string'
      : $T extends number                 ? 'number'  // ← Unnecessary nesting
        : $T extends boolean              ? 'boolean'
          : 'unknown'
    ```
- Handle state combinations: calculate enum, then switch
- Extract magic numbers to named constants
- In JSDoc, use `{@link identifier}` syntax for references to other functions/types (enables IDE navigation)
- **JSDoc Placement Rules**:
  - **CRITICAL PRINCIPLE**: Only document the PUBLIC INTERFACE. JSDoc is for users of the API, not for implementation details.
  - **DO**: Add JSDoc to PUBLIC exports only:
    - Exported interfaces
    - Exported functions
    - Exported classes
    - Exported type aliases
    - Exported constants
  - **DON'T**: Add JSDoc to:
    - Private/internal functions or variables
    - Namespace exports (`export * as Name`)
    - Barrel exports (`export * from './foo'`)
    - Re-exports
    - Implementations that already inherit documentation from their interface/type
    - Helper functions used only internally
  - **CRITICAL**: Never use multiple JSDoc blocks for the same declaration - only the closest one is effective
  - **CRITICAL**: Avoid duplicate JSDoc - if a const implements an interface with JSDoc, don't repeat it on the const
  - **Focus**: Place JSDoc where tooling will actually pick it up (hover info, auto-complete, docs)
  - **DO**: NAMESPACE EXPORT HACK: For export * as Name, use @ts-expect-error with duplicate namespace: //
    @ts-expect-error Duplicate identifier export * as Utils from './utils' /** * ... */ export namespace Utils {}
- **JSDoc Type Parameter Rules**:
  - **DON'T**: Document type parameters with `@typeParam` unless they are intended to be provided literally by the user
  - Type parameters that are inferred from arguments should not be documented
  - Only document type parameters when users explicitly need to pass them (e.g., `.i<string>()`, `.o<boolean>()`)
  - JSDoc `@typeParam` names are not semantically linked to actual type parameters and won't update during refactors
  - Example: Document `.i<T>()` because users write `.i<string>()`, but don't document `matrix<$values>()` because it's inferred
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
- **CRITICAL: NEVER cast function inputs/parameters** - If TypeScript shows an error on inputs, it's revealing a real bug. Find and fix the root cause instead of casting
  - ❌ WRONG: `Ef.runPromise(effect as Ef.Effect<A, never, never>)` - hiding missing runtime layers
  - ✅ RIGHT: Fix the runtime to provide all required services
  - Casting inputs masks real problems and leads to runtime failures
  - Only cast return values when implementing complex conditional types (with `as any` internally)

#### Node.js & Package Management

- Use pnpm (not npm)
- Use `pnpm env` (not nvm)
- **CRITICAL**: To run multiple scripts in parallel: use `pnpm run '/pattern/'` (pattern matching WITHOUT --parallel flag)
  - Example: `pnpm run '/docs:dev:.*/'` runs all scripts matching pattern
  - **NEVER use `--parallel` flag** - it's only for workspace packages, not for running multiple scripts
  - Pattern matching runs scripts concurrently by default for long-running processes
- Use `node:` prefix for built-ins
- Prefer zx package for scripts over bash

### Project Structure

- Learn from: DEVELOPMENT.md, CONTRIBUTING.md, README.md, and project-specific docs/conventions/*.md files
- Follow project conventions documented in the codebase

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
- **CRITICAL: Minimalist test fixtures** - Use absolute minimum test cases needed to cover behavior. Quality over quantity. Remove redundant fixtures.
- `describe` blocks for each export (unless single export)
- No top-level describes repeating module name
- **ALWAYS** add a test case when fixing a bug in tested code
- **CRITICAL: MUST CAPTURE FAILING TESTS BEFORE FIXING** - Before implementing any fix for a bug or issue, you MUST first create a failing unit test that reproduces the problem, confirm it fails, then implement the fix. This applies to ALL bug fixes except very complex integration scenarios like massive deep state in Playwright browser tests. No exceptions - TDD is mandatory for bug fixes.
- **CRITICAL: Use Test.describe() NOT comments** - NEVER use inline comments like `// Long flags` to group test cases. Always use `Test.describe('long flags', ...)` which provides the same grouping PLUS test output reporting.
- **CRITICAL: Use Schema.make() for test fixtures** - When creating instances of Effect Schema classes in tests, ALWAYS use `Schema.make()` constructor instead of manually constructing objects with `_tag`. This ensures type safety and uses the official API.
- **CRITICAL: READ THE JSDOC** - Before using ANY API (especially @wollybeard/kit APIs like Ts.Assert, Test, etc.), READ the actual JSDoc documentation in the source code. NEVER guess the API signature. Find usage examples in the codebase if needed.

##### Type Testing

###### `.test-d.ts` Files - Pure Type-Level Tests

**CRITICAL**: When writing pure type-level tests in `.test-d.ts` files (tests that don't involve runtime values):

- **NEVER wrap type-level tests in `test()` blocks** - they should be flat type aliases at the module level
- **ALWAYS prefix type names with `_`** to satisfy linters checking for unused variables
- Use `@ts-expect-error` for negative test cases (types that should fail)
- Keep one `test()` block only for value-level assertions that need runtime context

**Pattern:**
```typescript
// ✅ CORRECT - Flat type aliases with _ prefix
type _pass_case = Assert.Cases<
  Assert.exact.string<string>,
  Assert.exact.number<number>
>

// @ts-expect-error - number not assignable to string
type _error_case_1 = Assert.Case<Assert.exact<string, number>>

// Value-level tests need a test block
test('value-level guards', () => {
  // @ts-expect-error - any not assignable to literal
  Assert.exact.of.as<3>()($a)
})

// ❌ WRONG - Don't wrap type tests in test blocks
test('type tests', () => {
  type _ = Assert.Cases<
    Assert.exact.string<string>
  >
})
```

**Rationale:**
- Type-level tests execute at compile time, not runtime - no need for test runner blocks
- Flat structure is simpler and more direct
- `_` prefix prevents "unused variable" lint errors
- Keeps the distinction clear between type-level (compile-time) and value-level (runtime) tests

###### Type Testing in Tests

**CRITICAL: Strongly prefer value-level Ts.Assert API over type-level**

- **Value-level** (preferred): `Ts.Assert.exact.ofAs<Expected>().on(value)`
  - ✅ Reports ALL failures, not just first one
  - ✅ No limit on number of assertions
  - ✅ Can be aliased for brevity (e.g., `const t = Ts.Assert.exact.ofAs`)
  - ✅ Better error messages at assertion site
  - Use in `.test.ts` AND `.test-d.ts` files

- **Type-level**: `type _ = Ts.Assert.exact<Expected, Actual>`, `Ts.Assert.Cases<...>`
  - ❌ Short-circuits on first failure
  - ❌ Limited number of cases in Cases block
  - ❌ Cannot be aliased
  - ⚠️ **CRITICAL**: Bare type assertions (`type _ = Ts.Assert.exact<>`) don't catch errors at type-check time unless wrapped in `Ts.Assert.Cases<>` - they pass through due to internal casts
  - Only use when specifically needed, otherwise prefer value-level API

- **CRITICAL**: ALWAYS read the JSDoc in `/Users/jasonkuhrt/projects/jasonkuhrt/kit/src/utils/ts/assert/` for the actual API - do not guess or use outdated examples

###### Testing Type Errors

**CRITICAL: Use @ts-expect-error for testing type errors, NEVER comment out test code**

When testing that certain code SHOULD produce TypeScript errors:
- Use `@ts-expect-error` directive with a descriptive comment explaining the expected error
- Keep the code active so it's actually compiled and tested
- This ensures the type system is working as expected
- The code will still run at runtime (may need runtime guards if it would crash)

```typescript
// ✅ CORRECT - Active test that verifies type error exists
// @ts-expect-error - string is not assignable to number
const invalid = someNumberFunction('not a number')

// ❌ WRONG - Commented out test that doesn't verify anything
// const invalid = someNumberFunction('not a number')  // ❌ Error
```

##### Table-Driven Tests with Test Utils (Kit Projects)

**CRITICAL**: Kit projects use `@wollybeard/kit/test` for table-driven tests. **NEVER use raw `test.for` from vitest**.

**READ THE JSDOC** in `/Users/jasonkuhrt/projects/jasonkuhrt/kit/src/utils/test/table/constructors.ts` for the full API documentation.

Key API methods:
- `Test.on(fn)` - Test a function directly (types inferred from function signature)
- `Test.describe(description)` - Generic mode with custom types (use `.inputType<T>()` and `.outputType<T>()`)
- `.cases()` - Add test cases
- `.test()` - Execute tests (optionally provide custom assertion function)
- `.onOutput()` - Transform expected outputs before comparison
- Nested describes: Use ` > ` separator in description (e.g., `'Parent > Child'`)

```typescript
// Function mode - types inferred
Test.on(add)
  .cases(
    [[2, 3], 5],
    [[-1, 1], 0]
  )
  .test()

// Generic mode with nested describes
Test.describe('Transform > String')
  .inputType<string>()
  .outputType<string>()
  .cases(['hello', 'HELLO'])
  .test(({ input, output }) => {
    expect(input.toUpperCase()).toBe(output)
  })

// Snapshot mode (no expected output)
Test.on(parseValue)
  .cases([['42']], [['hello']])
  .test()
```

**CRITICAL**: Do NOT wrap `Test.describe()` or `Test.on()` calls inside Vitest `describe` blocks. The `Test` module creates its own describe blocks internally. Use `Test.describe()` directly at the top level.

```typescript
// ✅ Correct - Test.describe() at top level
Test.describe('addition')
  .on(add)
  .cases([[1, 2], 3])
  .test()

// ❌ Incorrect - wrapping Test in describe
describe('addition', () => {
  Test.on(add)
    .cases([[1, 2], 3])
    .test()
})
```

##### Type Benchmarking with @ark/attest

**Purpose:** Measure TypeScript type instantiations to optimize type-level performance.

**Critical Concepts:**

1. **Baseline Expression**:
   - Include a "baseline expression" at the top of benchmark files to exclude API setup overhead
   - The baseline warms up the type evaluation machinery and caches common type computations
   - **CRITICAL**: The baseline expression must be **different** from any benchmark expression
   - If the baseline is identical to a benchmark, that benchmark will reuse cached types → 0 instantiations (false result)

2. **Type Caching**:
   - TypeScript caches type evaluations **per exact type**
   - `Simplify.All<Map<1, 2>>` and `Simplify.All<Map<3, 4>>` are different → no caching benefit
   - If baseline uses `Simplify.All<Map<0, 0>>` and benchmark uses `Simplify.All<Map<0, 0>>` → cached (low instantiations)
   - Use similar but distinct types in baseline vs benchmarks

3. **Instantiation Costs**:
   - Each benchmark measures instantiations for that specific expression in isolation
   - Costs are **not cumulative** - every expression re-evaluates from scratch (except cached types)
   - Complex pattern matches (e.g., `Map<K, V> extends Map<infer K2, infer V2>`) can be expensive (~1800+ inst)

**Example:**

```typescript
import { bench } from '@ark/attest'
import { type } from 'arktype'

// Baseline expression - similar to benchmarks but not identical
type("boolean")

bench("single-quoted", () => {
  const _ = type("'nineteen characters'")
  // Would be 2697 without baseline, now 610
}).types([610, "instantiations"])

bench("keyword", () => {
  const _ = type("string")
  // Would be 2507 without baseline, now 356
}).types([356, "instantiations"])
```

**Best Practices:**
- Always include a baseline that exercises your API but with different inputs than benchmarks
- Use `.bench-d.ts` suffix for type benchmark files (convention)
- Benchmark files are type-only - no runtime execution
- Update baseline values when intentionally changing performance characteristics
- Beware: Complex built-in types (Map, Set) have inherent pattern-matching costs in TypeScript

**Resources:**
- [arktype attest documentation](https://github.com/arktypeio/arktype/tree/main/ark/attest)
- Baseline explanation: Prevents "noise" from initial API invocation overhead

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
- Run tests: `pnpm test [path] --run` (ALWAYS use --run flag to avoid watch mode)
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

#### Git Worktree Management with `flo`

- Use `flo` tool for managing git worktrees
- When finishing a feature on a worktree, run `flo rm` to clean up
- See `flo -h` for full details and available commands

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

## Script Execution

- Never use child process exec to execute a script when you could ESM import it instead
- Never use ESM dynamic import when you could ESM statically import it instead
- Always use tsx to execute TypeScript files
- Always use `tsconfig.json` when running tsc to ensure correct configuration
- Always use `.js` extension on relative imports (ESM requirement with nodenext module resolution)
- Function contracts (public APIs) must be properly typed, but NEVER complicate internal implementations for type safety - use simple types or cast to `any` internally if needed


## Temporary Directories

- When creating temporary test projects or demos, always use local directories within the current project (e.g.,
  `test-*`, `tmp/*`, `demo-*`)
- Never attempt to use OS-level `/tmp` directory as Claude Code cannot cd outside the original working directory due to
  security restrictions
- Clean up temporary directories after use unless they contain valuable reference material

## MCP Services

### General Guidelines

- Always leverage installed MCPs: ref, serena, effect-docs, exa
- Always use ref MCP for documentation searches BEFORE using WebFetch or generic web search
- Always use exa MCP for current information instead of generic web search
- When researching complex topics, use exa's deep_researcher instead of multiple separate searches

### ref MCP

#### Purpose
- Documentation Search

#### When to Use
- Searching for technical documentation (frameworks, libraries, APIs)
- Converting any URL to markdown for analysis
- Looking up coding patterns and best practices

#### Available Functions
- `ref_search_documentation(query)` - Search across 100+ documentation sources
- `ref_read_url(url)` - Convert URL content to markdown

#### Best Practices
```typescript
// Search public documentation
ref_search_documentation('React hooks useEffect')

// Search user's private documentation
ref_search_documentation('graphql schema design ref_src=private')

// Always read the full content after searching
const results = ref_search_documentation('TypeScript decorators')
const content = ref_read_url(results[0].url)
```

### exa MCP

#### Purpose
- Advanced Web Search

#### When to Use
- Current events and real-time information
- Academic research and papers
- Company/competitive analysis
- GitHub repository searches
- Complex multi-source research

### Priority Rules

1. **Documentation**: Always try ref first, fall back to exa if not found
2. **Current Events**: Always use exa (ref doesn't have real-time data)
3. **Code Search**: Use exa's github_search for repositories
4. **Research**: Use exa's deep_researcher for comprehensive analysis

### Known Issues

- **effect-docs MCP**: Currently broken - causes terminal to hang with long-running process (likely infinite loop or spawning many processes), resulting in severe input lag (5+ second delay per keypress). Do not use for Effect documentation.
- Use alternative sources for Effect documentation (ref MCP, web search, or direct file inspection)
