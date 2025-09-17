# Library Namespace Module

## Purpose

This kind of module allows consumers to import the library as a single namespace.

## Example

```ts
// file: foo.ts
import { Bar } from 'bar'        // Package Dependency Library
import { Bar } from '#lib/bar'   // Package Local Library via sub path
import { Bar } from './bar/$.js' // Package Local Library via relative path
```

## Rules

1. If there is a Barrel Module (`/$$.ts`), then the contents of this file must be: `export * as <Name> from './$$.js'`.
   - `<Name>` must be the pascal case version of the library's directory name.

2. Else if there is no Barrel Module, then the contents of this file must be: `export * from './<Name>.js'`.
   - `<Name>` must be the kebab case version of the library's directory name.

# Library Barrel Module

## Purpose

This kind of entrypoint allows a library to assemble its public API.

## Rules

1. It may only contain re-exports from code modules within the library
1. It can never import from the namespace module of the library (`$.ts`)

## Usage Guide

- Use when you have multiple Code Modules to organize
- Can skip when there is single code module, in which case you can do `export * from './<name>.js'` in the namespace
  module

# Package Local Libraries

## Purpose

Package local libraries are libraries that are intended to be consumed only within the package they are defined in. They
are not intended to be published for external consumption. But they should be structured in a way that they could be
published in theory. The point being that they demonstrate strong encapsulation and separation of concerns within the
package.

## Rules

1. Must be located within the `/src/lib/` directory
1. Must have the following sub path entries in package.json. `<name>` is the kebab case version of the library's
   directory name.
   - `"#lib/<name>": "/src/lib/<name>/$.ts"`

1. Must have the following path entries in tsconfig.json. `<name>` is the kebab case version of the library's directory
   name.
   - `"#lib/<name>": ["src/lib/<name>/$.ts"]`

## Consumer Rules

1. Can only import PLLs via their sub path entry (as opposed to their relative path)

# Library Code Module

## Purpose

Contains actual business logic etc. of the library.

## Rules

1. Cannot use a name already reserved for special module types (e.g. `$.ts`, `$$.ts`, `$.test.ts`, `$.test.fixture.ts`)
2. Cannot import from test modules or export modules
3. Can import from other code modules within the library using relative paths only (no sub path imports)
4. Can import from other libraries using sub paths only (no relative path imports)
5. Can be within directories within the library
6. Can use TypeScript namespaces only if they only export types

### Import Permissions Summary

| Import From                   | Allowed? | How                  |
| ----------------------------- | -------- | -------------------- |
| Sibling code modules          | ✅       | `./sibling.js`       |
| Code modules in subdirectory  | ✅       | `./subdir/module.js` |
| Other libraries               | ✅       | `#lib/<name>`        |
| Own Namespace Module (`$.ts`) | ❌       | -                    |
| Own Barrel Module (`$$.ts`)   | ❌       | -                    |
| Test modules                  | ❌       | -                    |

# Testing

## Library Test Module

### Purpose

Validates the library's public interface from a consumer perspective.

### Rules

1. File name: `$.test.ts`
2. Imports ONLY from library's Namespace Module
3. Should have a describe block per export
4. Should NOT have a single top-level describe block wrapping all other blocks

### Example

```typescript
// file: /src/lib/a/$.test.ts
import { A } from './$.js'

test('.create ...', () => {
  const a = A.create()
  // ...
})
```

## Library Test Fixture Module

### Purpose

Provides reusable test data and utilities for the test suite. Centralizes test data for declarative testing.

### Rules

1. Optional, use if there is reusable test data
2. File name: `$.test.fixture.ts`
3. Imports ONLY from library's Namespace Module
4. Exports TypeScript namespace `Fx` (always `Fx`, not library name)

### Example

```typescript
// file: /src/lib/a/$.test.fixture.ts
import { A } from './$.js'

export namespace Fx {
  // ...
}
```

## Library Code Module Test Module

### Purpose

Unit tests for complex internal implementation details. Used sparingly when module complexity doesn't justify creating a
separate library.

### Rules

1. File name: `<name>.test.ts` where `<name>` matches the tested module
2. Can only import from the module being tested

### Guide

1. For exceptionally complex modules only
2. Should be rare - if you need many of these, consider restructuring
3. Example use case: Complex algorithm with simple exports
4. Indicates potential architectural smell if overused

### Example

```typescript
// file: /src/lib/a/b.test.ts
import { x,y,z } from './b.js'

test('...', () => {
  // ...
})
```

# Appendix

## Glossary

- Export Module: A Namespace module or Barrel module
- Barrel Module: A module named `$$.ts`
- Namespace Module: A module named `$.ts`
- Code Module: Any module that is not a special module type containing the actual code of the library
- Test Module: Any module related to testing
- Test Fixture Module: A module named `$.test.fixture.ts`
- Library Test Module: A module named `$.test.ts`
- Library Code Module Test Module: A module named `<name>.test.ts` where `<name>` matches the tested module

## Name Case Rules

- Directories use kebab case (e.g., `my-lib/`)
- Files use kebab case (e.g., `my-lib.ts`)
- ESM and TS namespaces use pascal case (e.g., `MyLib`)

## Library Structure Table

| Pattern                | When to use?                  | Files Required                  | Export Point |
| ---------------------- | ----------------------------- | ------------------------------- | ------------ |
| **Namespace only**     | Single implementation file    | `$.ts`, `<name>.ts`             | `$.js`       |
| **Namespace + Barrel** | Multiple implementation files | `$.ts`, `$$.ts`, multiple files | `$.js`       |

## Examples

### Library With Namespace

Simple library with a single implementation file.

```
/src/lib/mask/
  ├── $.ts          // Namespace module
  ├── mask.ts       // Single implementation file
  └── $.test.ts     // Public API tests
```

**$.ts** - Namespace module exports everything from the implementation:

```typescript
export * as Mask from './mask.js'
```

**mask.ts** - Implementation:

```typescript
export const create = (pattern: string): Mask => {
  return { pattern, apply }
}

export const apply = (mask: Mask, value: string): string => {
  // Apply mask logic...
  return value
}

export interface Mask {
  pattern: string
  apply: (value: string) => string
}
```

**Usage**:

```typescript
import { Mask } from '#lib/mask'

const phoneMask = Mask.create('(###) ###-####')
const formatted = Mask.apply(phoneMask, '5551234567')
```

### Library With Namespace + Barrel

Complex library with multiple implementation files organized via barrel.

```
/src/lib/parser/
  ├── $.ts          // Namespace module
  ├── $$.ts         // Barrel module organizing exports
  ├── tokenizer.ts  // Tokenization logic
  ├── lexer.ts      // Lexical analysis
  ├── ast.ts        // AST building
  └── $.test.ts     // Public API tests
```

**$.ts** - Namespace module points to barrel:

```typescript
export * as Parser from './$$.js'
```

**$$.ts** - Barrel organizes all exports:

```typescript
export { tokenize } from './tokenizer.js'
export { lex } from './lexer.js'
export { buildAST, type AST, type Node } from './ast.js'
export * as Utils from './utils.js'  // Sub-namespace for utilities
```

**tokenizer.ts**:

```typescript
export const tokenize = (input: string): Token[] => {
  // Tokenization logic...
  return tokens
}

export interface Token {
  type: string
  value: string
}
```

**Usage**:

```typescript
import { Parser } from '#lib/parser'

const tokens = Parser.tokenize('const x = 42')
const lexemes = Parser.lex(tokens)
const ast = Parser.buildAST(lexemes)
const cleaned = Parser.Utils.stripComments('// comment')
```

### Library With Testing

```
/src/lib/validator/
  ├── $.ts                  // Namespace module
  ├── $.test.ts             // Public API tests
  ├── $.test.fixture.ts     // Shared test fixtures
  ├── $$.ts                 // Barrel module
  ├── email.ts              // Email validation
  ├── phone.ts              // Phone validation
  ├── complex-regex.ts      // Complex internal module
  └── complex-regex.test.ts // Internal module unit tests
```

**$.test.ts** - Tests public API only:

```typescript
import { Validator } from './$.js'

describe('.isEmail', () => {
  // ...
})

describe('.isPhone', () => {
  // ...
})
```

**$.test.fixture.ts** - Shared test data:

```typescript
import { A } from '#lib/a'

export namespace Fx {
  export const something = '...'
}
```

**complex-regex.test.ts** - Internal unit tests:

```typescript
import { buildRegex, optimizePattern } from './complex-regex.js'

test('buildRegex handles escaped characters', () => {
  const regex = buildRegex('\\d+')
  expect(regex.test('123')).toBe(true)
})

test('optimizePattern reduces complexity', () => {
  const optimized = optimizePattern('[a-zA-Z]')
  expect(optimized).toBe('[a-z]')
})
```
