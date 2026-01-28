# Vue 3 Development Standards

## REQUIRED: Use ref exclusively (FORBIDDEN: reactive)

You MUST use `ref()` or `shallowRef()` for all reactive state. Using `reactive()` or `shallowReactive()` is **STRICTLY FORBIDDEN**. This applies to **component state** and **composable return values**.

**✅ Correct:** 
`const user = ref({ name: 'Vue' })`  
`return { count: ref(0) }`

**❌ FORBIDDEN:** 
`const user = reactive({ name: 'Vue' })`  
`return reactive({ count: 0 })`

---

## REQUIRED: Use watch (FORBIDDEN: watchEffect)

You MUST use `watch` for explicit dependency tracking. Using `watchEffect` is **FORBIDDEN** to prevent accidental re-runs and implicit dependencies.

**✅ Correct:** `watch(source, () => { ... })`  
**❌ FORBIDDEN:** `watchEffect(() => { ... })`

---

## Use Composition API for new projects

Composition API offers better TypeScript support and logic reuse

**Recommended:** `<script setup>` for components  
**Not Recommended:** Options API for new projects

Docs: https://vuejs.org/guide/extras/composition-api-faq.html

---

## Use script setup syntax

Cleaner syntax with automatic exports

**Recommended:** `<script setup>` with `defineProps`  
**Not Recommended:** `setup()` function manually

Docs: https://vuejs.org/api/sfc-script-setup.html

---

## Use shallowRef for large objects

Avoid deep reactivity for performance

**Recommended:** `const bigData = shallowRef(largeObject)`  
**Not Recommended:** `const bigData = ref(largeObject)`

Docs: https://vuejs.org/api/reactivity-advanced.html#shallowref

---

## Define props with defineProps

Type-safe prop definitions

**Recommended:** `defineProps<{ msg: string }>()`  
**Not Recommended:** `defineProps(['msg'])`

Docs: https://vuejs.org/guide/typescript/composition-api.html#typing-component-props

---

## Use withDefaults for default values

Provide defaults for optional props

**Recommended:** `withDefaults(defineProps<Props>(), { count: 0 })`  
**Not Recommended:** `const { count = 0 } = defineProps()`

---

## Define emits with defineEmits

Type-safe event emissions

**Recommended:** `defineEmits<{ change: [id: number] }>()`  
**Not Recommended:** `emit('change', id)` without define

Docs: https://vuejs.org/guide/typescript/composition-api.html#typing-component-emits

---

## Use v-model for two-way binding

Simplified parent-child data flow

**Recommended:** `<Child v-model="value"/>`  
**Not Recommended:** `<Child :value="value" @input="value = $event"/>`

Docs: https://vuejs.org/guide/components/v-model.html

---

## Accept ref or value params

Use toValue for flexible inputs

**Recommended:** `const val = toValue(maybeRef)`  
**Not Recommended:** `const val = maybeRef.value`

Docs: https://vuejs.org/api/reactivity-utilities.html#tovalue

---

## Use Pinia for global state

Official state management for Vue 3

**Recommended:** `const store = useCounterStore()`  
**Not Recommended:** Vuex with mutations

Docs: https://pinia.vuejs.org/

---

## Define stores with defineStore

Composition API style stores

**Recommended:** `defineStore('counter', () => {})`  
**Not Recommended:** `defineStore('counter', { state })`

---

## Use storeToRefs for destructuring

Maintain reactivity when destructuring

**Recommended:** `const { count } = storeToRefs(store)`  
**Not Recommended:** `const { count } = store`

Docs: https://pinia.vuejs.org/core-concepts/#destructuring-from-a-store

---

## Use generic components

Type-safe reusable components

**Recommended:** `<script setup lang="ts" generic="T">`  
**Not Recommended:** `<script setup>` without types

Docs: https://vuejs.org/guide/typescript/composition-api.html

---

## Type template refs

Proper typing for DOM refs

**Recommended:** `const input = ref<HTMLInputElement>(null)`  
**Not Recommended:** `const input = ref(null)`

---

## Use PropType for complex props

Type complex prop types

**Recommended:** `type: Object as PropType<User>`  
**Not Recommended:** `type: Object`

---

## Use v-model modifiers

Built-in input handling

**Recommended:** `<input v-model.number="age">`  
**Not Recommended:** `<input v-model="age">` then parse

Docs: https://vuejs.org/guide/essentials/forms.html#modifiers
