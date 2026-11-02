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
