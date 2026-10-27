# Module 03: Manipulating data

Every exercise here runs your script on a throwaway copy, then checks the resulting **state** of the tables. The original database is never touched.

## INSERT

```sql
INSERT INTO pets (name, species, age) VALUES ('Nibbles', 'rabbit', 1);
INSERT INTO pets (name, species, age) VALUES ('Zed', 'dog', 3), ('Kiwi', 'bird', 2);
```

List the columns you fill; the rest get their default or `NULL`. Identity columns (`GENERATED ... AS IDENTITY`) fill themselves: do not provide them. You can also insert the result of a query: `INSERT INTO t (a, b) SELECT ...`.

## UPDATE

```sql
UPDATE pets SET age = age + 1 WHERE species = 'cat';
```

`SET` can use the old values of the row. **Without `WHERE`, every row changes.**

## DELETE

```sql
DELETE FROM pets WHERE age > 10;
```

Same warning: no `WHERE`, no mercy. A good habit is to write the `SELECT` with the same `WHERE` first and look at what it returns.

## RETURNING

PostgreSQL can give back the rows it just wrote:

```sql
INSERT INTO pets (name, species) VALUES ('Zed', 'dog') RETURNING id, name;
UPDATE pets SET age = 5 WHERE id = 1 RETURNING *;
```

Useful for fetching generated ids without a second query.

## ON CONFLICT (upsert)

When a row would break a unique rule, you can choose what happens instead of failing:

```sql
INSERT INTO tags (label, uses) VALUES ('urgent', 1)
ON CONFLICT (label) DO UPDATE SET uses = tags.uses + EXCLUDED.uses;
```

`EXCLUDED` is the row you tried to insert. `ON CONFLICT ... DO NOTHING` simply skips it. The conflict target must be a column (or set) with a unique constraint.

## Common traps

- `UPDATE` or `DELETE` without `WHERE`.
- Foreign keys: you cannot delete a row that others still point at, or insert one pointing at nothing.
- Updating with an expression of the wrong type, for example whole-number division that silently truncates.

Manual: <https://www.postgresql.org/docs/17/dml.html>
