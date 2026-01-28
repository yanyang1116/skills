# Tailwind CSS Development Standards

## Project Configuration

### Color System
<!-- 
TODO: Define project semantic colors here.
Example: primary, secondary, surface, danger 
-->
{{THEME_COLORS}}

---

### Z-Index Scale
<!-- 
TODO: Define available z-index values.
Example: z-0, z-10... z-modal(50), z-toast(60) 
-->
{{Z_INDEX_SCALE}}

---

### Custom Utilities
<!-- 
TODO: List project-specific utility classes.
Example: .text-shadow, .scrollbar-hide 
-->
{{CUSTOM_UTILITIES}}

---

## Hover Transitions

Add smooth transitions on hover state changes

**Recommended:** `hover:bg-gray-100 transition-colors`  
**Not Recommended:** `hover:bg-gray-100` (no transition)

---

## Grid Gaps

Use consistent gap utilities for spacing

**Recommended:** `grid gap-6`  
**Not Recommended:** `grid` with `mb-4` on each item

Docs: https://tailwindcss.com/docs/gap

---

## Flexbox Alignment

Use flex utilities for alignment

**Recommended:** `flex items-center justify-between`  
**Not Recommended:** Nested divs for alignment

---

## Font Size Scale

Use consistent text size scale

**Recommended:** `text-lg`  
**Not Recommended:** `text-[17px]`

Docs: https://tailwindcss.com/docs/font-size

---

## Text Truncation

Handle long text gracefully

**Recommended:** `line-clamp-2`  
**Not Recommended:** No overflow handling

Docs: https://tailwindcss.com/docs/text-overflow

---

## Disabled States

Clear disabled styling

**Recommended:** `disabled:opacity-50 disabled:cursor-not-allowed`  
**Not Recommended:** Same style as enabled

---

## Placeholder Styling

Style placeholder text appropriately

**Recommended:** `placeholder:text-gray-400`  
**Not Recommended:** Default dark placeholder

---

## Loading States

Show loading feedback

**Recommended:** `<Button disabled><Spinner/></Button>`  
**Not Recommended:** Button without loading state

---

## Avoid @apply Bloat

Use direct utilities in HTML

**Recommended:** `class='px-4 py-2 rounded'`  
**Not Recommended:** `@apply px-4 py-2 rounded;`

Docs: https://tailwindcss.com/docs/reusing-styles

---

## Group and Peer

Style based on parent/sibling state

**Recommended:** `group-hover:text-blue-500`  
**Not Recommended:** `onMouseEnter={() => setHover(true)}`

Docs: https://tailwindcss.com/docs/hover-focus-and-other-states#styling-based-on-parent-state

---

## SVG Explicit Dimensions

Add width/height attributes to SVGs to prevent layout shift before CSS loads

**Recommended:** `<svg class='size-6' width='24' height='24'>`  
**Not Recommended:** `<svg class='size-6'>`
