# SQL Gotchas

> Write here, in your own words, every surprise or mistake you hit. Review it at each checkpoint.

## Contents

- [`BETWEEN`](#between)
- [`IN`](#in)
- [`ILIKE`](#ilike)
- [`NULL`](#null)
- [`IS DISTINCT FROM`](#is-distinct-from)
- [Double vs single quotes](#double-vs-single-quotes)
- [`RETURNING`](#returning)
- [Subqueries need parentheses](#subqueries-need-parentheses)
- [`UPDATE` without `WHERE`](#update-without-where)
- [Inserting several rows](#inserting-several-rows)
- [`INSERT ... SELECT` from a `VALUES` list](#insert--select-from-a-values-list)
- [Always list the columns in `INSERT`](#always-list-the-columns-in-insert)
- [Don't use keywords as aliases](#dont-use-keywords-as-aliases)
- [`ROUND` vs `CEIL`](#round-vs-ceil)
- [`ON CONFLICT` (upsert)](#on-conflict-upsert)
- [`GENERATED ALWAYS` vs `BY DEFAULT` (identity)](#generated-always-vs-by-default-identity)

---

## `BETWEEN`

When we want to filter a value in a range, we can use `BETWEEN` instead of `>=` and `<=`.

> ❗ **Important:** `BETWEEN` **includes both limits**.

---

## `IN`

When we want to filter a value that matches a group of predefined values, we can use `IN` instead of multiple `OR`s.

---

## `ILIKE`

When comparing strings, `ILIKE` compares **ignoring the case**.

> 📝 **Note:** `ILIKE` only exists in **Postgres**; in other database systems we should use `LOWER`.

---

## `NULL`

Any comparison with `NULL` returns `NULL` (**unknown**), and `WHERE` only returns rows where the condition is **true**.

```sql
WHERE city != 'Coimbra'
```

> ⚠️ **Warning:** A row where `city` is `NULL` **won't be returned** by the `WHERE` clause, even though we might want it to be.

---

## `IS DISTINCT FROM`

When we want to filter by excluding a value, we can use `IS DISTINCT FROM`, which **always returns `true` or `false`**, even for rows with a `NULL` field.

> 💡 **Tip:** If we use `!=`, we do not get rows where the field is `NULL`. See [`NULL`](#null).

---

## Double vs single quotes

SQL treats quotes differently:

| Quotes | Used for | Example |
|---|---|---|
| `"double"` | **identifiers** | `"order"` |
| `'single'` | **values** | `'Coimbra'` |

---

## `RETURNING`

When we want the insert to return data from the newly inserted rows, we can use `RETURNING` with the **column names**.

```sql
RETURNING id, city
```

> 💡 **Tip:** `RETURNING` also works with `UPDATE` and `DELETE`, returning the changed or deleted rows.

> 📝 **Note:** `RETURNING` is not standard SQL; it exists in **Postgres** (and a few others), but not everywhere.

---

## Subqueries need parentheses

When we want to use a subquery, we should **wrap it in parentheses**.

```sql
INSERT INTO categories (name, parent_id) VALUES
('Compasses', (SELECT category_id FROM categories WHERE name = 'Navigation'));
```

---

## `UPDATE` without `WHERE`

An `UPDATE` (or `DELETE`) without `WHERE` changes **every row** in the table.

```sql
UPDATE players SET active = false;                  -- every player!
UPDATE players SET active = false WHERE id = 42;    -- only one
```

> ⚠️ **Warning:** Always write the `WHERE` first. Run it as a `SELECT` with the same `WHERE` to check which rows will change.

---

## Inserting several rows

One `INSERT` can add several rows: each row goes **inside parentheses**, and rows are **separated by commas**.

```sql
INSERT INTO players (name, team_id) VALUES
('Ana', 1),
('Rui', 1);
```

---

## `INSERT ... SELECT` from a `VALUES` list

An `INSERT` doesn't need `VALUES`: it can take its rows from a **`SELECT`**. A `VALUES` list can act as a temporary table, so a repeated subquery is written **only once**.

```sql
INSERT INTO players (name, team_id)
SELECT v.name, (SELECT team_id FROM teams WHERE name = 'Lions')
FROM (VALUES ('Ana'), ('Rui')) AS v(name);
```

> 💡 **Tip:** `AS v(name)` names the temporary table (`v`) and its column (`name`).

---

## Always list the columns in `INSERT`

Write `INSERT INTO t (a, b) VALUES ...`, not `INSERT INTO t VALUES ...`.

> ⚠️ **Warning:** Without the column list, values are matched by the **column order** of the table, and the insert breaks (or silently fills the wrong columns) if the table changes.

---

## Don't use keywords as aliases

An alias like `values`, `order` or `user` may work, but it is **confusing to read** and may fail in other contexts or databases. Prefer short neutral names like `v` or `new_rows`.

---

## `ROUND` vs `CEIL`

- `CEIL` **always rounds up**.
- `ROUND` goes to the **nearest** value; halves round away from zero (up, for positive numbers).

```sql
SELECT ceil(879.375), round(879.375);   -- 880 vs 879
SELECT ceil(879.5),   round(879.5);     -- 880 vs 880
```

> ⚠️ **Warning:** A passing check doesn't prove the rounding is right: with "friendly" data, `CEIL` and `ROUND` can give the same results. Test with values like `.375`.

> 📝 **Note:** This is for `numeric`. With `double precision` (`float`), Postgres `ROUND` may round halves to the **even** number: `round(2.5::float)` gives `2`.

---

## `ON CONFLICT` (upsert)

`INSERT ... ON CONFLICT` inserts new rows and, when a row would duplicate a unique value, **updates it instead** (or ignores it).

```sql
INSERT INTO players (email, name, score)
VALUES ('ana@x.pt', 'Ana', 10)
ON CONFLICT (email)
DO UPDATE SET name  = EXCLUDED.name,
              score = EXCLUDED.score;
```

- `ON CONFLICT (col)`: the conflict target goes **in parentheses** and must have a `UNIQUE` index or primary key.
- `DO UPDATE SET`: list **column by column** what changes. Columns not listed keep their values.
- `EXCLUDED`: the row we **tried** to insert. `EXCLUDED.name` is the new value; `name` alone is the current one.

> 💡 **Tip:** `ON CONFLICT (col) DO NOTHING` skips duplicates instead of updating them.

> 📝 **Note:** `ON CONFLICT` is not standard SQL (Postgres and SQLite have it); the standard uses `MERGE`, which Postgres also supports since version 15.

---

## `GENERATED ALWAYS` vs `BY DEFAULT` (identity)

Both make Postgres generate the id from a sequence. The difference is what happens when an `INSERT` sends its own value:

- `GENERATED ALWAYS AS IDENTITY`: the id is **always** generated. When user provides an explicit value is an error is thrown.
- `GENERATED BY DEFAULT AS IDENTITY`: the id is generated **only when none is sent**. An explicit value provided by the user is accepted.

```sql
CREATE TABLE pets (
  pet_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name   text NOT NULL
);

INSERT INTO pets (pet_id, name) VALUES (5, 'Rex');
-- ERROR: cannot insert a non-DEFAULT value into column "pet_id"

INSERT INTO pets (pet_id, name) OVERRIDING SYSTEM VALUE VALUES (5, 'Rex');
-- works: the escape hatch for migrations and data imports
```

> ⚠️ **Warning:** With `BY DEFAULT`, a manual id does **not** move the sequence forward. Insert `5` by hand and, when the sequence reaches 5, the next normal `INSERT` fails with a duplicate key.

> 💡 **Tip:** Prefer `ALWAYS`: it stops ids from being set by accident.
