# Module 05: Multi-table queries

Toy tables for this primer (not in the project):

```
owners: id | name        pets: id | name    | owner_id
        10 | Ana               1 | Biscuit | 10
        11 | Bruno             2 | Mochi   | 10
        12 | Carla             3 | Pip     | 11
                               4 | Rex     | NULL
```

## Relationships

`pets.owner_id` is a **foreign key** to `owners.id`: one owner has many pets (1:N). When both sides can have many (pets and the clubs they belong to) a third **link table** holds pairs (`pet_id`, `club_id`): that is N:N.

## JOIN

```sql
SELECT p.name, o.name AS owner
FROM pets p
JOIN owners o ON o.id = p.owner_id;
```

`p` and `o` are table aliases; use them whenever a column name exists in both tables (otherwise PostgreSQL says the reference is *ambiguous*). `JOIN` is short for `INNER JOIN`: only pairs that match survive, so Rex and Carla disappear.

| Join | Keeps |
| --- | --- |
| `INNER JOIN` | matching pairs only |
| `LEFT JOIN` | all left rows; right side is NULL when nothing matches |
| `RIGHT JOIN` | the mirror image (rarely needed: swap the tables) |
| `FULL JOIN` | all rows of both sides |
| `CROSS JOIN` | every left row with every right row, no condition |

If the join column has the same name on both sides you may write `USING (col)` instead of `ON`.

## Finding what is missing

A `LEFT JOIN` followed by `WHERE right_side.key IS NULL` finds left rows with no match (owners without pets).

## Self join

A table can join itself, with two aliases for its two roles: an employee row and the row of their manager.

## Set operations

`UNION` (stack, remove duplicates), `UNION ALL` (stack, keep everything), `INTERSECT` (rows in both), `EXCEPT` (in the first, not in the second). Both queries need the same number of compatible columns.

## Views

`CREATE VIEW name AS SELECT ...;` saves a query under a name. You read it like a table. It stores no data of its own.

## Joins change the grain

A join's result has one row per **matching pair**. Joining owners to pets gives one row per pet, not per owner. Joining the same owner to *two* one-to-many tables (pets and vet visits) gives pets × visits rows for that owner. Before trusting a number, ask what one row now stands for.

## Common traps

- A condition on the right-hand table in `WHERE` after a `LEFT JOIN` removes the NULL rows and silently turns it into an inner join. Put it in `ON`.
- Joining through a table that has several rows per key **multiplies** rows. Count before and after.
- Forgetting the join condition gives a cartesian product (every row times every row). The checker stops queries that run longer than 5 seconds.

Manual: <https://www.postgresql.org/docs/17/queries-table-expressions.html>
