# React Development Standards

## State Management

### REQUIRED: Use useImmer for Object/Array State

**Rule**: For object or array state, **you MUST use `useImmer`** instead of `useState`.

**Rationale**: Avoid verbose spread syntax and reduce mutation errors.

**Correct:**

```javascript
import { useImmer } from 'use-immer';

const [state, updateState] = useImmer({ user: { name: '' } });
updateState((draft) => {
  draft.user.name = 'John';  // Direct mutation
});
```

**Incorrect:**

```javascript
const [state, setState] = useState({ user: { name: '' } });
setState((prev) => ({ 
  ...prev, 
  user: { ...prev.user, name: 'John' }  // Verbose spread
}));
```

> **This rule is frequently violated. Always check before using useState with objects/arrays.**

## Performance Optimization

### FORBIDDEN: Never Use Manual Memoization

**Rule**: **DO NOT** use `useMemo`, `useCallback`, or `React.memo`.

**Rationale**: 
- Project uses `babel-plugin-react-compiler` for automatic optimization
- Compiler handles caching at build time automatically
- Manual memoization creates unnecessary complexity and maintenance burden

**Forbidden:**

```javascript
// Never do this
const memoizedValue = useMemo(() => computeExpensive(a, b), [a, b]);
const memoizedCallback = useCallback(() => doSomething(a), [a]);
const MemoizedComponent = React.memo(MyComponent);
```

**Correct:**

```javascript
// Let the compiler handle it
const value = computeExpensive(a, b);
const handleClick = () => doSomething(a);
function MyComponent() { /* ... */ }
```

---

## Prioritize ahooks

**Guideline**: Prefer using ahooks over custom hook implementations when applicable.

**Rationale**:
- Reduces boilerplate code and common bugs
- Well-tested and maintained by Alibaba
- Covers most common React hook patterns

### Common Hooks Index

**Request & Async:**
- `useRequest` - data fetching with loading/error states
- `useInfiniteScroll` - infinite scroll loading

**State Management:**
- `useToggle` - boolean toggle state
- `useBoolean` - boolean state operations
- `useCounter` - counter with increment/decrement
- `useMap` - Map data structure state
- `useSet` - Set data structure state

**Storage:**
- `useLocalStorageState` - localStorage with state sync
- `useSessionStorageState` - sessionStorage with state sync
- `useCookieState` - cookie with state sync

**Effect & Timing:**
- `useDebounce` - debounced value
- `useDebounceFn` - debounced function
- `useThrottle` - throttled value
- `useThrottleFn` - throttled function
- `useInterval` - interval timer
- `useTimeout` - timeout timer

**DOM & Events:**
- `useEventListener` - addEventListener wrapper
- `useClickAway` - detect clicks outside element
- `useHover` - hover state detection
- `useFocusWithin` - focus within detection
- `useSize` - element size tracking
- `useScroll` - scroll position tracking

**Lifecycle & Advanced:**
- `useMount` - componentDidMount equivalent
- `useUnmount` - componentWillUnmount equivalent
- `useUpdateEffect` - skip first render useEffect
- `usePrevious` - get previous value
- `useCreation` - useMemo/useRef replacement
- `useMemoizedFn` - persistent function reference

### Examples

**Recommended:**

```javascript
import { useRequest, useDebounce } from 'ahooks';

const { data, loading } = useRequest(fetchData);
const debouncedValue = useDebounce(value, { wait: 300 });
```

**Not Recommended:**

```javascript
// Manual data fetching
const [data, setData] = useState(null);
const [loading, setLoading] = useState(false);
useEffect(() => {
  setLoading(true);
  fetchData().then(setData).finally(() => setLoading(false));
}, []);

// Manual debounce
const [debounced, setDebounced] = useState(value);
useEffect(() => {
  const timer = setTimeout(() => setDebounced(value), 300);
  return () => clearTimeout(timer);
}, [value]);
```
