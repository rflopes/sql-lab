# Module 06: Aggregate functions

Toy table: `visits (pet_id, vet, cost, day)`.

```
pet_id | vet | cost | day
     1 | Lia |   40 | 2025-01-03
     1 | Lia |   25 | 2025-02-10
     2 | Tom |   60 | 2025-01-15
     3 | Lia | NULL | 2025-03-01
```

## Aggregates

They collapse many rows into one value.

```sql
SELECT COUNT(*), COUNT(cost), SUM(cost), AVG(cost), MIN(cost), MAX(cost) FROM visits;
-- 4, 3, 125, 41.67, 25, 60
```

Note the difference: `COUNT(*)` counts rows, `COUNT(cost)` counts non-NULL values, and `SUM`/`AVG` ignore NULLs (so `AVG` divides by 3, not 4). `COUNT(DISTINCT vet)` counts different values.

## GROUP BY

The `GROUP BY` list *is* the grain of the result: `GROUP BY vet` gives one row per vet, `GROUP BY vet, pet_id` one row per vet-and-pet pair.

```sql
SELECT vet, COUNT(*) AS n, SUM(cost) AS total
FROM visits
GROUP BY vet;
```

One result row per group. Every column in `SELECT` must be either in `GROUP BY` or inside an aggregate; PostgreSQL rejects anything else with a clear error (other databases guess silently). Read that error message: it is telling you exactly what is wrong.

## WHERE versus HAVING

`WHERE` filters rows **before** grouping; `HAVING` filters groups **after** aggregating.

```sql
SELECT vet, COUNT(*) FROM visits
WHERE day >= '2025-02-01'      -- rows
GROUP BY vet
HAVING COUNT(*) > 1;           -- groups
```

Aggregates are not allowed in `WHERE`.

## FILTER

Count or sum only some rows, per aggregate:

```sql
SELECT COUNT(*) AS all_visits, COUNT(*) FILTER (WHERE cost >= 40) AS pricey FROM visits;
```

## STRING_AGG

```sql
SELECT vet, STRING_AGG(pet_id::text, ', ' ORDER BY pet_id) FROM visits GROUP BY vet;
```

Glues values into one text. `ORDER BY` inside makes the result predictable.

## Aggregating over joins

After a join, each row of one side repeats once per matching row on the other. Summing a repeated value inflates the total. Join only what the question needs, or aggregate first and join afterwards.

## Common traps

- Integer averages: `AVG` of integers returns `numeric` here, but `SUM(a) / COUNT(*)` on integers truncates.
- `COUNT(column)` silently skips NULLs.
- An aggregate over zero rows: `COUNT` gives 0, but `SUM` and `AVG` give NULL.

Manual: <https://www.postgresql.org/docs/17/functions-aggregate.html>
