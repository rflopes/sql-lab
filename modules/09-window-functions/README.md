# Module 09: Window functions

An aggregate with `GROUP BY` collapses rows. A **window function** computes across a set of related rows **without** collapsing them: every row stays, and gets an extra value.

Toy table:

```
runners: name  | team | secs
         Ada   | red  | 310
         Bo    | red  | 295
         Cy    | red  | 295
         Di    | blue | 330
```

## OVER

```sql
SELECT name, team, secs,
       AVG(secs) OVER (PARTITION BY team) AS team_avg
FROM runners;
```

- `PARTITION BY` splits rows into groups (optional; without it the window is the whole result).
- `ORDER BY` inside `OVER` orders rows within each group.

Window functions can only appear in `SELECT` and `ORDER BY`. To filter on one, wrap the query: compute in a subquery or CTE, then `WHERE` in the outer query.

## Ranking

```sql
ROW_NUMBER() OVER (PARTITION BY team ORDER BY secs)   -- 1,2,3  never ties
RANK()       OVER (PARTITION BY team ORDER BY secs)   -- 1,2,2,4 gaps after ties
DENSE_RANK() OVER (PARTITION BY team ORDER BY secs)   -- 1,2,2,3 no gaps
```

For red: Bo and Cy tie at 295. `ROW_NUMBER` still picks one of them arbitrarily unless you add a tie-breaker to the `ORDER BY`.

## LAG and LEAD

`LAG(secs) OVER (ORDER BY ...)` is the value from the previous row, `LEAD` from the next. The first (or last) row has NULL. `LAG(x, 2)` looks two rows back.

## Aggregates as windows, running totals

```sql
SUM(secs) OVER ()                         -- grand total on every row
SUM(secs) OVER (PARTITION BY team)        -- total per team on every row
SUM(secs) OVER (ORDER BY name)            -- running total
```

**Adding `ORDER BY` changes what the window looks at**: from "the whole partition" to "from the start up to the current row". That single clause is behind many "why is my total growing?" bugs.

## Frames

The frame says which rows around the current one count:

```sql
AVG(secs) OVER (ORDER BY name ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
```

`ROWS` counts physical rows. `RANGE` (the default when you have an `ORDER BY`) treats rows with equal sort values as peers and includes **all** of them, so ties change the numbers. `FIRST_VALUE(x)`, `LAST_VALUE(x)` and `NTILE(n)` are also worth a look.

## Common traps

- `ROW_NUMBER` where you meant `RANK` (tied rows disappear) or the other way around.
- `LAST_VALUE` with the default frame returns the current row, not the last of the partition.
- Using a window function in `WHERE` (error): wrap the query.

Manual: <https://www.postgresql.org/docs/17/tutorial-window.html>
