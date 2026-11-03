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
- [Upper and lower case](#upper-and-lower-case)
- [Column vs table constraints](#column-vs-table-constraints)
- [`DEFAULT` does not mean `NOT NULL`](#default-does-not-mean-not-null)
- [`PRIMARY KEY` vs `UNIQUE`](#primary-key-vs-unique)
- [Foreign keys skip `NULL`](#foreign-keys-skip-null)

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

### `NULL` in `CHECK` is the opposite

`WHERE` keeps a row only when the condition is `true`. `CHECK` rejects a row only when the condition is `false`. So an unknown (`NULL`) result is **dropped** by `WHERE` but **accepted** by `CHECK`.

| Where | Passes when the condition is… | A `NULL` result is… |
|---|---|---|
| `WHERE` | `true` only | **excluded** |
| `CHECK` | anything but `false` | **accepted** |

```sql
CREATE TABLE pets (name text CHECK (name LIKE 'R%'));
INSERT INTO pets VALUES ('Max');  -- ERROR: violates check constraint
INSERT INTO pets VALUES (NULL);   -- OK: the CHECK gives NULL, not false
```

> 💡 **Tip:** `CHECK` does not stop `NULL`s. If the value is required, add `NOT NULL` too.

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

---

## Upper and lower case

Not everything in SQL ignores case:

| What | Case-sensitive? | Example |
|---|---|---|
| Keywords | **no** | `SELECT` = `select` |
| Identifiers **without** quotes | **no**: Postgres folds them to lowercase | `Pet_Id` and `PET_ID` both become `pet_id` |
| Identifiers **with** `"double"` quotes | **yes**: kept exactly as written | `"Pet_Id"` is a different column from `pet_id` |
| Values in `'single'` quotes | **yes** | `'Rex' = 'rex'` is `false` |

> ⚠️ **Warning:** A column created as `"Pet_Id"` must be quoted forever after: `SELECT Pet_Id` looks for `pet_id` and fails. Avoid quotes and mixed case in names.

> 💡 **Tip:** To compare values ignoring case, use `ILIKE` or `lower(a) = lower(b)`.

> 📝 **Note:** Standard SQL folds unquoted names to **uppercase**; Postgres folds them to **lowercase**. See also [Double vs single quotes](#double-vs-single-quotes).

---

## Column vs table constraints

Both are standard SQL. The difference is **how many columns the rule touches**:

| Form | Use it when | Example |
|---|---|---|
| **Column** constraint (inline) | The rule is about **one** column | `price numeric CHECK (price >= 0)` |
| **Table** constraint (after the columns) | The rule involves **several** columns (required here) | `CHECK (starts_at < ends_at)`, `PRIMARY KEY (a, b)` |
| `ALTER TABLE ... ADD CONSTRAINT` | The table **already exists** (migrations) | `ALTER TABLE events ADD CONSTRAINT ...` |

```sql
CREATE TABLE events (
  event_id  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  price     numeric NOT NULL CONSTRAINT events_price_positive CHECK (price >= 0),
  starts_at timestamptz NOT NULL,
  ends_at   timestamptz NOT NULL,
  CONSTRAINT events_ends_after_start CHECK (starts_at < ends_at)
);
```

> 💡 **Tip:** Name the constraints that matter (`CONSTRAINT name CHECK (...)`). The name shows up in errors (`violates check constraint "events_price_positive"`) and you need it to `DROP CONSTRAINT` later. Without one, Postgres invents it (e.g. `events_price_check`).

> 📝 **Note:** A single statement is already atomic. `BEGIN`/`COMMIT` only matters when a script has **several** statements that must succeed or fail together.

---

## `DEFAULT` does not mean `NOT NULL`

`DEFAULT` only fills a column when **no value is given**. An explicit `NULL` is a value, so it goes in. `NOT NULL` is what refuses it, and it stays on the table forever (not only while running the `ALTER`).

| Only `DEFAULT 0` | `DEFAULT 0` + `NOT NULL` |
|---|---|
| `INSERT` without the column → `0` ✅ | `INSERT` without the column → `0` ✅ |
| `INSERT ... VALUES (NULL)` → stores `NULL` ❌ | `INSERT ... VALUES (NULL)` → error ✅ |
| `UPDATE ... SET pts = NULL` → stores `NULL` ❌ | `UPDATE ... SET pts = NULL` → error ✅ |

```sql
CREATE TABLE players (name text, pts integer DEFAULT 0);
INSERT INTO players (name) VALUES ('Ana');             -- pts = 0
INSERT INTO players (name, pts) VALUES ('Rui', NULL);  -- pts = NULL, accepted
```

> ⚠️ **Warning:** `ALTER TABLE ... ADD COLUMN x integer NOT NULL` **without** a `DEFAULT` fails on a table that already has rows (they would have no value). On an empty table it works.

> 💡 **Tip:** For a required column with a starting value, use both: `ADD COLUMN x integer NOT NULL DEFAULT 0`. Existing rows get `0` in the same statement.

---

## `PRIMARY KEY` vs `UNIQUE`

In what they enforce, `PRIMARY KEY (a, b)` is exactly `UNIQUE (a, b)` + `NOT NULL` on `a` and `b`. Both create a unique index. The differences are around it:

| | `PRIMARY KEY` | `UNIQUE` |
|---|---|---|
| How many per table | **one** | as many as needed |
| `NULL` allowed | no (implicit `NOT NULL`) | **yes**, unless the columns are `NOT NULL` |
| `REFERENCES other_table` with no column | points to it | must name the column |
| Meaning | the row's **identity** (ORMs, DB tools, replication use it) | just "no repeats" |

```sql
CREATE TABLE t (a int, b int, UNIQUE (a, b));
INSERT INTO t VALUES (1, NULL), (1, NULL);  -- accepted: NULL is never equal to NULL
```

> ⚠️ **Warning:** A `UNIQUE` on nullable columns lets through any number of rows with `NULL`. Add `NOT NULL`, or (Postgres 15+) use `UNIQUE NULLS NOT DISTINCT (a, b)`.

> 💡 **Tip:** Keep a surrogate `PRIMARY KEY` (an `id` column) and add a `UNIQUE` for the business rule ("the same pet name only once per owner").

---

## Foreign keys skip `NULL`

A foreign key checks that a **non-`NULL`** value exists in the other table. A `NULL` is not checked at all: it means "points to nothing".

```sql
CREATE TABLE owners (owner_id int PRIMARY KEY);
CREATE TABLE pets (owner_id int REFERENCES owners);
INSERT INTO pets VALUES (NULL);  -- accepted: a pet with no owner
INSERT INTO pets VALUES (99);    -- ERROR: violates foreign key constraint
```

| Value in `pets.owner_id` | FK checks it? | Result |
|---|---|---|
| `7` (exists in `owners`) | yes | accepted |
| `99` (does not exist) | yes | **error** |
| `NULL` | **no** | accepted |

- Only `REFERENCES`: the link is **optional**, but valid when present.
- `NOT NULL` + `REFERENCES`: the link is **required** and valid.

> ⚠️ **Warning:** "The other table's primary key is never `NULL`" is about the **target** column. The column that points to it can still be `NULL` unless it has `NOT NULL`.

> 📝 **Note:** Same pattern as [`NULL` in `CHECK`](#null-in-check-is-the-opposite) and [`PRIMARY KEY` vs `UNIQUE`](#primary-key-vs-unique): only `NOT NULL` treats `NULL` as a violation. `CHECK (col IS NOT NULL)` also works, but prefer `NOT NULL` on the column (clearer error, visible in the table definition).
