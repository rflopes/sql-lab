# Module 02: SQL basics

## SELECT, aliases, expressions

```sql
SELECT name, age * 7 AS dog_years FROM pets;
```

You can compute columns and name them with `AS`. Beware integer division: `7 / 2` is `3`, while `7 / 2.0` is `3.5`.

`SELECT DISTINCT species FROM pets;` removes duplicate rows from the result.

## WHERE

```sql
SELECT * FROM pets WHERE species = 'dog' AND age > 3;
```

Combine conditions with `AND`, `OR`, `NOT`; use parentheses, because `AND` binds tighter than `OR`.

| Need | Write |
| --- | --- |
| one of several values | `species IN ('dog', 'cat')` |
| inclusive range | `age BETWEEN 2 AND 5` |
| text pattern (`%` any text, `_` one char) | `name LIKE 'P%'` |
| same, ignoring case | `name ILIKE 'p%'` (PostgreSQL specific) |

## NULL

`NULL` means "unknown", not zero and not empty text. Any comparison with it is neither true nor false but *unknown*, and `WHERE` keeps only true rows:

```sql
SELECT * FROM pets WHERE owner_id = NULL;     -- never matches
SELECT * FROM pets WHERE owner_id IS NULL;    -- Rex
SELECT * FROM pets WHERE owner_id <> 10;      -- also hides Rex!
SELECT * FROM pets WHERE owner_id IS DISTINCT FROM 10;  -- keeps Rex
```

`IS DISTINCT FROM` is the NULL-aware "not equal".

## ORDER BY, LIMIT, OFFSET

```sql
SELECT name, age FROM pets ORDER BY age DESC, name LIMIT 2 OFFSET 1;
```

Without `ORDER BY`, the order of rows is **not defined**, even if it looks stable today. Always sort when you use `LIMIT`. Add a tie-breaker column when values can repeat.

## How a query is evaluated

You write `SELECT` first, but the database works in this order:

```
FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> DISTINCT -> ORDER BY -> LIMIT
```

That explains many errors: an alias made in `SELECT` does not exist yet in `WHERE`, but `ORDER BY` can use it.

## What is one row?

Before writing a query, say in words what **one row of the result** stands for: "one pet", "one species", "one species per owner". `SELECT DISTINCT species, owner_id` gives one row per *combination*, which is usually more rows than one per species. Most wrong results are the right columns at the wrong grain.

## Collation: how text is sorted

Sorting text depends on the database's **collation**. The project database uses `C`, which compares raw bytes: all uppercase letters sort before all lowercase ones, and a leading space sorts before everything. Most real-world databases use a language-aware collation where `'apple'` sorts before `'Banana'`. Same query, different order: remember this when you move to another server.

## Dates and timestamps

A `timestamptz` includes a time of day. `ts <= '2025-03-31'` means *midnight at the start* of March 31, so it excludes the rest of that day. The safe pattern is a half-open range: `ts >= '2025-03-01' AND ts < '2025-04-01'`. The session time zone here is always UTC.

## Comments

`-- to the end of the line` and `/* block */`.

## Common traps

- `= NULL` returns nothing; use `IS NULL`.
- `LIMIT` without `ORDER BY` returns arbitrary rows.
- Column aliases are not visible in `WHERE` (it runs before `SELECT` finishes), but they are in `ORDER BY`.
- `LIKE` is case-sensitive in PostgreSQL.

Manual: <https://www.postgresql.org/docs/17/queries.html> and <https://www.postgresql.org/docs/17/functions-comparison.html>
