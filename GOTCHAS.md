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
  - [Logical order of a query](#logical-order-of-a-query)
  - [Where a column alias can be used](#where-a-column-alias-can-be-used)
  - [`BETWEEN`](#between)
  - [`IN`](#in)
  - [Subqueries need parentheses](#subqueries-need-parentheses)
  - [Filtering by a related table: `EXISTS` vs `JOIN` + `DISTINCT`](#filtering-by-a-related-table-exists-vs-join--distinct)
  - [`IN` vs `EXISTS`: where the link goes](#in-vs-exists-where-the-link-goes)
  - [A table that points to itself: children vs siblings](#a-table-that-points-to-itself-children-vs-siblings)
  - [Correlated subquery in `SELECT` and `WHERE`](#correlated-subquery-in-select-and-where)
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
- [Aggregates](#aggregates)
  - [Order inside `STRING_AGG`](#order-inside-string_agg)
- [Scalar functions](#scalar-functions)
  - [Text functions](#text-functions)
  - [Number functions](#number-functions)
  - [Casting: `CAST` and `::`](#casting-cast-and-)
  - [Date and time functions](#date-and-time-functions)
  - [Conditional expressions](#conditional-expressions)
  - [`jsonb`](#jsonb)
  - [Your own helper functions: `CREATE FUNCTION`](#your-own-helper-functions-create-function)
  - [Casting text that may not be a number](#casting-text-that-may-not-be-a-number)
- [Window functions](#window-functions)
  - [`OVER`: a value per row, without merging rows](#over-a-value-per-row-without-merging-rows)
  - [`ROW_NUMBER`, `RANK` and `DENSE_RANK`](#row_number-rank-and-dense_rank)
  - [Filtering on a window function: top row per group](#filtering-on-a-window-function-top-row-per-group)
  - [`LAG` and `LEAD`](#lag-and-lead)
  - [Running totals and the default frame](#running-totals-and-the-default-frame)
  - [A window over an aggregate](#a-window-over-an-aggregate)
  - [Moving average and months with no sales](#moving-average-and-months-with-no-sales)

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

### Logical order of a query

The order you **write** the clauses in is not the order they are **processed** in.

| Step | Clause | What it does | Can see |
|---|---|---|---|
| 1 | `FROM` / `JOIN` | builds the rows from the tables | table columns |
| 2 | `WHERE` | keeps rows (before grouping) | table columns; **no** aggregates |
| 3 | `GROUP BY` | turns rows into groups | table columns |
| 4 | `HAVING` | keeps groups | aggregates (`COUNT(*)`, `SUM(...)`) |
| 5 | `SELECT` | computes the output columns, **creates the aliases** | everything above |
| 6 | `DISTINCT` | removes duplicate output rows | output columns |
| 7 | `ORDER BY` | sorts the output | output columns **and aliases** |
| 8 | `LIMIT` / `OFFSET` | keeps the first rows | |

Written order, which SQL requires: `SELECT → FROM → JOIN → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT`.

```sql
-- made-up table sales(item, qty)
SELECT item, SUM(qty) AS total     -- 5: alias "total" is born here
FROM sales                          -- 1
WHERE qty > 0                       -- 2: per row
GROUP BY item                       -- 3
HAVING SUM(qty) >= 200              -- 4: per group, "total" does not exist yet
ORDER BY total DESC                 -- 7: "total" exists now
LIMIT 10;                           -- 8
```

> ⚠️ **Warning:** An aggregate in the `WHERE` fails (`aggregate functions are not allowed in WHERE`): the groups do not exist yet at step 2. A condition on a total goes in the `HAVING`.

> ⚠️ **Warning:** Clauses written out of order are a syntax error: `HAVING` before `GROUP BY` gives `syntax error at or near "GROUP"`.

> 📝 **Note:** This is the **logical** order: the result is always as if it followed it. The planner may physically do things in another order to go faster.

> 📝 **Note:** Hit in 06-06 (alias in `HAVING`), 06-10 (aggregate in `WHERE`) and 06-14 (`HAVING` before `GROUP BY`).

### Where a column alias can be used

A `SELECT` alias (`... AS name`) exists from step 5 on, so in principle only the `ORDER BY` can see it. PostgreSQL also accepts it in the `GROUP BY`, as an extension.

| Clause | Alias works? | Why |
|---|---|---|
| `WHERE` | ❌ `column "x" does not exist` | runs before the `SELECT` |
| `GROUP BY` | ✅ (PostgreSQL extension) | substituted **when the query is read** |
| `HAVING` | ❌ `column "x" does not exist` | runs before the `SELECT`, no substitution |
| `ORDER BY` | ✅ (standard) | runs after the `SELECT` |

How the `GROUP BY` one works: it does **not** mean `GROUP BY` runs after `SELECT`. When PostgreSQL reads the query, for each name in the `GROUP BY` it:
1. looks for a **table column** with that name;
2. if there is none, looks for a **`SELECT` alias**, and copies the alias's expression into the `GROUP BY`.

So `GROUP BY city_clean` becomes `GROUP BY LOWER(city)` before anything runs; grouping still happens at step 3.

```sql
SELECT LOWER(city) AS city_clean, COUNT(*) AS n
FROM (VALUES ('Porto'), ('PORTO'), ('Braga')) AS people(city)
GROUP BY city_clean               -- read as GROUP BY LOWER(city)
ORDER BY city_clean;
--  city_clean | n
--  braga      | 1
--  porto      | 2
```

> ⚠️ **Warning:** In the `GROUP BY`, a **table column with the same name wins** over the alias, silently:
>
> ```sql
> SELECT LOWER(city) AS city, COUNT(*) AS n
> FROM (VALUES ('Porto'), ('PORTO'), ('Braga')) AS people(city)
> GROUP BY city;           -- groups by the ORIGINAL city: 'Porto' and 'PORTO' stay apart
> --  braga | 1  ·  porto | 1  ·  porto | 1
> ```
>
> In the `ORDER BY` it is the opposite: the **alias wins** over the table column.

> ⚠️ **Warning:** In the `ORDER BY`, the alias works only **on its own**: `ORDER BY total` works, `ORDER BY total + 1` gives `column "total" does not exist`.

Ways to avoid repeating a long expression:

| Way | Example | Catch |
|---|---|---|
| Alias in `GROUP BY` | `GROUP BY city_clean` | a table column with the same name wins |
| Position | `GROUP BY 1` (first `SELECT` column) | reordering the `SELECT` silently changes it |
| Subquery / CTE | `SELECT city_clean, COUNT(*) FROM (SELECT LOWER(city) AS city_clean FROM people) AS p GROUP BY city_clean` | more text, but works everywhere, including `WHERE` and `HAVING` (module 08) |

> 📝 **Note:** Hit in 07-11 (repeating the `NULLIF(SPLIT_PART(...))` expression).

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

### `IN` vs `EXISTS`: where the link goes

Both filter by a related table without duplicates, but the subquery works differently.

Made-up tables: `authors(author_id, name)` and `books(book_id, author_id, genre)`. Goal: authors with at least one horror book.

**`IN`: the subquery stands alone.** It runs **once** and returns a list. The outer query then asks, for each author, "is my id in this list?". Repeated ids in the list don't matter.

```sql
SELECT b.author_id FROM books b WHERE b.genre = 'horror';
-- 3, 7, 7, 12

SELECT a.author_id, a.name
FROM authors a
WHERE a.author_id IN (SELECT b.author_id FROM books b WHERE b.genre = 'horror');
-- same as: WHERE a.author_id IN (3, 7, 7, 12)
```

**`EXISTS`: the subquery needs the outer row.** It asks "is there a horror book by **this** author?", so it needs the link `b.author_id = a.author_id` to know who "this author" is. It is a **correlated** subquery: conceptually it runs once per author.

```sql
SELECT a.author_id, a.name
FROM authors a
WHERE EXISTS (
  SELECT 1 FROM books b
  WHERE b.author_id = a.author_id   -- the link
    AND b.genre = 'horror'
);
```

| | The comparison with the outer row is made by | Can the subquery run alone? |
|---|---|---|
| `IN` | the `IN` itself (`a.author_id IN ...`) | yes |
| `EXISTS` | the link inside the subquery | no: `a.author_id` doesn't exist there |

> ⚠️ **Warning:** Don't copy the `EXISTS` link into an `IN` subquery (`... IN (SELECT b.author_id FROM books b WHERE b.author_id = a.author_id AND ...)`). The result is still right, but the link is redundant: the `IN` already compares the ids. And it turns a standalone list into a correlated subquery that can no longer be run alone to check it.

> 💡 **Tip:** To check an `IN` subquery, copy it and run it on its own: you should see the list it produces.

> 📝 **Note:** For `NOT IN` vs `NOT EXISTS`, see ["Never": four ways to write it](#never-four-ways-to-write-it): a single `NULL` in the list empties `NOT IN`.

> 📝 **Note:** Hit in sql-lab 08-02.

### A table that points to itself: children vs siblings

In a tree stored in one table, each row has a `parent_id` that points to **another row of the same table**. Top-level rows have `parent_id = NULL`.

Made-up table `folders(folder_id, name, parent_id)`:

```
 folder_id | name   | parent_id
         1 | Home   | (null)
         2 | Photos | 1
         3 | Music  | 1
         4 | 2024   | 2
```

Goal: folders with **no subfolders** (leaves: 3 and 4).

**1. Two copies of the same table need two aliases.** Name them after their role, so each side of the `=` says which row it is:

```sql
SELECT f.folder_id, f.name
FROM folders f                        -- the folder we are checking
WHERE NOT EXISTS (
  SELECT 1 FROM folders child         -- a possible child of f
  WHERE child.parent_id = f.folder_id
);
```

**2. Read the link aloud before running it.** The two links look alike, but they ask different questions (`child` and `sibling` are the alias of the inner copy, `f` is the outer row):

| Link | Reads as | Finds |
|---|---|---|
| `child.parent_id = f.folder_id` | "is there a row whose parent **is me**?" | children ✅ |
| `sibling.parent_id = f.parent_id` | "is there a row with **the same parent as me**?" | siblings ❌ (and `f` itself) |

With the sibling link, `NOT EXISTS` is false for almost every row: each row is its own sibling. Only top-level rows pass, because `NULL = NULL` is unknown, so nothing matches them. A result that is exactly "the top-level rows" is a sign the link is wrong.

**3. `NOT IN` on `parent_id` returns nothing.** The list `SELECT parent_id FROM folders` contains `NULL` (from `Home`), and one `NULL` makes every `NOT IN` unknown (see ["Never": four ways to write it](#never-four-ways-to-write-it)):

```sql
WHERE f.folder_id NOT IN (SELECT parent_id FROM folders);                            -- 0 rows
WHERE f.folder_id NOT IN (SELECT parent_id FROM folders WHERE parent_id IS NOT NULL); -- works
```

`NOT EXISTS` does not need the `IS NOT NULL`: a `NULL` `parent_id` never equals anything, so it just doesn't match.

> 💡 **Tip:** Several "has no ..." conditions are several `NOT EXISTS` joined with `AND`, one per related table.

> 📝 **Note:** Hit in sql-lab 08-03.

### Correlated subquery in `SELECT` and `WHERE`

A **correlated** subquery uses a column of the outer row, so it gives a different answer per row. It can return a single value (a scalar), which can be shown as a column or compared in the `WHERE`.

Made-up table `staff(staff_id, name, team, salary)`: team red has salaries 100, 101, 101 (average 100.67); team blue has 200, 300 (average 250).

Goal: staff paid above their own team's average, showing that average.

```sql
SELECT s.staff_id, s.name, s.salary,
       (SELECT ROUND(AVG(t.salary), 2) FROM staff t WHERE t.team = s.team) AS team_avg
FROM staff s
WHERE s.salary > (SELECT AVG(t.salary) FROM staff t WHERE t.team = s.team);
--  staff_id | name  | salary | team_avg
--         2 | Bruno |    101 |   100.67
--         3 | Carla |    101 |   100.67
--         5 | Eva   |    300 |   250.00
```

**1. The link `t.team = s.team` is what makes it "per team".** Without it, the subquery is the average of **everyone**, the same value on every row.

**2. The `WHERE` cannot use the alias `team_avg`.** The `WHERE` runs before the `SELECT`, so the alias doesn't exist yet (see [Where a column alias can be used](#where-a-column-alias-can-be-used)):

```sql
WHERE s.salary > team_avg;   -- ERROR: column "team_avg" does not exist
```

So the subquery is written twice: once to **show** the value, once to **filter** by it.

**3. Round for display, compare with the exact value.** Rounding only changes what we see, but if the comparison uses the rounded value the result can change. With `ROUND(AVG(t.salary), 0)` in the `WHERE`, red's average becomes `101`, and Bruno and Carla (`101 > 101` is false) disappear.

> 💡 **Tip:** A correlated subquery can't be run alone (`s.team` doesn't exist there). To check it, replace `s.team` with a fixed value (`WHERE t.team = 'red'`) and run that.

> 📝 **Note:** Hit in sql-lab 08-04.

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

---

## Aggregates

### Order inside `STRING_AGG`

`STRING_AGG` joins values in whatever order the rows arrive, and that order is **not guaranteed**. To control it, put an `ORDER BY` **inside** the parentheses, after the separator, with **no comma**.

```sql
-- songs(album, title)
SELECT album,
       STRING_AGG(title, ' | ' ORDER BY title) AS tracklist
FROM songs
GROUP BY album;
```

| Where | What it sorts |
|---|---|
| `STRING_AGG(title, ', ' ORDER BY title)` | the values **inside** each text |
| `... GROUP BY album ORDER BY album` | the **result rows** (one per album) |

> ⚠️ **Warning:** An `ORDER BY` at the end of the query does not sort the names inside the text; it only sorts the rows.

> ⚠️ **Warning:** The argument is a column or expression of the group's rows, not a query: `STRING_AGG(SELECT title FROM songs, ', ')` is a syntax error. And the separator is a value, so it takes **single** quotes (`', '`); `", "` would be read as a column name.

> 📝 **Note:** The same `ORDER BY` inside the parentheses works for other order-sensitive aggregates, such as `ARRAY_AGG`.

> 📝 **Note:** Hit in 06-09 (employees per department).

---

## Scalar functions

A scalar function works on **one value per row** and returns one value per row, so the row count does not change. An aggregate (`COUNT`, `SUM`, ...) does the opposite: it turns many rows into one per group.

All examples run as they are in `pnpm sql`. `FROM (VALUES (...), (...)) AS t(col)` builds a small made-up table inline: each `(...)` is a row, and `t(col)` names the table and its columns.

### Text functions

#### `LOWER(t)` / `UPPER(t)`

Changes the text to lower or upper case.

```sql
SELECT email, LOWER(email) AS lower_email, UPPER(email) AS upper_email
FROM (VALUES ('Ana@Mail.COM'), ('rui@web.pt')) AS people(email);
--  email        | lower_email  | upper_email
--  Ana@Mail.COM | ana@mail.com | ANA@MAIL.COM
--  rui@web.pt   | rui@web.pt   | RUI@WEB.PT
```

#### `TRIM(t)` / `LTRIM(t)` / `RTRIM(t)`

Removes spaces at both ends (`TRIM`), only at the start (`LTRIM`) or only at the end (`RTRIM`). Spaces in the middle stay.

```sql
-- the brackets only show where the spaces are
SELECT '[' || name || ']'        AS raw,
       '[' || TRIM(name) || ']'  AS trimmed,
       '[' || LTRIM(name) || ']' AS ltrimmed,
       '[' || RTRIM(name) || ']' AS rtrimmed
FROM (VALUES ('  Ana  ')) AS people(name);
--  raw       | trimmed | ltrimmed | rtrimmed
--  [  Ana  ] | [Ana]   | [Ana  ]  | [  Ana]
```

> 💡 **Tip:** Clean before comparing: `TRIM(LOWER(email))`. Apply the **same** expression on both sides, or in both the `SELECT` and the `WHERE`.

#### `TRIM(BOTH c FROM t)`

Removes another character, instead of spaces, at both ends (`LEADING` for the start only, `TRAILING` for the end only).

```sql
SELECT code, TRIM(BOTH '-' FROM code) AS cleaned
FROM (VALUES ('--A12--'), ('B7-')) AS t(code);
--  code    | cleaned
--  --A12-- | A12
--  B7-     | B7
```

#### `SPLIT_PART(t, sep, n)`

Cuts `t` at every `sep` and returns the `n`-th piece (counting from 1). With a negative `n`, counts from the end (PostgreSQL 14+).

```sql
SELECT email,
       SPLIT_PART(email, '@', 1) AS username,
       SPLIT_PART(email, '@', 2) AS domain
FROM (VALUES ('ana@mail.com'), ('no-at-sign')) AS people(email);
--  email        | username   | domain
--  ana@mail.com | ana        | mail.com
--  no-at-sign   | no-at-sign |              <- '' (empty), not NULL
```

```sql
SELECT path, SPLIT_PART(path, '/', -1) AS file_name
FROM (VALUES ('docs/2024/report.pdf'), ('notes.txt')) AS t(path);
--  path                 | file_name
--  docs/2024/report.pdf | report.pdf
--  notes.txt            | notes.txt
```

> ⚠️ **Warning:** `SPLIT_PART` returns `''`, not `NULL`, when the piece does not exist. `IS NULL` will not find it; use `NULLIF(..., '')` to turn it into `NULL`.

#### `CONCAT_WS(sep, a, b, ...)`

Joins the values with a separator ("with separator"), **skipping `NULL`s**, so there are no stray separators. If every value is `NULL`, returns `''` (never `NULL`).

```sql
SELECT city, phone, CONCAT_WS(' / ', city, phone) AS contact
FROM (VALUES ('Porto', '912000000'), ('Braga', NULL), (NULL, '934000000'), (NULL, NULL)) AS people(city, phone);
--  city   | phone     | contact
--  Porto  | 912000000 | Porto / 912000000
--  Braga  | (null)    | Braga
--  (null) | 934000000 | 934000000
--  (null) | (null)    |                    <- ''
```

#### `CONCAT(a, b, ...)`

Joins the values, treating `NULL` as `''`. Any separators you typed stay, even next to a missing value.

```sql
SELECT first_name, middle_name, last_name,
       CONCAT(first_name, ' ', middle_name, ' ', last_name) AS full_name
FROM (VALUES ('Ana', 'Sofia', 'Lima'), ('Rui', NULL, 'Costa')) AS people(first_name, middle_name, last_name);
--  first_name | middle_name | last_name | full_name
--  Ana        | Sofia       | Lima      | Ana Sofia Lima
--  Rui        | (null)      | Costa     | Rui  Costa       <- two spaces
```

#### `a || b`

The concatenation operator. **One `NULL` makes the whole result `NULL`.**

```sql
SELECT city, phone, city || ' / ' || phone AS contact
FROM (VALUES ('Porto', '912000000'), ('Braga', NULL)) AS people(city, phone);
--  city  | phone     | contact
--  Porto | 912000000 | Porto / 912000000
--  Braga | (null)    | (null)
```

### Number functions

See also [`ROUND`, `CEIL` and `FLOOR`](#round-ceil-and-floor) for halves and negatives.

#### `ROUND(x)` / `ROUND(x, n)`

Rounds to the nearest whole number, or to `n` decimals (`numeric` only). Halves round away from zero.

```sql
SELECT price,
       ROUND(price)    AS whole,
       ROUND(price, 1) AS one_decimal,
       ROUND(price, 2) AS two_decimals
FROM (VALUES (12.345), (7.5), (-2.5)) AS t(price);
--  price  | whole | one_decimal | two_decimals
--  12.345 |    12 |        12.3 |        12.35
--     7.5 |     8 |         7.5 |         7.50
--    -2.5 |    -3 |        -2.5 |        -2.50
```

#### `CEIL(x)` / `FLOOR(x)`

`CEIL` always rounds **up** to a whole number, `FLOOR` always **down**.

```sql
-- boxes of 2.5 kg
SELECT kg,
       CEIL(kg / 2.5)  AS boxes,       -- a partial box is still a box
       FLOOR(kg / 2.5) AS full_boxes   -- only boxes that are completely full
FROM (VALUES (2.5), (6.0), (0.3)) AS t(kg);
--  kg  | boxes | full_boxes
--  2.5 |     1 |          1
--  6.0 |     3 |          2
--  0.3 |     1 |          0
```

#### Integer division `/`

Integer ÷ integer is an integer, and the decimals are **cut off**, not rounded: `7 / 2` is `3`. Make one side non-integer (`100.0`, or a cast) to keep them.

```sql
-- cents to euros
SELECT cents,
       cents / 100             AS wrong_eur,
       ROUND(cents / 100.0, 2) AS eur
FROM (VALUES (12950), (99)) AS t(cents);
--  cents | wrong_eur | eur
--  12950 |       129 | 129.50
--     99 |         0 |   0.99
```

### Casting: `CAST` and `::`

#### `CAST(x AS type)` / `x::type`

Changes a value's type. The two forms are equivalent: `CAST` is standard SQL, `::` is PostgreSQL shorthand.

```sql
SELECT code, CAST(code AS integer) AS as_int, code::integer AS same_thing
FROM (VALUES ('0012'), ('450')) AS t(code);
--  code | as_int | same_thing
--  0012 |     12 |         12
--  450  |    450 |        450
```

> ⚠️ **Warning:** A cast that cannot work fails the **whole query**, see [Casting text that may not be a number](#casting-text-that-may-not-be-a-number).

### Date and time functions

> 📝 **Note:** On `timestamptz` columns, `::date`, `DATE_TRUNC`, `EXTRACT` and `TO_CHAR` depend on the session time zone. `pnpm sql` and the checker use UTC.

#### `ts::date`

Keeps the calendar date and drops the time.

```sql
SELECT ordered_at, ordered_at::date AS order_date
FROM (VALUES (timestamp '2024-03-15 14:30'), (timestamp '2024-03-15 23:59:59')) AS t(ordered_at);
--  ordered_at          | order_date
--  2024-03-15 14:30:00 | 2024-03-15
--  2024-03-15 23:59:59 | 2024-03-15
```

#### `DATE_TRUNC(unit, ts)`

Cuts the timestamp down to the start of the unit (`'year'`, `'month'`, `'day'`, `'hour'`, ...). The result is **still a timestamp**; add `::date` if you need a date.

```sql
SELECT ordered_at,
       DATE_TRUNC('month', ordered_at)       AS month_ts,
       DATE_TRUNC('month', ordered_at)::date AS month_date,
       DATE_TRUNC('hour', ordered_at)        AS hour_ts
FROM (VALUES (timestamp '2024-03-15 14:30')) AS t(ordered_at);
--  ordered_at          | month_ts            | month_date | hour_ts
--  2024-03-15 14:30:00 | 2024-03-01 00:00:00 | 2024-03-01 | 2024-03-15 14:00:00
```

#### `EXTRACT(field FROM ts)`

Returns one field of the date as a number: `YEAR`, `MONTH`, `DAY` (of the month), `HOUR`, `MINUTE`, `DOW` (weekday, **0 = Sunday**), `ISODOW` (weekday, **1 = Monday, 7 = Sunday**).

```sql
-- 2024-03-15 is a Friday, 2024-03-17 a Sunday
SELECT ordered_at,
       EXTRACT(YEAR FROM ordered_at)   AS year,
       EXTRACT(MONTH FROM ordered_at)  AS month,
       EXTRACT(HOUR FROM ordered_at)   AS hour,
       EXTRACT(DOW FROM ordered_at)    AS dow,
       EXTRACT(ISODOW FROM ordered_at) AS isodow
FROM (VALUES (timestamp '2024-03-15 14:30'), (timestamp '2024-03-17 09:05')) AS t(ordered_at);
--  ordered_at          | year | month | hour | dow | isodow
--  2024-03-15 14:30:00 | 2024 |     3 |   14 |   5 |      5
--  2024-03-17 09:05:00 | 2024 |     3 |    9 |   0 |      7
```

#### `DATE_PART('field', ts)`

The same as `EXTRACT`, written as a function with the field as text. `'day'` is the day **of the month**, not the date.

```sql
SELECT ordered_at,
       DATE_PART('day', ordered_at)    AS day_of_month,
       DATE_PART('minute', ordered_at) AS minute
FROM (VALUES (timestamp '2024-03-15 14:30')) AS t(ordered_at);
--  ordered_at          | day_of_month | minute
--  2024-03-15 14:30:00 |           15 |     30
```

#### `TO_CHAR(ts, pattern)`

Formats a date as **text**, following a pattern. The case of the pattern matters.

| Pattern | Result for 2024-03-15 14:30 |
|---|---|
| `'Dy'` | `'Fri'` |
| `'DY'` | `'FRI'` |
| `'Day'` | `'Friday   '` (padded to 9 characters) |
| `'FMDay'` | `'Friday'` (`FM` removes the padding) |
| `'D'` | `'6'` (1 = Sunday; not the same as `DOW`) |
| `'YYYY-MM'` | `'2024-03'` |
| `'HH24'` | `'14'` |

```sql
SELECT ordered_at,
       TO_CHAR(ordered_at, 'Dy')                 AS weekday,
       TO_CHAR(ordered_at, 'FMDay')              AS weekday_full,
       TO_CHAR(ordered_at, 'YYYY-MM')            AS month,
       TO_CHAR(ordered_at, 'DD/MM/YYYY HH24:MI') AS pt_format
FROM (VALUES (timestamp '2024-03-15 14:30')) AS t(ordered_at);
--  ordered_at          | weekday | weekday_full | month   | pt_format
--  2024-03-15 14:30:00 | Fri     | Friday       | 2024-03 | 15/03/2024 14:30
```

> ⚠️ **Warning:** Weekday numbering differs: `EXTRACT(DOW)` is 0–6 from Sunday, `TO_CHAR(..., 'D')` is 1–7 from Sunday, `EXTRACT(ISODOW)` is 1–7 from Monday.

#### `ts - ts`

Subtracting two timestamps gives an **interval in days + time**, with no months. `EXTRACT(DAY FROM ...)` on it gives the number of complete 24-hour periods.

```sql
SELECT ordered_at, shipped_at,
       shipped_at - ordered_at                   AS waited,
       EXTRACT(DAY FROM shipped_at - ordered_at) AS full_days
FROM (VALUES (timestamp '2024-02-01 09:00', timestamp '2024-02-02 08:00'),
             (timestamp '2024-02-01 09:00', timestamp '2024-03-05 10:00')) AS t(ordered_at, shipped_at);
--  ordered_at          | shipped_at          | waited           | full_days
--  2024-02-01 09:00:00 | 2024-02-02 08:00:00 | 23:00:00         |         0
--  2024-02-01 09:00:00 | 2024-03-05 10:00:00 | 33 days 01:00:00 |        33
```

#### `AGE(ts, ts)`

The difference as an **interval in years + months + days**, the way people say ages. Good for "how old", bad for "how many days".

```sql
SELECT born,
       AGE(timestamp '2024-03-15', born)                    AS age,
       EXTRACT(YEAR FROM AGE(timestamp '2024-03-15', born)) AS years
FROM (VALUES (timestamp '1990-07-20'), (timestamp '2000-03-15')) AS t(born);
--  born                | age                     | years
--  1990-07-20 00:00:00 | 33 years 7 mons 26 days |    33
--  2000-03-15 00:00:00 | 24 years                |    24
```

> ⚠️ **Warning:** `EXTRACT(DAY FROM AGE(...))` only reads the **days part** of "1 mon 4 days", so it ignores the month: `EXTRACT(DAY FROM AGE(timestamp '2024-03-05 10:00', timestamp '2024-02-01 09:00'))` is `4`, not `33`. For "how many days", use `ts - ts`.

#### `date - date`

Subtracting two `date`s gives a plain **integer** number of days (not an interval).

```sql
SELECT start_day, end_day, end_day - start_day AS days
FROM (VALUES (date '2024-02-01', date '2024-03-05'), (date '2024-12-31', date '2025-01-01')) AS t(start_day, end_day);
--  start_day  | end_day    | days
--  2024-02-01 | 2024-03-05 |   33
--  2024-12-31 | 2025-01-01 |    1
```

#### `EXTRACT(EPOCH FROM interval)`

The total length of an interval in **seconds**. Divide to convert to hours, days, ...

```sql
SELECT waited,
       EXTRACT(EPOCH FROM waited)               AS seconds,
       FLOOR(EXTRACT(EPOCH FROM waited) / 3600) AS full_hours
FROM (VALUES (interval '1 day 2 hours 30 minutes')) AS t(waited);
--  waited         | seconds      | full_hours
--  1 day 02:30:00 | 95400.000000 |         26
```

> 📝 **Note:** Hit in 07-01 to 07-08.

### Conditional expressions

Not functions strictly speaking, but they also work on one row at a time and return one value per row. PostgreSQL documents them together under "Conditional Expressions".

#### `CASE`

Returns a different value depending on conditions: `CASE WHEN condition THEN value ... ELSE value END`.

`CASE` checks the `WHEN`s **in order** and returns the first one that is true. Any comparison with `NULL` is unknown (never true), so a `NULL` value skips every `WHEN` and lands in the `ELSE`. With no `ELSE`, `CASE` returns `NULL`.

```sql
SELECT price,
       CASE WHEN price < 5000  THEN 'budget'
            WHEN price < 15000 THEN 'mid'
            ELSE 'premium'
       END AS with_else,
       CASE WHEN price < 5000   THEN 'budget'
            WHEN price < 15000  THEN 'mid'
            WHEN price >= 15000 THEN 'premium'
       END AS no_else,
       CASE WHEN price IS NULL  THEN 'unknown'
            WHEN price < 5000   THEN 'budget'
            WHEN price < 15000  THEN 'mid'
            ELSE 'premium'
       END AS null_first
FROM (VALUES (1200), (9900), (15000), (NULL::integer)) AS items(price);
--  price  | with_else | no_else | null_first
--    1200 | budget    | budget  | budget
--    9900 | mid       | mid     | mid
--   15000 | premium   | premium | premium
--  (null) | premium   | (null)  | unknown      <- with_else puts "no price" in premium
```

| Version | `NULL` price gives | Use when |
|---|---|---|
| `ELSE` as the last band | the last band (wrong) | the column is `NOT NULL` |
| every band in a `WHEN`, no `ELSE` | `NULL` | "no value" should stay `NULL` |
| `WHEN x IS NULL` first | a label (`'unknown'`) | a report must show how many have no value |

> ⚠️ **Warning:** `ELSE` means "everything else, **including `NULL`**". Use it only when that is what you want.

> 💡 **Tip:** Because the `WHEN`s are checked in order, `WHEN price < 15000` after `WHEN price < 5000` already means "5000 to 14999". No need for `BETWEEN`.

> 📝 **Note:** Hit in 07-09 (price bands; safe there because `unit_price_cents` is `NOT NULL`).

#### `COALESCE(a, b, ...)`

Returns the **first value that is not `NULL`**, reading left to right. If all are `NULL`, returns `NULL`. Use it to give a `NULL` a fallback value.

```sql
SELECT nickname, first_name,
       COALESCE(nickname, first_name, 'friend') AS greeting_name
FROM (VALUES ('Tó', 'António'), (NULL, 'Rita'), (NULL, NULL)) AS people(nickname, first_name);
--  nickname | first_name | greeting_name
--  Tó       | António    | Tó
--  (null)   | Rita       | Rita
--  (null)   | (null)     | friend
```

```sql
-- arithmetic with NULL gives NULL; COALESCE first
SELECT NULL + 1, COALESCE(NULL, 5) + 1;
--  (null) | 6
```

> ⚠️ **Warning:** All the arguments must have compatible types: `COALESCE(1, 'x')` fails with `invalid input syntax for type integer: "x"`.

> 💡 **Tip:** `COALESCE` and `NULLIF` are opposites: `COALESCE` turns `NULL` into a value, `NULLIF` turns a value into `NULL`.

#### `NULLIF(a, b)`

Returns `NULL` when `a = b`, otherwise `a`. Use it to turn a "fake empty" value (`''`, `0`) into a real `NULL`.

```sql
-- '' from SPLIT_PART becomes NULL
SELECT domain, NULLIF(domain, '') AS domain_or_null
FROM (VALUES ('mail.com'), ('')) AS t(domain);
--  domain   | domain_or_null
--  mail.com | mail.com
--           | (null)
```

```sql
-- avoid "division by zero": dividing by NULL gives NULL instead of an error
SELECT total, orders, total / NULLIF(orders, 0) AS avg_per_order
FROM (VALUES (300, 3), (500, 0)) AS t(total, orders);
--  total | orders | avg_per_order
--    300 |      3 |           100
--    500 |      0 |        (null)
```

### `jsonb`

A `jsonb` column holds a JSON document per row. Two families of operators: some **read a value** out of it, others **test** it (true/false, for the `WHERE`).

The examples use a made-up table `items(id, info)`:

```sql
SELECT ... FROM (VALUES
  (1, '{"size": "L", "tags": ["new", "sale"], "dims": {"w": 30, "h": 20}}'::jsonb),
  (2, '{"size": "M"}'::jsonb),
  (3, '{"tags": ["sale"]}'::jsonb)
) AS items(id, info);
```

#### `->` vs `->>` vs `['key']`

The difference is the **type of the result**: `jsonb` or `text`.

| Form | Returns | `info ... 'size'` on row 1 | Use it to |
|---|---|---|---|
| `info -> 'size'` | `jsonb` | `"L"` (with quotes) | keep going deeper, or test with `?` / `@>` |
| `info['size']` (PostgreSQL 14+) | `jsonb` | `"L"` (with quotes) | same as `->`, just easier to read |
| `info ->> 'size'` | `text` | `L` | show the value, compare with text, cast to a number |

```sql
SELECT id, info -> 'size' AS arrow, info['size'] AS subscript, info ->> 'size' AS as_text,
       pg_typeof(info['size']) AS t1, pg_typeof(info ->> 'size') AS t2
FROM ... ;
--  id | arrow  | subscript | as_text | t1    | t2
--   1 | "L"    | "L"       | L       | jsonb | text
--   3 | (null) | (null)    | (null)  | jsonb | text   <- missing key gives NULL, no error
```

> ⚠️ **Warning:** `info['size']` and `info -> 'size'` are **not text**. The quotes in `"L"` are part of the value, so the checker sees `"\"L\""`. If the task says "as text", use `->>`.

> 📝 **Note:** There is no subscript form of `->>`. If you want text out of `info['size']`, you need `->>` (or `info['size'] #>> '{}'`). `info['size']::text` keeps the quotes: `"L"`.

> 📝 **Note:** `pg_typeof(x)` shows the type of any expression. Handy when you are not sure what an operator returns.

#### Going deeper: nested keys and array positions

```sql
SELECT info['dims']['w']       AS a,   -- jsonb 30
       info -> 'dims' ->> 'w'  AS b,   -- text '30': only the LAST step is ->>
       info #>> '{dims,w}'     AS c,   -- text '30': a whole path in one go
       info['tags'][0]         AS d,   -- jsonb "new": arrays count from 0
       info['tags'][-1]        AS e    -- jsonb "sale": negative counts from the end
FROM ... WHERE id = 1;
```

> ⚠️ **Warning:** JSON arrays count from **0**. PostgreSQL arrays (`ARRAY[...]`) and `SPLIT_PART` count from **1**.

#### Precedence: `::` and `+` bind tighter than `->>`

`::` is applied before `->>`, so in `info ->> 'size'::jsonb` the cast runs on `'size'`, not on the result:

```sql
SELECT info ->> 'size'::jsonb FROM ... ;
-- ERROR: invalid input syntax for type json
-- DETAIL: Token "size" is invalid.          <- 'size' is not valid JSON

SELECT info ->> 'w' + 1 FROM ... ;
-- ERROR: invalid input syntax for type integer: "w"   <- 'w' + 1 ran first
```

Put parentheses around the part that reads the value:

```sql
SELECT (info -> 'dims' ->> 'w')::integer + 1 FROM ... ;   -- 31
```

> 💡 **Tip:** When an error says the **key name** is invalid (`Token "size"`, `"w"`), the operator order is the problem, not the data.

> 📝 **Note:** Hit in 07-14 (`specs->>'colors'::jsonb`).

#### Testing: `?`, `?|`, `?&`, `@>`

| Test | True when | Row 1 | Row 2 | Row 3 |
|---|---|---|---|---|
| `info ? 'tags'` | the **key** exists at the top level | t | f | t |
| `info['tags'] ? 'sale'` | the **array** has the string `"sale"` | t | (null) | t |
| `info ?\| array['size', 'x']` | **any** of these keys exists | t | t | f |
| `info ?& array['size', 'tags']` | **all** of these keys exist | t | f | f |
| `info @> '{"tags": ["sale"]}'` | `info` **contains** this piece of JSON | t | f | t |

`?` means "is this key here" on an object, and "is this string an element" on an array.

> ⚠️ **Warning:** `?` only finds **strings**, and only exact ones: `'["new","sale"]' ? 'sal'` and `? 'SALE'` are false, and `'[3]' ? '3'` is false (`3` is a number). For numbers, use `@>`: `info['n'] @> '3'`.

> ⚠️ **Warning:** With `@>`, the shape must match: `{"tags": "sale"}` is **false** (a string, not an array); `{"tags": ["sale"]}` is true.

#### A missing key gives `NULL`, and `NULL` filters the row out

`info['tags']` on row 2 is `NULL`, so `info['tags'] ? 'sale'` is `NULL`, and `WHERE` keeps only `true`. You do not need `info ? 'tags' AND ...` first to avoid an error: there is no error.

```sql
SELECT id FROM ... WHERE info['tags'] ? 'sale';
--  1
--  3
```

> 📝 **Note:** A key with a JSON `null` value is different from a missing key: `'{"a": null}'::jsonb ? 'a'` is **true**, `-> 'a'` gives the JSON value `null`, and `->> 'a'` gives SQL `NULL`.

#### Comparing a value: text or JSON

```sql
WHERE info ->> 'size' = 'L'      -- text vs text: the simple way
WHERE info['size'] = '"L"'       -- jsonb vs jsonb: the quotes are needed
WHERE (info ->> 'w')::integer > 25   -- numbers come out of ->> as text: cast them
```

> ⚠️ **Warning:** `info ->> 'w' > '25'` compares **text**: `'100' < '25'` because `'1'` comes before `'2'`. Cast before comparing numbers.

#### `json` vs `jsonb`

| | `json` | `jsonb` |
|---|---|---|
| Stores | the text as typed (spaces, key order, duplicate keys) | a parsed binary form |
| `->`, `->>`, `#>>` | yes | yes |
| `['key']` | no: `cannot subscript type json` | yes |
| `?`, `?\|`, `?&`, `@>` | no: `operator does not exist: json ? unknown` | yes |

If a column is `json`, cast it once: `info::jsonb ? 'tags'`. On a `jsonb` column, `::jsonb` changes nothing. Check the type with `\d table_name` in `psql`.

#### One row per array element: `jsonb_array_elements_text`

Not a scalar function: it returns **several rows** per input row, so the row count changes (like a join).

```sql
SELECT id, tag
FROM ..., jsonb_array_elements_text(info['tags']) AS tag;
--  id | tag
--   1 | new
--   1 | sale
--   3 | sale      <- row 2 disappears: no tags, no rows
```

> 📝 **Note:** Hit in 07-13 (`specs['season']` gave `"3-season"` with quotes) and 07-14 (`::` precedence, looking inside an array).

### Your own helper functions: `CREATE FUNCTION`

When the same expression keeps coming back (seconds to days, cents to euros), PostgreSQL lets you give it a name with `CREATE FUNCTION`.

```sql
CREATE OR REPLACE FUNCTION interval_in(i interval, unit text)
RETURNS numeric
LANGUAGE sql IMMUTABLE STRICT
RETURN EXTRACT(EPOCH FROM i) / CASE unit
         WHEN 'minutes' THEN 60
         WHEN 'hours'   THEN 3600
         WHEN 'days'    THEN 86400
       END;

SELECT interval_in(interval '1 day 12 hours', 'days');    -- 1.5000000000000000
SELECT interval_in(interval '1 day 12 hours', 'hours');   -- 36.0000000000000000
SELECT interval_in(interval '90 seconds', 'minutes');     -- 1.5000000000000000
```

```sql
CREATE OR REPLACE FUNCTION cents_to_eur(cents integer)
RETURNS numeric
LANGUAGE sql IMMUTABLE STRICT
RETURN ROUND(cents / 100.0, 2);

SELECT cents_to_eur(12950);   -- 129.50
SELECT cents_to_eur(NULL);    -- NULL (STRICT)
```

| Part | Meaning |
|---|---|
| `CREATE OR REPLACE` | creates it, or replaces an existing one with the same name and argument types |
| `(i interval, unit text)` | the arguments, with names and types |
| `RETURNS numeric` | the type of the result |
| `LANGUAGE sql` + `RETURN ...` | the body is one SQL expression (PostgreSQL 14+) |
| `IMMUTABLE` | same input, always same output (no table reads, no `now()`), so PostgreSQL can optimise it |
| `STRICT` | if any argument is `NULL`, returns `NULL` without running the body |

Managing them in `psql`: `\df` lists your functions, `\df+ name` shows the body, `DROP FUNCTION cents_to_eur(integer);` removes one (the argument types are part of its identity).

> ⚠️ **Warning:** **Don't use them in the exercises.** `pnpm check` runs each query on a fresh copy of the base database (`sqllab_chk_...`), where your function does not exist: `function interval_in(interval, unknown) does not exist`. A function created in `pnpm sql` lives only in `sqllab_play`, and `pnpm sql --reset` deletes it.

> ⚠️ **Warning:** An unknown unit (`'weeks'`) returns `NULL` without any error, because the `CASE` has no `ELSE`. Failing loudly needs `LANGUAGE plpgsql` and `RAISE EXCEPTION`, which sql-lab does not cover.

Built-in helpers that already do part of the job, nothing to create:

| Function | Example | Result |
|---|---|---|
| `make_interval(secs => n)` | `make_interval(secs => 129600)` | `36:00:00` |
| `make_interval(mins => n)` | `make_interval(mins => 90)` | `01:30:00` |
| `justify_hours(interval)` | `justify_hours(interval '50 hours')` | `2 days 02:00:00` |
| `EXTRACT(EPOCH FROM interval) / 86400` | `EXTRACT(EPOCH FROM interval '36 hours') / 86400` | `1.5` |

> 📝 **Note:** Came up after 07-12 (seconds to days).

### Casting text that may not be a number

`CAST(text AS integer)` fails on anything that is not a valid integer, and **one bad row makes the whole query fail**:

```sql
SELECT CAST('' AS integer);
-- ERROR: invalid input syntax for type integer: ""
```

A common source of `''`: `SPLIT_PART` returns an **empty string** (not `NULL`) when the separator or the part is missing: `SPLIT_PART('abc', '-', 2)` is `''`.

Ways around it (made-up table `codes(code)`, values like `'ABC-0012'`):

| Approach | Example | Covers |
|---|---|---|
| `NULLIF` | `CAST(NULLIF(SPLIT_PART(code, '-', 2), '') AS integer)` | only the empty string |
| Check with a regex first | `CASE WHEN SPLIT_PART(code, '-', 2) ~ '^[0-9]+$' THEN CAST(SPLIT_PART(code, '-', 2) AS integer) END` | anything that is not only digits |
| Extract the digits | `CAST(SUBSTRING(code FROM '[0-9]+') AS integer)` | no digits at all (gives `NULL`); does not depend on the `-` |
| `pg_input_is_valid` (PostgreSQL 16+) | `CASE WHEN pg_input_is_valid(SPLIT_PART(code, '-', 2), 'integer') THEN CAST(SPLIT_PART(code, '-', 2) AS integer) END` | everything, including numbers too big for `integer` |

> 📝 **Note:** `NULLIF(a, b)` returns `NULL` when `a = b`, otherwise `a`. Casting `NULL` gives `NULL`, no error.

> 📝 **Note:** A `CASE` without `ELSE` returns `NULL` when no branch matches.

> 💡 **Tip:** Prefer turning bad values into `NULL` and counting them over letting the query fail: bad data should show up in a report, not stop it.

> 📝 **Note:** Hit in 07-02 (`SPLIT_PART` gives `''`) and 07-08 (sku number).

---

## Window functions

Made-up table used below, `sales(seller, region, amount)`:

| seller | region | amount |
|---|---|---|
| Ana | North | 100 |
| Bruno | North | 300 |
| Carla | South | 200 |
| Duarte | South | 200 |
| Eva | South | 50 |

### `OVER`: a value per row, without merging rows

`GROUP BY` **merges** rows into one per group. A window function **keeps every row** and adds a value computed over related rows (the "window"). `OVER (...)` is what turns an aggregate into a window function.

```sql
SELECT region, SUM(amount) FROM sales GROUP BY region;
-- 2 rows: North 400, South 450

SELECT seller, region, amount,
       SUM(amount) OVER (PARTITION BY region) AS region_total
FROM sales;
-- 5 rows, each with its region's total next to it (400 or 450)
```

| Inside `OVER` | Effect |
|---|---|
| nothing: `OVER ()` | one window: the whole result |
| `PARTITION BY x` | one window per value of `x`; numbering and sums **restart** in each |
| `ORDER BY y` | the order inside the window; needed for numbering, `LAG`/`LEAD` and running totals |

> 💡 **Tip:** Without `ORDER BY`, an aggregate covers the **whole partition**: that's how to put the order total next to each order line (09-08).

---

### `ROW_NUMBER`, `RANK` and `DENSE_RANK`

```sql
SELECT seller, region, amount,
       ROW_NUMBER() OVER (PARTITION BY region ORDER BY amount DESC) AS rn,
       RANK()       OVER (PARTITION BY region ORDER BY amount DESC) AS rnk,
       DENSE_RANK() OVER (PARTITION BY region ORDER BY amount DESC) AS drnk
FROM sales;
```

| seller | region | amount | rn | rnk | drnk |
|---|---|---|---|---|---|
| Bruno | North | 300 | 1 | 1 | 1 |
| Ana | North | 100 | 2 | 2 | 2 |
| Carla | South | 200 | 1 | 1 | 1 |
| Duarte | South | 200 | 2 | 1 | 1 |
| Eva | South | 50 | 3 | **3** | **2** |

- `ROW_NUMBER`: always 1, 2, 3, even on ties.
- `RANK`: ties share a position, then **skip** (1, 1, 3).
- `DENSE_RANK`: ties share a position, **no skip** (1, 1, 2).

> ⚠️ **Warning:** On a tie, `ROW_NUMBER` picks the order **arbitrarily** (Carla and Duarte could swap). Add a tie-breaker to the `ORDER BY` (`amount DESC, seller_id`) so the result is the same every run.

> 📝 **Note:** Without `PARTITION BY` there is one numbering for the whole table: Eva would be `rn = 5`.

---

### Filtering on a window function: top row per group

Window functions run **after** `WHERE` (and after `GROUP BY`/`HAVING`), so they can't be filtered in the same query:

```sql
SELECT seller, ROW_NUMBER() OVER (ORDER BY amount DESC) AS rn
FROM sales
WHERE ROW_NUMBER() OVER (ORDER BY amount DESC) = 1;
-- ERROR: window functions are not allowed in WHERE
```

Compute it in a CTE (or a subquery in `FROM`) and filter outside. Top seller per region:

```sql
WITH ranked AS (
  SELECT seller, region, amount,
         ROW_NUMBER() OVER (PARTITION BY region ORDER BY amount DESC, seller) AS rn
  FROM sales
)
SELECT seller, region, amount
FROM ranked
WHERE rn = 1;
-- Bruno (North), Carla (South)
```

> ⚠️ **Warning:** Give the window column an alias (`AS rn`). Without one, Postgres names it after the function (`row_number`); `WHERE row_number = 1` works, but breaks as soon as you switch to `RANK`.

> 💡 **Tip:** "Most recent" is `ORDER BY ... DESC`, and the tie-breaker goes in the same direction the task asks for: "the higher id counts as the most recent" is `ORDER BY ordered_at DESC, order_id DESC` (09-04).

> 📝 **Note:** Other ways to get the top row per group, without window functions: `DISTINCT ON` and a correlated subquery with `ORDER BY ... LIMIT 1` (08-13).

---

### `LAG` and `LEAD`

`LAG(col)` takes `col` from the **previous** row of the window, `LEAD(col)` from the **next** one. At the edge there is no row, so the result is `NULL`.

```sql
SELECT seller, region, amount,
       LAG(amount)  OVER (PARTITION BY region ORDER BY amount DESC, seller) AS prev_amount,
       LEAD(amount) OVER (PARTITION BY region ORDER BY amount DESC, seller) AS next_amount
FROM sales;
--  Bruno  | North | 300 |      |  100
--  Ana    | North | 100 |  300 |
--  Carla  | South | 200 |      |  200
--  Duarte | South | 200 |  200 |   50
--  Eva    | South |  50 |  200 |
```

> 💡 **Tip:** The `NULL` at the edge is usually what the task wants ("`NULL` for their first order"): no `COALESCE` needed.

> 📝 **Note:** `LAG` gives the **value**, not the difference. For a gap, subtract: `ordered_at - LAG(ordered_at) OVER (...)` is an `interval`, and `EXTRACT(DAY FROM ...)` gives the complete days (09-05).

---

### Running totals and the default frame

With `ORDER BY` inside `OVER`, an aggregate covers the rows **from the start of the window up to the current row**: a running total.

Made-up table `daily(day, steps)`:

| day | steps |
|---|---|
| 1 | 100 |
| 2 | 300 |
| 3 | 200 |

```sql
SELECT day, steps, SUM(steps) OVER (ORDER BY day) AS running
FROM daily;
```

| day | steps | running |
|---|---|---|
| 1 | 100 | 100 |
| 2 | 300 | 400 |
| 3 | 200 | 600 |

> ⚠️ **Warning:** The default frame is `RANGE ... CURRENT ROW`, and **ties in the `ORDER BY` are summed together**. Made-up `t(d, x)` = `(1,10), (2,20), (2,30), (3,40)`:
>
> | d | x | `SUM(x) OVER (ORDER BY d)` | `... ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` |
> |---|---|---|---|
> | 1 | 10 | 10 | 10 |
> | 2 | 20 | **60** | 30 |
> | 2 | 30 | 60 | 60 |
> | 3 | 40 | 100 | 100 |
>
> With one row per value (one row per month after a `GROUP BY`), both are the same. Otherwise, add a tie-breaker to the `ORDER BY` or write `ROWS` explicitly.

> 📝 **Note:** `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` limits the frame to the current row and the 2 before it: a moving window (09-09).

---

### A window over an aggregate

The logical order is `FROM` → `WHERE` → `GROUP BY` → aggregates → **window functions** → `ORDER BY`. So a window function can use an aggregate of the same query:

```sql
SELECT region, SUM(amount) AS total,
       SUM(SUM(amount)) OVER () AS grand_total
FROM sales
GROUP BY region;
--  North | 400 | 850
--  South | 450 | 850
```

`SUM(amount)` is the group's total; `SUM(...) OVER ()` adds those totals across all groups.

> 💡 **Tip:** It works, but it's hard to read. A CTE with the `GROUP BY`, and the window function on top of it, does the same thing in two readable steps (09-07, 09-09).

---

### Moving average and months with no sales

A "3-month" moving average over a monthly `GROUP BY` silently breaks when a month has no sales: that month is **not a row** at all, so nothing marks the gap.

Made-up table `sales(sold_on, amount)` (a different one from the `sales` above), with **no sales in February**:

| sold_on | amount |
|---|---|
| 2024-01-10 | 300 |
| 2024-03-05 | 600 |
| 2024-04-20 | 900 |

| Version | Window | February | April's average |
|---|---|---|---|
| Monthly `GROUP BY` + `ROWS BETWEEN 2 PRECEDING` | last 3 **rows** | missing | (300 + 600 + 900) / 3 = **600**: reaches back to January |
| Monthly `GROUP BY` + `RANGE BETWEEN '2 months' PRECEDING` | last 3 **calendar months** | missing | (600 + 900) / 2 = **750**: right months, but February is skipped, not 0 |
| All months generated + `LEFT JOIN` + `COALESCE(..., 0)` | last 3 calendar months | `0` | (0 + 600 + 900) / 3 = **500** |

The fix: generate every month, start the `FROM` there, and `LEFT JOIN` the revenue:

```sql
WITH months AS (
  SELECT generate_series(
    (SELECT date_trunc('month', MIN(sold_on)) FROM sales),
    (SELECT date_trunc('month', MAX(sold_on)) FROM sales),
    INTERVAL '1 month'
  )::date AS month
),
monthly AS (
  SELECT date_trunc('month', sold_on)::date AS month, SUM(amount) AS total
  FROM sales
  GROUP BY 1
)
SELECT m.month,
       COALESCE(s.total, 0) AS total,
       ROUND(AVG(COALESCE(s.total, 0))
             OVER (ORDER BY m.month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS avg_3m
FROM months m                                -- the table that must be complete goes in FROM
LEFT JOIN monthly s ON s.month = m.month     -- LEFT, not JOIN: a plain JOIN drops February again
ORDER BY m.month;
```

> ⚠️ **Warning:** `AVG` **ignores** `NULL`s, it does not count them as 0. Without the `COALESCE` inside the `AVG`, February is generated but still left out of the average.

> ⚠️ **Warning:** Take the month from the generated table (`m.month`), not from the joined one: on February's row `s.month` is `NULL`.

> 💡 **Tip:** `date_trunc` the `MIN`/`MAX` before `generate_series`, or the series runs on the 10th of each month and never matches. Use the same rules (time zone, status filter) for the bounds as for the revenue.

> 💡 **Tip:** A passing check doesn't prove this is right: if every month has sales, all three versions give the same result. Test by emptying one month in `sqllab_play` (for example, set its orders to `cancelled`).

> 📝 **Note:** Came up after 09-09 (three-month average).
