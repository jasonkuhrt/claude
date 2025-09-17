# Library Package Conventions

This extends [Library Local Conventions](./library-local.md) for packages where the library IS the package itself.

This document specifies the differences.

## Namespace Module

- For `<name>` it uses the PascalCase version of the package name.

## File Location

- modules are located at `/src/*` instead of `/src/lib/<name>/*`

## Package Exports

- Package.json must define exports for consumers
- The `types` export condition should be omitted, relying on the default.

## Single Export Package

- Namespace Module should be exposed at main export (`".": "./<build path>/$.js"`)

### Example

Layout

```
/package.json       // Contains exports field
/src/
  $.ts              // Namespace module
  $.test.ts         // Public API tests
  index.ts          // Single implementation
```

Package.json

```json
{
  "exports": {
    ".": {
      "default": "./build/$.js"
    },
  }
}
```

## Multi Export Package

- If there are multiple package exports, there should be a `./src/exports` directory that contains export modules
- All modules in `/src/exports` must be listed in the `exports` field of package.json following these rules:
  - If is Barrel module (`$$.ts`, `<name>$$.ts`), ignore
  - If is Test module (`<name>.test.ts`, `<name>.test.fixtures.ts`), ignore
  - If is `index.ts`, becomes the main export of parent path, e.g.:
    - src/exports/index.ts -> .
    - src/exports/foo/index.ts -> ./foo
  - If is `$.ts`, extends semantics of `index.ts` with:
      - Must be a namespace module
      - Its namespace is the PascalCase version of the directory name, or, if main package export, the PascalCase version of the package name.
  - If is `<name>$.ts`, extends semantics of `<name>.ts` with:
    - Must be a namespace module
    - Its namespace is the PascalCase version of the file name
    - It maps to package export of`./...<path>/<name>` meaning the `$` suffix is elided
  - If is `<name>.ts`, becomes package export of `./...<path>/<name>`
- Additional conventions that should be used:
  - If a package export needs a barrel module then use convention of `<name>$$.ts` in same directory
- The following states are invalid:
  - Presence of both `index.ts` and `$.ts` in same directory
  - Presence of both `<name>.ts` and `<name>$.ts` in same directory

### Example

Layout

```
/package.json     // Contains exports field
/src/
  a.ts        // Code Module
  b.ts        // Code Module
  c.ts        // Code Module
  exports/
    index.ts      // Package Export
    index.test.ts // Public API tests
    index$$.ts    // Barrel module
    foo.ts        // Package Export
    foo$$.ts      // Barrel module (for foo.ts)
    bar/
      $.ts          // Package Export, Namespace Module
      qux.ts        // Package Export
```

Package.json

```json
{
  "exports": {
    ".": {
      "default": "./build/exports/$.js"
    },
    "./foo": {
      "default": "./build/exports/foo.js"
    },
    "./bar": {
      "default": "./build/exports/bar/$.js"
    }
    "./bar/qux": {
      "default": "./build/exports/bar/qux.js"
    }
  }
}
```
