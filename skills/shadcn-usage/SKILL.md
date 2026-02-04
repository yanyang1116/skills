---
name: shadcn-usage
description: Trigger only in React projects when the user mentions shadcn/ui (shadui/shadcn) or asks for UI layout, design, styling, or component work that should use shadcn/ui. Requires shadcn-mcp; if missing, stop and ask the user to install. If shadcn/ui is requested but not initialized, stop and ask the user to initialize.
---

# Shadcn Usage

## Trigger Conditions

- **Step 1 — Framework gate (mandatory)**: Trigger only in React projects (e.g., `package.json` has `react` or `react-dom`). If the project is not React, never trigger this skill.
- **Step 2 — Intent (if / else, mandatory)**:
  - **If** the user explicitly asks to use shadcn/ui (shadui/shadcn), **always trigger**.
  - **Else if** the user asks for UI changes (styling, layout, components, or visual arrangement) **and** the project already has shadcn/ui initialized (`components.json` exists or `components/ui/` exists), **always trigger**.
  - **Else** do not trigger.
- **Opt-out**: If the user explicitly says "do not use shadcn/ui," do not use this skill.

## Hard Stops (must stop and ask user)

1) **shadcn-mcp is required**  
If shadcn-mcp is not available, tell the user to install it and stop. Do not continue.

2) **shadcn/ui not initialized**  
If shadcn/ui is required for the request (explicitly requested or clearly needed for the UI work) and the project is not initialized (no `components.json` and no `components/ui/`), tell the user to initialize shadcn/ui and stop. Do not continue.

## Behavior Rules

- For layout/design/style changes, first consider using shadcn/ui components. Do not hand-roll UI components or styles by default.
- Only create custom components when:
  - the user explicitly says "don't use shadcn/ui," or
  - the user repeatedly says shadcn/ui styling is unsatisfactory and asks for a custom build.
- Use official shadcn-mcp for adding or composing components. Do not invent manual install steps.

## Minimal Checks

- **React check**: Look for `react`/`react-dom` in `package.json`.
- **Initialization check**: Prefer `components.json`; otherwise check for `components/ui/`.
