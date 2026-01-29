# TypeScript Guidelines

## Global Type Definitions
<!--
TODO: List all global type definition files used in this project (e.g., env typings, shims, global.d.ts).
Explain where they live and what they declare so contributors understand what's globally available.
Fill this section according to the project's requirements.
-->

## Import Rules for .d.ts and Type-only Imports

- Always include the `.d` suffix when importing declaration files.
- For type-only imports (except enums), use the `type` modifier.

**Good**
```ts
import type { UserProfile } from "./types.d.ts";
import { Status } from "./status"; // enum can be value import
```

**Bad**
```ts
import { UserProfile } from "./types.ts"; // missing .d suffix for declaration file
import { UserProfile } from "./types.d.ts"; // type-only import missing `type`
```
