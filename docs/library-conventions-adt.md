# Library Conventions: ADT Extension

This document extends the base [Library Conventions](./library-conventions.md) with patterns specific to Algebraic Data Types (ADTs) and discriminated unions.

## Library: Union ADT (Algebraic Data Type) Pattern

- About
  - Pattern for discriminated unions with multiple member types
  - Provides type-safe access to union members and constructors
  - Library name should match the ADT name (e.g., `lifecycle-event` lib for `LifecycleEvent` ADT)
- Rules
  1. Library directory name matches the ADT name in kebab-case
  2. Union definition imports members directly (not via Barrel Export)
  3. Barrel Export exports members as namespaces
  4. Structure:
  ```
  /lib/lifecycle-event/
    ├── $.ts                    // export * as LifecycleEvent from './$$.js'
    ├── $$.ts                   // exports member namespaces
    ├── lifecycle-event.ts      // union definition
    ├── added.ts               // member
    └── removed.ts             // member
  ```
  - Implementation (example with Effect Schema):
    ```typescript
    // lifecycle-event.ts
    import { Added } from './added.js' // direct import, not from $$.ts
    import { Removed } from './removed.js'
    export const LifecycleEvent = Schema.Union(Added, Removed)

    // $$.ts
    export * as Added from './added.js'
    export * from './lifecycle-event.js'
    export * as Removed from './removed.js'
    ```

## ADT Unions - Comprehensive Guide

### Overview

ADT (Algebraic Data Type) Unions are discriminated unions with multiple member types that provide type-safe access to union members and constructors. This is a specialized pattern commonly used with schema libraries (like Effect Schema, Zod, etc.) for complex data modeling.

### Core Principles

- **ADT Level**
  - Choose a name using pascal case
  - Create a module:
    - named as `<self>.ts` using kebab case
    - Each member should be a file (NOT a directory) in the same directory
    - Each member should be re-exported as namespace from $$.ts using `export * as <MemberName> from './<member>.js'`
    - The union schema itself is exported from the main module file
    - Imports all members and exports a union schema of them
    - example (with Effect Schema): `export const Catalog = Schema.Union(Versioned,Unversioned)` in `catalog.ts` under `catalog/` directory

- **Member Level**
  - Use tagged/discriminated structures to define members (e.g., `Schema.TaggedStruct` in Effect)
  - Each member is a single file (e.g., `versioned.ts`, `unversioned.ts`)
    - tag name: `<adt name><member name>` pascal case
    - naming of export schema in module: `<member name>` pascal case
    - example: `export const Versioned = TaggedStruct('CatalogVersioned', ...` in `versioned.ts` under `catalog/` directory

### ADT Union Directory Structure

```
src/lib/catalog/
├── $.ts          # export * as Catalog from './$$.js'  <-- ALWAYS points to $$.js when it exists
├── $$.ts         # export * as Versioned from './versioned.js'
│                 # export * as Unversioned from './unversioned.js'
│                 # export * from './catalog.js'
├── catalog.ts    # import { Versioned } from './versioned.js'
│                 # import { Unversioned } from './unversioned.js'
│                 # export const Catalog = createUnion(Versioned, Unversioned)
├── versioned.ts  # export const Versioned = createTaggedType('CatalogVersioned', { ... })
└── unversioned.ts # export const Unversioned = createTaggedType('CatalogUnversioned', { ... })
```

### ADT Import Patterns

**CRITICAL RULE**: For ADT unions, ALWAYS import ONLY from $.js (namespace), NEVER from $$.js (barrel)

```typescript
// ✅ CORRECT: Import ONLY from namespace
import { LifecycleEvent } from './lifecycle-event/$.js'
import { Lifecycle } from './lifecycle/$.js'

// ❌ WRONG: NEVER do this
import { Added, LifecycleEvent, Removed } from './lifecycle-event/$$.js'
import { ObjectType, InterfaceType, Lifecycle } from './lifecycle/$$.js'

// To access members, use the namespace pattern:
const added: LifecycleEvent.Added.Added = LifecycleEvent.Added.make({...})
const objectType: Lifecycle.ObjectType.ObjectType = Lifecycle.ObjectType.make({...})
```

### Correct ADT imports in consuming code

```typescript
// Import the union type from $.ts
import { LifecycleEvent } from './lifecycle-event/$.js'

// Import member namespaces from $$.ts
import { Added, Removed } from './lifecycle-event/$$.js'

// Use member types via namespace
const addedEvent: Added.Added = Added.make({ ... })
const removedEvent: Removed.Removed = Removed.make({ ... })
```

### ADT Factory Pattern

For discriminated unions, use the factory pattern to create members:

```typescript
// Define union (example with Effect Schema)
const MyUnion = Schema.Union(MemberA, MemberB)

// Create factory using your library's union utilities
const make = createUnionFactory(MyUnion)  // Library-specific implementation

// Use with full type safety - tag determines fields and return type
const instanceA = make('MemberATag', {/* fields specific to MemberA */})
const instanceB = make('MemberBTag', {/* fields specific to MemberB */})
```

**Benefits:**

- Type-safe tag selection with autocomplete
- Automatic field inference based on tag
- No manual conditionals needed
- Single source of truth for union member creation

**Example with LifecycleEvent:**

```typescript
// Before: verbose manual approach
const createEvent = (type: 'Added' | 'Removed') => {
  const baseEvent = { schema, revision }
  return type === 'Added'
    ? LifecycleEvent.Added.make(baseEvent)
    : LifecycleEvent.Removed.make(baseEvent)
}

// After: clean factory approach (library-specific implementation)
const createEvent = createUnionFactory(LifecycleEvent.LifecycleEvent)
const added = createEvent('LifecycleEventAdded', { schema, revision })
const removed = createEvent('LifecycleEventRemoved', { schema, revision })
```

### Critical: Schema Make Constructor

**ALWAYS** use the schema's `make` constructor when manually constructing values:

```typescript
// ✅ CORRECT - Use schema.make
const revision = Revision.make({ date: '2024-01-15', version: '1.0.0' })

// ❌ WRONG - Manual object construction
const revision = { _tag: 'Revision', date: '2024-01-15', version: '1.0.0' }

// The make constructor ensures:
// - Type safety and validation
// - Proper tag assignment
// - Default values are applied
// - Transformations are executed
```

### ADT Library Rules Summary

1. **Library directory name** matches the ADT name in kebab-case
2. **Union definition** imports members directly (not via Barrel Export)
3. **Barrel Export** exports members as namespaces
4. **Namespace import pattern** for external consumers
5. **Factory pattern** for type-safe member creation
6. **Schema.make constructors** for all value creation

This comprehensive ADT pattern ensures type safety, maintainability, and consistent API design across complex discriminated union types.