# Library Conventions

## Local Libraries

Follow this layout:

```
src/lib/
  └── <lib-name>/
      ├── $.ts          # Namespace export: export * as <LibName> from './$$.ts'
      ├── $$.ts         # Barrel export: export * from './*.ts' (excluding $ files)
      ├── *.test.ts     # Tests (import from namespace)
      └── *.ts          # Implementation modules
```

### Library Pattern Rules

- Each library exports a namespace that can be "opened" via import path
- `$` = Namespace file (one thing), `$$` = Barrel exports (many things)
- Library name in kebab-case, namespace in PascalCase
- Requires manual import mappings in package.json:
  ```json
  {
    "imports": {
      "#lib/<name>": "./src/lib/<name>/$.ts",
      "#lib/<name>/<name>": "./src/lib/<name>/$$.ts"
    }
  }
  ```
- Usage: `import { Mask } from '#lib/mask'` (namespace) or `import { create } from '#lib/mask/mask'` (direct)
- Benefits: Self-contained libs, no naming collisions, cleaner export names by eliding domain term

### Library Testing Pattern

- One test file per library: `$.test.ts`
- Test via namespace: Import from `./$.ts`
- Test public API only
- No top-level describe for library name
- Top-level describe for each exported function
- Only add `[module].test.ts` for complex modules that need unit testing

### Domain-Driven Module Organization

- Colocate data types with their primary operations
- Name modules after domain concepts (`mask.ts`), not generic terms (`types.ts`)
- Domain module contains type + constructor/primary operations
- Secondary operations get their own modules with related types
- Use `internal.ts` only for shared internal utilities
- Never use `types.ts`, `utils.ts`, `helpers.ts` at library root

### Validation & Fixes

Use the `/fix-conventions` command to check and auto-fix common library layout issues.