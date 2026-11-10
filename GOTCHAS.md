# SQL Gotchas

> Write here, in your own words, every surprise or mistake you hit. Review it at each checkpoint.

## Contents

- [Names, quotes and case](#names-quotes-and-case)
  - [Double vs single quotes](#double-vs-single-quotes)
  - [Upper and lower case](#upper-and-lower-case)
  - [`ILIKE`](#ilike)
  - [Don't use keywords as aliases](#dont-use-keywords-as-aliases)
- [`NULL`s](#nulls)
  - [`NULL`](#null)
  - [`IS DISTINCT FROM`](#is-distinct-from)
- [Querying](#querying)
  - [`BETWEEN`](#between)
  - [`IN`](#in)
  - [Subqueries need parentheses](#subqueries-need-parentheses)
  - [Filtering by a related table: `EXISTS` vs `JOIN` + `DISTINCT`](#filtering-by-a-related-table-exists-vs-join--distinct)
  - [`ROUND`, `CEIL` and `FLOOR`](#round-ceil-and-floor)
- [Joins](#joins)
  - [Join types](#join-types)
  - [Where a join's `NULL`s come from](#where-a-joins-nulls-come-from)
  - [`ON` drops `NULL` keys](#on-drops-null-keys)
  - [`LEFT` vs `RIGHT`: the table order matters](#left-vs-right-the-table-order-matters)
  - [Finding rows with no match](#finding-rows-with-no-match)
  - ["Never": four ways to write it](#never-four-ways-to-write-it)
  - [A link table is often enough](#a-link-table-is-often-enough)
  - [Joins change the grain](#joins-change-the-grain)
  - [When `CROSS JOIN` is useful](#when-cross-join-is-useful)
  - [Stacking results: `UNION`, `INTERSECT`, `EXCEPT`](#stacking-results-union-intersect-except)
  - [Join traps](#join-traps)
- [Changing data](#changing-data)
  - [Always list the columns in `INSERT`](#always-list-the-columns-in-insert)
  - [Inserting several rows](#inserting-several-rows)
  - [`INSERT ... SELECT` from a `VALUES` list](#insert--select-from-a-values-list)
  - [`RETURNING`](#returning)
  - [`ON CONFLICT` (upsert)](#on-conflict-upsert)
  - [`UPDATE` without `WHERE`](#update-without-where)
- [Defining tables](#defining-tables)
  - [Column vs table constraints](#column-vs-table-constraints)
  - [`GENERATED ALWAYS` vs `BY DEFAULT` (identity)](#generated-always-vs-by-default-identity)
  - [`DEFAULT` does not mean `NOT NULL`](#default-does-not-mean-not-null)
  - [`PRIMARY KEY` vs `UNIQUE`](#primary-key-vs-unique)
  - [`UNIQUE` on an expression needs an index](#unique-on-an-expression-needs-an-index)
  - [Foreign keys skip `NULL`](#foreign-keys-skip-null)
  - [`REFERENCES` without a column](#references-without-a-column)

---

## Names, quotes and case

### Double vs single quotes

SQL treats quotes differently:

| Quotes | Used for | Example |
|---|---|---|
| `"double"` | **identifiers** | `"order"` |
| `'single'` | **values** | `'Coimbra'` |

---

### Upper and lower case

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

### `ILIKE`

When comparing strings, `ILIKE` compares **ignoring the case**.

> 📝 **Note:** `ILIKE` only exists in **Postgres**; in other database systems we should use `LOWER`.

---

### Don't use keywords as aliases

An alias like `values`, `order` or `user` may work, but it is **confusing to read** and may fail in other contexts or databases. Prefer short neutral names like `v` or `new_rows`.

---

## `NULL`s

### `NULL`

Any comparison with `NULL` returns `NULL` (**unknown**), and `WHERE` only returns rows where the condition is **true**.

```sql
WHERE city != 'Coimbra'
```

> ⚠️ **Warning:** A row where `city` is `NULL` **won't be returned** by the `WHERE` clause, even though we might want it to be.

#### `NULL` in `CHECK` is the opposite

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

### `IS DISTINCT FROM`

When we want to filter by excluding a value, we can use `IS DISTINCT FROM`, which **always returns `true` or `false`**, even for rows with a `NULL` field.

> 💡 **Tip:** If we use `!=`, we do not get rows where the field is `NULL`. See [`NULL`](#null).

---

## Querying

### `BETWEEN`

When we want to filter a value in a range, we can use `BETWEEN` instead of `>=` and `<=`.

> ❗ **Important:** `BETWEEN` **includes both limits**.

---

### `IN`

When we want to filter a value that matches a group of predefined values, we can use `IN` instead of multiple `OR`s.

---

### Subqueries need parentheses

When we want to use a subquery, we should **wrap it in parentheses**.

```sql
INSERT INTO categories (name, parent_id) VALUES
('Compasses', (SELECT category_id FROM categories WHERE name = 'Navigation'));
```

---

### Filtering by a related table: `EXISTS` vs `JOIN` + `DISTINCT`

A `JOIN` returns **one row per match**. When it is used only as a filter ("has at least one…"), a row that matches several times comes out **duplicated**.

```sql
-- Customers with at least one order over 100
SELECT c.*
FROM customers c
JOIN orders o ON o.customer_id = c.id AND o.total > 100;
-- a customer with 3 such orders appears 3 times
```

There are two fixes:

| Fix | What it does | Problem |
|---|---|---|
| `SELECT DISTINCT c.*` | creates the duplicates, then **removes** them | only works while the duplicate rows are identical in **every** column; adding `o.total` to the `SELECT` brings them back; extra work (per-row subqueries run before the dedup) |
| `WHERE EXISTS (...)` | asks "is there at least one?", so it **never creates** duplicates | none for this case |

```sql
SELECT c.*
FROM customers c
WHERE EXISTS (
  SELECT 1                     -- what it selects doesn't matter
  FROM orders o
  WHERE o.customer_id = c.id   -- links the subquery to the outer row
    AND o.total > 100
);
```

> ⚠️ **Warning:** `EXISTS` takes a **subquery**, not a list: `col EXISTS (1, 4)` is a syntax error. It is a true/false condition, so it goes in `WHERE`, not in `FROM`/`JOIN`.

> ⚠️ **Warning:** Without the link (`o.customer_id = c.id`), the subquery asks "is there such an order **anywhere**?" and the answer is the same for every row.

> 💡 **Tip:** Use a `JOIN` when you need columns from the other table. Use `EXISTS` when you only need to **filter** by it. `c.id IN (SELECT customer_id FROM orders WHERE total > 100)` also works without duplicates.

---

### `ROUND`, `CEIL` and `FLOOR`

- `CEIL` **always rounds up**.
- `FLOOR` **always rounds down**.
- `ROUND` goes to the **nearest** value; halves round away from zero (up, for positive numbers).

```sql
SELECT ceil(879.375), floor(879.375), round(879.375);   -- 880 vs 879 vs 879
SELECT ceil(879.5),   floor(879.5),   round(879.5);     -- 880 vs 879 vs 880
SELECT ceil(-2.5),    floor(-2.5),    round(-2.5);      --  -2 vs  -3 vs  -3
```

> ⚠️ **Warning:** A passing check doesn't prove the rounding is right: with "friendly" data, `CEIL`, `FLOOR` and `ROUND` can give the same results. Test with values like `.375` and `.5`.

> ⚠️ **Warning:** "Up" and "down" mean **towards bigger / smaller numbers**, not away from / towards zero. For negatives, `FLOOR(-2.5)` is `-3`, not `-2`.

> 📝 **Note:** This is for `numeric`. With `double precision` (`float`), Postgres `ROUND` may round halves to the **even** number: `round(2.5::float)` gives `2`.

---

## Joins

Toy tables used below:

```
owners: id | name        pets: id | name    | owner_id
        10 | Ana               1 | Biscuit | 10
        11 | Bruno             2 | Mochi   | 10
        12 | Carla             3 | Pip     | 11
                               4 | Rex     | NULL
```

### Join types

| Join | Keeps | Toy example |
|---|---|---|
| `INNER JOIN` (or just `JOIN`) | matching pairs only | Rex and Carla disappear |
| `LEFT JOIN` | all left rows; right side `NULL` when nothing matches | Rex stays, owner `NULL` |
| `RIGHT JOIN` | all right rows (mirror of `LEFT`) | Carla stays, pet `NULL` |
| `FULL JOIN` | all rows of both sides | Rex and Carla both stay |
| `CROSS JOIN` | every left row with every right row, no condition | 4 × 3 = 12 rows |

- Use table aliases (`p`, `o`) when a column name exists in both tables, otherwise: `column reference "name" is ambiguous`.
- Same column name on both sides: `USING (col)` instead of `ON a.col = b.col`.

> 📝 **Note:** Hit in 05-01 to 05-04.

---

### Where a join's `NULL`s come from

`FROM` + `JOIN` first build one combined set of rows; `SELECT` only picks columns from it. When a row has **no match**, the outer join fills **every column of the missing side** with `NULL` (padding). The side that kept the row keeps its real values, `NULL`s included.

```sql
SELECT p.name, p.owner_id, o.id, o.name
FROM pets p
FULL JOIN owners o ON o.id = p.owner_id;
```

| p.name | p.owner_id | o.id | o.name | Why the `NULL`s |
|---|---|---|---|---|
| Rex | `NULL` | `NULL` | `NULL` | `p.owner_id`: real value stored in `pets`; `o.*`: padding, no owner matched |
| `NULL` | `NULL` | 12 | Carla | `p.*`: padding, no pet matched |

> ⚠️ **Warning:** The `NULL` in a column belongs to **that column's table**. `o.id` is `NULL` on Rex's row because the `owners` side is missing, not because of anything in `pets`.

> 💡 **Tip:** `RIGHT`/`LEFT` instead of `FULL` only changes **which rows survive**; it never fills a padded column. To show "this side's value, or else the other side's", use `COALESCE(a.col, b.col)`. It helps when each side has its own copy of the key (e.g. two customer lists joined by email).

> 📝 **Note:** Logical order of a query: `FROM`/`JOIN` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY` → `LIMIT`. Postgres doesn't really build a temporary table; the planner may do it in another order, but the result is always as if it followed this one.

> 📝 **Note:** Hit in 05-11 (thought an order without an employee got its `NULL` from `orders`; it was padding from `employees`).

---

### `ON` drops `NULL` keys

`ON` works like `WHERE`: a pair survives only when the condition is **true**. `NULL = anything` is unknown, so a row whose join key is `NULL` **never matches**, whatever is on the other side. See [`NULL`](#null).

```sql
SELECT p.name, o.name FROM pets p JOIN owners o ON o.id = p.owner_id;
-- Rex (owner_id NULL) is gone, even if owners had a row with id NULL
```

> 💡 **Tip:** Before an `INNER JOIN` on an "every X" request, check the key column with `\d`: `NOT NULL` + `REFERENCES` means no row can be lost. If either is missing, you need a `LEFT JOIN`. See [Foreign keys skip `NULL`](#foreign-keys-skip-null).

> 📝 **Note:** Hit in 05-01 and 05-02.

---

### `LEFT` vs `RIGHT`: the table order matters

`LEFT JOIN` keeps the table in `FROM`; `RIGHT JOIN` keeps the table after `JOIN`. Swapping only the table order changes the result:

| Query | Keeps all | Loses |
|---|---|---|
| `pets LEFT JOIN owners` | pets (Rex too) | owners without pets (Carla) |
| `owners LEFT JOIN pets` | owners (Carla too) | pets without owner (Rex) |
| `owners RIGHT JOIN pets` | pets (Rex too) | same as `pets LEFT JOIN owners` |

> 💡 **Tip:** Prefer `LEFT JOIN` only: put the table that must stay whole in `FROM`. `RIGHT JOIN` reads backwards and gets confusing with several joins.

> 📝 **Note:** Hit in 05-04 (swapped the tables without `RIGHT`: 69 rows instead of 73).

---

### Finding rows with no match

`LEFT JOIN` + `WHERE right.col IS NULL` keeps left rows that matched nothing (owners without pets).

```sql
SELECT o.id, o.name
FROM owners o
LEFT JOIN pets p ON p.owner_id = o.id
WHERE p.id IS NULL;   -- Carla
```

Test a right-side column that is `NULL` **only** when there is no match:

- a column used in `ON`: a real row with `NULL` there never passes `ON`, so a `NULL` in the result must be padding;
- or the right table's primary key.

> ⚠️ **Warning:** Testing any other column (`p.name IS NULL`) mixes "no match" with "matched, but that value is `NULL`".

> ⚠️ **Warning:** `= NULL` never works, use `IS NULL`.

> 📝 **Note:** Hit in 05-05 (`RIGHT JOIN` kept orders, so `order_id IS NULL` gave 0 rows) and 05-06.

---

### "Never": four ways to write it

"Owners who have **never** had a pet" can be written four ways:

```sql
-- 1. EXCEPT
SELECT o.id, o.name FROM owners o
EXCEPT
SELECT o.id, o.name FROM owners o JOIN pets p ON p.owner_id = o.id;

-- 2. LEFT JOIN + IS NULL (anti-join)
SELECT o.id, o.name FROM owners o
LEFT JOIN pets p ON p.owner_id = o.id
WHERE p.id IS NULL;

-- 3. NOT EXISTS
SELECT o.id, o.name FROM owners o
WHERE NOT EXISTS (SELECT 1 FROM pets p WHERE p.owner_id = o.id);

-- 4. NOT IN
SELECT o.id, o.name FROM owners o
WHERE o.id NOT IN (SELECT p.owner_id FROM pets p);
```

| | Compares | Duplicates | Trap |
|---|---|---|---|
| `EXCEPT` | the **whole row** | removed | an extra or differently written column (e.g. `email` in another case) breaks the match |
| `LEFT JOIN … IS NULL` | the key | can appear (other joins in the query) | test a column that is `NULL` only on no match, see [Finding rows with no match](#finding-rows-with-no-match) |
| `NOT EXISTS` | the key | never | none for this case |
| `NOT IN` | the key | never | **one `NULL`** in the subquery → **empty** result (Rex's `owner_id` is `NULL`, so `12 NOT IN (10, 10, 11, NULL)` is unknown and even Carla disappears) |

**Readability:** `EXISTS` / `NOT EXISTS` reads closest to the request: "members for whom **there is** a visit in December and **there is no** complaint". Each related table is just a condition on the row, so it never multiplies rows and needs no `DISTINCT`.

```sql
SELECT m.member_id, m.email
FROM members m
WHERE EXISTS (SELECT 1 FROM visits v
              WHERE v.member_id = m.member_id
                AND v.visited_at >= '2024-12-01 UTC' AND v.visited_at < '2025-01-01 UTC')
  AND NOT EXISTS (SELECT 1 FROM complaints c WHERE c.member_id = m.member_id);
```

> 💡 **Tip:** Only filtering by another table → `EXISTS` / `NOT EXISTS`. Need to **show** its columns (a date, a total) → `JOIN`.

> 📝 **Note:** Postgres usually runs `NOT EXISTS` and `LEFT JOIN … IS NULL` with the same plan (anti-join), so choose by readability.

> 📝 **Note:** Hit in 05-21 (December buyers without reviews: solved with `EXCEPT`, then rewrote with `LEFT JOIN … IS NULL` and `NOT EXISTS`).

---

### A link table is often enough

In N:N (orders ↔ products) the link table (`order_items`) already holds both keys plus the relationship's own data (`quantity`). Join a side table only when you need its columns.

> 📝 **Note:** Hit in 05-03 (order 100's lines: `order_items` + `products`, no `orders`).

---

### Joins change the grain

A join returns one row per **matching pair**. `owners JOIN pets` gives one row per pet, not per owner. Joining the same owner to **two** one-to-many tables (pets and vet visits) gives pets × visits rows for that owner.

> 💡 **Tip:** Before trusting a count or sum, ask what one row now stands for. Count before and after the join.

---

### When `CROSS JOIN` is useful

`CROSS JOIN` gives **every combination** (N × M rows) and has no `ON`. To filter one side, use `WHERE`. It is useful when the combinations are the point:

| Use | Example |
|---|---|
| A complete grid for a report | every shop × every month, then `LEFT JOIN` the sales so a month with no sales shows `0` instead of vanishing |
| Generating data or scenarios | sizes × colours = every product variant; teams × teams = every fixture |
| Adding one single value to every row | a one-row subquery with the grand total, to compute each row's share |
| Combining with a generated series | `generate_series` of dates × shops = one row per shop per day |

```sql
-- every shop with every month, sales or not
SELECT s.name, m.month, coalesce(sum(v.total), 0) AS total
FROM shops s
CROSS JOIN (SELECT generate_series(1, 12) AS month) m
LEFT JOIN sales v ON v.shop_id = s.id AND v.month = m.month
GROUP BY s.name, m.month;

-- each sale's share of the grand total
SELECT v.id, v.total * 100.0 / t.grand AS pct
FROM sales v
CROSS JOIN (SELECT sum(total) AS grand FROM sales) t;
```

> ⚠️ **Warning:** Rows grow as N × M: 1 000 × 1 000 is already a million. A `JOIN` with a forgotten condition does the same by accident, so write `CROSS JOIN` explicitly when you mean it.

> 📝 **Note:** Hit in 05-12 (every supplier × top-level categories: the filter goes in `WHERE`).

---

### Stacking results: `UNION`, `INTERSECT`, `EXCEPT`

A join puts tables **side by side** (more columns). A set operation puts two `SELECT`s **one under the other** (more rows).

Toy lists: `club_a` has `Ana, Rui, Rui`; `club_b` has `Rui, Eva`.

| Operation | Returns | Toy example |
|---|---|---|
| `UNION` | rows from either side, **duplicates removed** | `Ana, Rui, Eva` |
| `UNION ALL` | rows from either side, **all kept** | `Ana, Rui, Rui, Rui, Eva` |
| `INTERSECT` | rows that appear on **both** sides | `Rui` |
| `INTERSECT ALL` | same, keeping repeats (as many as the side with fewer) | `Rui` |
| `EXCEPT` | rows from the first side **not** in the second | `Ana` |
| `EXCEPT ALL` | same, removing one copy per match | `Ana, Rui` |

```sql
SELECT name FROM club_a
UNION
SELECT name FROM club_b;
```

- Both `SELECT`s need the **same number of columns** with compatible types, paired by **position**, not by name.
- Column names come from the **first** `SELECT`; aliases in the others are ignored.
- `ORDER BY` / `LIMIT` go **once**, at the end, and apply to the whole result.
- When removing duplicates, two `NULL`s count as **equal** (unlike `=`): at most one `NULL` row survives.

> 💡 **Tip:** Prefer `UNION ALL` when duplicates can't happen or should stay: `UNION` has to compare every row to remove them.

> ⚠️ **Warning:** `EXCEPT` is not symmetric: `a EXCEPT b` ≠ `b EXCEPT a`.

> 📝 **Note:** Standard SQL. Oracle calls `EXCEPT` `MINUS`. Hit in 05-13 (customer + supplier emails, distinct: `UNION`).

---

### Join traps

- A condition on the right table in `WHERE` after a `LEFT JOIN` removes the `NULL` rows: it silently becomes an inner join. Put it in `ON`.
- Joining through a table with several rows per key **multiplies** rows.
- Forgetting the join condition gives a cartesian product (every row × every row). The checker stops queries that run longer than 5 seconds.

---

## Changing data

### Always list the columns in `INSERT`

Write `INSERT INTO t (a, b) VALUES ...`, not `INSERT INTO t VALUES ...`.

> ⚠️ **Warning:** Without the column list, values are matched by the **column order** of the table, and the insert breaks (or silently fills the wrong columns) if the table changes.

---

### Inserting several rows

One `INSERT` can add several rows: each row goes **inside parentheses**, and rows are **separated by commas**.

```sql
INSERT INTO players (name, team_id) VALUES
('Ana', 1),
('Rui', 1);
```

---

### `INSERT ... SELECT` from a `VALUES` list

An `INSERT` doesn't need `VALUES`: it can take its rows from a **`SELECT`**. A `VALUES` list can act as a temporary table, so a repeated subquery is written **only once**.

```sql
INSERT INTO players (name, team_id)
SELECT v.name, (SELECT team_id FROM teams WHERE name = 'Lions')
FROM (VALUES ('Ana'), ('Rui')) AS v(name);
```

> 💡 **Tip:** `AS v(name)` names the temporary table (`v`) and its column (`name`).

---

### `RETURNING`

When we want the insert to return data from the newly inserted rows, we can use `RETURNING` with the **column names**.

```sql
RETURNING id, city
```

> 💡 **Tip:** `RETURNING` also works with `UPDATE` and `DELETE`, returning the changed or deleted rows.

> 📝 **Note:** `RETURNING` is not standard SQL; it exists in **Postgres** (and a few others), but not everywhere.

---

### `ON CONFLICT` (upsert)

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

### `UPDATE` without `WHERE`

An `UPDATE` (or `DELETE`) without `WHERE` changes **every row** in the table.

```sql
UPDATE players SET active = false;                  -- every player!
UPDATE players SET active = false WHERE id = 42;    -- only one
```

> ⚠️ **Warning:** Always write the `WHERE` first. Run it as a `SELECT` with the same `WHERE` to check which rows will change.

---

## Defining tables

### Column vs table constraints

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

### `GENERATED ALWAYS` vs `BY DEFAULT` (identity)

Both make Postgres generate the id from a sequence. The difference is what happens when an `INSERT` sends its own value:

- `GENERATED ALWAYS AS IDENTITY`: the id is **always** generated. An explicit value sent by the user is an error.
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

### `DEFAULT` does not mean `NOT NULL`

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

### `PRIMARY KEY` vs `UNIQUE`

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

### `UNIQUE` on an expression needs an index

A `UNIQUE` **constraint** only takes **column names**. To make an **expression** unique (e.g. an email ignoring case), create a **unique index** instead.

```sql
ALTER TABLE players ADD CONSTRAINT players_nickname_key UNIQUE (lower(nickname));
-- ERROR: syntax error at or near "("   (the "(" after lower)

CREATE UNIQUE INDEX players_nickname_lower_key ON players (lower(nickname));
INSERT INTO players (nickname) VALUES ('Ana');
INSERT INTO players (nickname) VALUES ('ANA');
-- ERROR: duplicate key value violates unique constraint "players_nickname_lower_key"
-- DETAIL: Key (lower(nickname))=(ana) already exists.
```

| | `UNIQUE` constraint | Unique index |
|---|---|---|
| How | `ALTER TABLE ... ADD CONSTRAINT ... UNIQUE (cols)` | `CREATE UNIQUE INDEX name ON table (...)` (its own statement) |
| Columns | yes | yes |
| Expressions (`lower(x)`) | **no** | **yes** |
| Rule enforced on | `INSERT` and `UPDATE` | `INSERT` and `UPDATE` |
| Listed as a constraint (`pg_constraint`) | yes | **no**, only in `\d table` under *Indexes* |
| Remove | `ALTER TABLE ... DROP CONSTRAINT name` | `DROP INDEX name` |
| Rename | `ALTER TABLE ... RENAME CONSTRAINT a TO b` | `ALTER INDEX a RENAME TO b` |

> ⚠️ **Warning:** The index only speeds up queries that use the **same expression**: `WHERE lower(nickname) = lower('Ana')` uses it; `WHERE nickname = 'Ana'` does not.

> ⚠️ **Warning:** `ALTER TABLE ... ADD CONSTRAINT ... UNIQUE USING INDEX` does not work here: `index contains expressions`. An expression index cannot become a constraint.

> 💡 **Tip:** Give the index a name (`CREATE UNIQUE INDEX name ON ...`), same reason as for [constraints](#column-vs-table-constraints): it shows up in errors and you need it to drop or rename it. Prefer `ALTER INDEX ... RENAME` over drop + create: with drop + create the rule is off in between.

> 💡 **Tip:** `ON CONFLICT` works with it, but the target must repeat the expression in **double** parentheses: `ON CONFLICT ((lower(nickname))) DO NOTHING`.

> 📝 **Note:** Hit in 04-13 (supplier emails, any capitalisation).

---

### Foreign keys skip `NULL`

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

> 📝 **Note:** In the project: `products.supplier_id` is `REFERENCES` only (4 products have no supplier); `order_items.product_id` is `NOT NULL` + `REFERENCES` (every line points to a real product). Check with `\d table` (column *Nullable*). Hit in 05-04 and 05-06.

> 📝 **Note:** Same pattern as [`NULL` in `CHECK`](#null-in-check-is-the-opposite) and [`PRIMARY KEY` vs `UNIQUE`](#primary-key-vs-unique): only `NOT NULL` treats `NULL` as a violation. `CHECK (col IS NOT NULL)` also works, but prefer `NOT NULL` on the column (clearer error, visible in the table definition).

---

### `REFERENCES` without a column

`REFERENCES other_table` with no column points to the other table's **primary key**. The column **name** plays no part.

```sql
CREATE TABLE teams (code text PRIMARY KEY, team_id int);
CREATE TABLE players (team_id text REFERENCES teams);
-- points to teams.code (the PK), not to teams.team_id
```

| Case | Result |
|---|---|
| Other table has a single-column PK | points to it |
| Other table has **no** PK | error: `there is no primary key for referenced table "teams"` |
| Other table has a **composite** PK | needs a table-level `FOREIGN KEY (a, b) REFERENCES teams` with the same number of columns |
| Want another column | name it: `REFERENCES teams(team_id)`; it must be `PRIMARY KEY` or `UNIQUE` |

#### Composite primary key

When the other table's PK has several columns, the FK needs the **same number of columns** and must be a **table** constraint (a column constraint covers one column only).

```sql
CREATE TABLE seasons (
  league text,
  year   int,
  PRIMARY KEY (league, year)
);

CREATE TABLE matches (
  match_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  league   text NOT NULL,
  year     int  NOT NULL,
  FOREIGN KEY (league, year) REFERENCES seasons (league, year)
);

-- league text REFERENCES seasons
-- ERROR: number of referencing and referenced columns for foreign key disagree
```

> ⚠️ **Warning:** The columns pair up by **position**, not by name: `FOREIGN KEY (year, league) REFERENCES seasons (league, year)` pairs `year` with `league` (here it fails because the types differ; with equal types it would be silently wrong).

> ⚠️ **Warning:** If the names match (`supplier_id` → `suppliers.supplier_id`), it works because that column **is** the PK, not because the names match.

> 📝 **Note:** Hit in 04-12 (`supplier_contacts`).
