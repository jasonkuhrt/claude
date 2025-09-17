# Library Package Conventions

This extends [Library Local Conventions](./library-local.md) for packages where the library IS the package itself.

## Key Differences

### File Structure

- Library modules are at `/src/*` instead of `/src/lib/<name>/*`

### Package Exports

- Package.json must define exports for consumers:
- Should rely on defaults for types thus not specifying them explicitly

```json
{
  "exports": {
    ".": {
      "default": "./build/$.js"
    }
  }
}
```

For packages with multiple entry points:

```json
{
  "exports": {
    ".": {
      "default": "./build/$.js"
    },
    "./<submodule>": {
      "default": "./build/<submodule>.js"
    }
  }
}
```

## Structure Examples

### Simple Library Package

```
/package.json       // Contains exports field
/src/
  $.ts          // Namespace module
  $.test.ts     // Public API tests
  index.ts      // Single implementation
```

### Complex Library Package

```
/package.json       // Contains exports field
/src/
  $.ts          // Namespace module
  $$.ts         // Barrel module
  core.ts       // Core functionality
  utils.ts      // Utilities
  $.test.ts     // Public API tests
```

## Namespace Module Rules

Same as library-local, except:
- Located at `/src/$.ts`
- For single code module: `export * as <PackageName> from './index.js'`
- For multiple code modules: `export * as <PackageName> from './$$.js'`

Where `<PackageName>` is the PascalCase version of the package name.
