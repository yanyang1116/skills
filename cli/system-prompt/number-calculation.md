# Number Calculation & Precision (Big.js)

Use Big.js to handle all number calculation and formatting that requires precision (e.g., currency, rates, totals).
If the project does not already include Big.js, install it before implementing number logic.

## Common Big.js APIs

- `Big(value)` / `new Big(value)` to construct a Big number
- Arithmetic: `plus`, `minus`, `times`, `div`, `mod`, `pow`, `sqrt`, `abs`, `neg`
- Comparison: `cmp`, `eq`, `gt`, `gte`, `lt`, `lte`
- Precision & rounding: `round`, `prec`, and global `Big.DP` / `Big.RM`
- Formatting: `toFixed`, `toPrecision`, `toExponential`, `toString`, `toNumber`, `toJSON`, `valueOf`
