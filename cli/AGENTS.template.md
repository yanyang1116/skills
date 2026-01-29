# Repository Guidelines

## 1. Project Overview

{{PROJECT_OVERVIEW}}

<!-- 
Description of what this project does, its main purpose, and key features.
Replace this placeholder when adapting to a specific project.
-->

---

## 2. Project Structure

{{PROJECT_STRUCTURE}}

<!-- 
Overview of the directory structure and file organization.
Explain where to find specific types of files and the overall architecture.
Replace this placeholder when adapting to a specific project.
-->

---

## 3. Code Standards

This section contains framework-specific coding guidelines and best practices.

### **React**
[`system-prompt/react.md`](./system-prompt/react.md)

**Applies to**: `.ts`, `.tsx`, `.js`, `.jsx` files in React projects

### **Vue**
[`system-prompt/vue.md`](./system-prompt/vue.md)

**Applies to**: `.vue`, `.ts`, `.js` files in Vue projects

### **Tailwind CSS**
[`system-prompt/tailwind.md`](./system-prompt/tailwind.md)

**Applies to**: styling in `.vue`, `.tsx`, `.html` files

---

## 4. Architecture & Conventions

### Naming Conventions
**Default**: `kebab-case` for all files and directories (e.g., `user-profile/`, `data-utils.ts`)
**Components**: `PascalCase` for component files ONLY (e.g., `UserProfile.vue`, `MyButton.tsx`)

### Path Aliases
<!-- 
TODO: Define project-specific path aliases.
Example: @/ (src), @components, @utils
-->
{{PATH_ALIASES}}

### File Organization & Extraction
**Colocation**: Keep related files together in the same feature folder.
**Extraction Rule**: Extract logic when a file exceeds **100 lines** or logic becomes complex.

- **Constants**: Extract to `const.ts` (Vue) or `const.ts/tsx` (React)
- **Helpers**: Extract to `helper.ts` (Pure functions)
- **Types**: Extract to `types.ts` (if shared/complex)

**Structure Example**:
```text
feature-name/
  ├── MainComponent.vue
  ├── const.ts           # Constants & Config
  ├── helper.ts          # Pure logic & Formatters
  └── types.ts           # Shared types
```

---

## 5. Development Rules

### 1. Strict Code Standards Compliance
- **All new code** must strictly follow the framework-specific guidelines
- **All code modifications** must adhere to the coding standards
- No exceptions unless explicitly requested by the user

### 2. Preserve Existing Code
- **DO NOT** modify existing code unless it's part of the current task
- **DO NOT** reformat or refactor unrelated code
- **DO NOT** change working logic for "improvements" outside the scope
- Keep changes minimal and focused on the specific requirement

### 3. AI Coding Best Practices
- **Understand before modifying**: Read and understand existing code before making changes
- **Incremental changes**: Make small, testable changes rather than large rewrites
- **Preserve patterns**: Follow existing code patterns and conventions in the file
- **Verify dependencies**: Check what depends on the code you're modifying
- **Test your changes**: Ensure changes don't break existing functionality
- **Document non-obvious**: Add comments for complex logic or non-standard approaches

### 4. Change Scope Management
- Only modify files directly related to the current task
- Don't "improve" code outside the change scope
- Resist the urge to fix unrelated issues in the same commit
- If you spot unrelated issues, report them to the user
