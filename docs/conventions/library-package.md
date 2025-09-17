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
- All modules in `/src/exports` must be listed in the `exports` field of package.json with path mirroring, following these conventions:
  - Ignore Barrel modules (`<name>$$.ts`)
  - Ignore Test modules (`<name>.test.ts`, `<name>.test.fixtures.ts`)
  - Name of `index` is special, it maps to the main export of a path, e.g.:
    - src/exports/index -> .
    - src/exports/foo/index.ts -> ./foo

### Example

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
      index.ts      // Package Export
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
      "default": "./build/exports/bar/index.js"
    }
    "./bar/qux": {
      "default": "./build/exports/bar/qux.js"
    }
  }
}
```
