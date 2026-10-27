# Module 08: Subqueries and CTEs

Toy tables: `pets (id, name, age)` and `visits (pet_id, cost)`.

## A query inside a query

**Scalar subquery**: returns one value and can be used wherever a value fits.

```sql
SELECT name FROM pets WHERE age > (SELECT AVG(age) FROM pets);
```

If it returns more than one row, PostgreSQL raises an error.

**List subquery**: `IN (SELECT ...)`.

```sql
SELECT name FROM pets WHERE id IN (SELECT pet_id FROM visits WHERE cost > 50);
```

**Subquery in FROM** behaves as a temporary table and needs an alias:

```sql
SELECT AVG(n) FROM (SELECT COUNT(*) AS n FROM visits GROUP BY pet_id) AS t;
```

## Correlated subqueries and EXISTS

A subquery can refer to the current row of the outer query. It runs "per row" conceptually.

```sql
SELECT p.name FROM pets p
WHERE EXISTS (SELECT 1 FROM visits v WHERE v.pet_id = p.id);
```

`EXISTS` only asks whether at least one row comes back (what you select is irrelevant). `NOT EXISTS` is the safe way to say "has none".

**`NOT IN` and NULL:** `x NOT IN (1, 2, NULL)` is never true, because comparing with the NULL is "unknown". If the inner list can contain NULLs, filter them out or use `NOT EXISTS`.

## CTEs: WITH

A common table expression names a step so the query reads top to bottom:

```sql
WITH totals AS (
  SELECT pet_id, SUM(cost) AS total FROM visits GROUP BY pet_id
)
SELECT p.name, t.total
FROM pets p JOIN totals t ON t.pet_id = p.id
WHERE t.total > (SELECT AVG(total) FROM totals);
```

A CTE can be used several times in the same query. Chain more with commas.

## Recursive CTEs

For trees and hierarchies (a folder inside a folder, a manager of a manager):

```sql
WITH RECURSIVE chain AS (
  SELECT id, name, 1 AS depth FROM groups WHERE parent_id IS NULL   -- start
  UNION ALL
  SELECT g.id, g.name, c.depth + 1                                  -- step
  FROM groups g JOIN chain c ON g.parent_id = c.id
)
SELECT * FROM chain;
```

Two parts joined by `UNION ALL`: a starting query, and a step that refers to the CTE itself. It repeats until the step returns no new rows. If your data has a cycle, it will not stop: the checker's 5-second limit will.

## Common traps

- Scalar subquery returning several rows (error) or none (NULL).
- `NOT IN` with a NULL in the list.
- Forgetting the alias on a subquery in `FROM`.
- Writing a recursive CTE where the step never reaches a stop condition.

Manual: <https://www.postgresql.org/docs/17/queries-with.html>
