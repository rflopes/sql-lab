# Module 07: Scalar functions

A scalar function takes values from one row and returns a value for that row.

Toy table: `plants (id, name, sold_on, price_cents, note)`.

## Text

| Function | Example | Result |
| --- | --- | --- |
| `lower`, `upper`, `initcap` | `initcap('fERN pot')` | `Fern Pot` |
| `trim`, `ltrim`, `rtrim` | `trim('  a ')` | `a` |
| `length` | `length('fern')` | `4` |
| `substring` | `substring('abcdef', 2, 3)` | `bcd` |
| `split_part` | `split_part('a-b-c', '-', 2)` | `b` |
| `replace` | `replace('a-b', '-', '+')` | `a+b` |
| `\|\|` and `concat` | `'a' \|\| 'b'` | `ab` |
| `concat_ws` | `concat_ws(', ', 'a', NULL, 'c')` | `a, c` |

`||` returns NULL if either side is NULL. `concat` and `concat_ws` treat NULL as nothing.

**Case functions and the C collation:** this project's database uses `C` for collation *and* character type, so `lower`/`upper`/`initcap` only change ASCII letters (`É` stays `É`). With a language-aware setting they would handle accents. Worth a note in `GOTCHAS.md` when you see it.

## Numbers

`round(x)`, `round(x, 2)`, `ceil(x)`, `floor(x)`, `abs(x)`, `x % y`. Remember that `integer / integer` is integer division.

## Dates and times

```sql
date_trunc('month', ts)        -- first instant of that month
extract(hour FROM ts)          -- numeric part: year, month, day, dow, hour...
to_char(ts, 'YYYY-MM-DD Dy')   -- format as text
ts::date                       -- the calendar day (in the session time zone, UTC here)
ts + interval '3 days'
b - a                          -- timestamp minus timestamp = interval
```

`extract(day FROM interval)` returns only the *days* component of an interval, ignoring the hours. Subtracting two **dates** gives a whole number of calendar days instead. They are different questions.

## Conversion

`CAST('42' AS integer)` and `'42'::integer` do the same thing. A failed conversion is an error, not a NULL.

## CASE

```sql
CASE WHEN price_cents < 500 THEN 'cheap'
     WHEN price_cents < 2000 THEN 'normal'
     ELSE 'fancy' END
```

Branches are tested in order; the first true one wins. Without `ELSE`, no match gives NULL.

## COALESCE and NULLIF

`COALESCE(a, b, 0)` returns the first non-NULL argument. `NULLIF(a, b)` returns NULL when `a = b`, otherwise `a`; handy to avoid dividing by zero: `x / NULLIF(y, 0)`.

## jsonb (optional exercises)

`jsonb` stores a JSON document in one column. Toy example: `plants.details = '{"light": "shade", "pots": ["clay", "plastic"]}'`.

```sql
details -> 'pots'          -- the value as jsonb: ["clay", "plastic"]
details ->> 'light'        -- the value as text: shade
details ? 'light'          -- true if the top-level key exists
details -> 'pots' ? 'clay' -- true if the array contains the string
details @> '{"light": "shade"}'  -- true if it contains this piece
```

Handy for loose, rarely-queried attributes. If you filter on a key all the time, it probably deserves a real column.

## Common traps

- Arithmetic with NULL gives NULL (`5 + NULL`). Use `COALESCE`.
- `to_char` returns text, so sorting its result sorts text, not dates.
- Mixing `date` and `timestamptz` silently shifts the boundary of the day.

Manual: <https://www.postgresql.org/docs/17/functions.html>
