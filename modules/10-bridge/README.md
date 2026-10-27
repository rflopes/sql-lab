# Module 10: Bridge to the backend

Not part of the public SQL curriculum, but you will need it as soon as an ORM or a slow endpoint enters the picture. The level is "read and understand", not "tune". Indexes and transactions are core; the exercises marked `(optional)` go a bit further.

**One-time setup:** `pnpm run setup:bridge` creates a table `page_views` with 200 000 rows in the `sqllab` database. (The small shop tables are too small for the planner to ever choose an index.) `pnpm db:reset` removes it; run the setup again afterwards.

## Indexes

An index is a separate, sorted structure that lets the database find rows without reading the whole table.

```sql
CREATE INDEX trips_city_idx ON trips (city);
CREATE INDEX trips_city_day_idx ON trips (city, day);
```

The primary key and `UNIQUE` constraints already create one. A multi-column index helps queries that filter on its **first** column(s). Indexes speed up reads but slow down writes and take space, so you add them for queries that need them.

## EXPLAIN

```sql
EXPLAIN SELECT * FROM trips WHERE id = 7;
EXPLAIN ANALYZE SELECT * FROM trips WHERE city = 'Faro';
```

`EXPLAIN` shows the plan the planner chose; `EXPLAIN ANALYZE` runs the query and adds real timings (careful: it really executes, also for `UPDATE`/`DELETE`; wrap those in a transaction you roll back).

The node names to recognise:

| Node | Meaning |
| --- | --- |
| `Seq Scan` | read the whole table |
| `Index Scan` | walk an index, then fetch the rows |
| `Index Only Scan` | answer from the index alone |
| `Bitmap Heap Scan` | collect many matches from an index, then read them in table order |

The planner uses statistics (refreshed by `ANALYZE`) and chooses the cheapest plan. An index is **not** always used: reading most of a table is cheaper sequentially. The `PREDICT` exercises ask which node you expect; the checker verifies with `EXPLAIN (FORMAT JSON)`.

## Transactions

`BEGIN` ... `COMMIT` makes a group of changes atomic: all or nothing. `ROLLBACK` abandons them; `SAVEPOINT x` and `ROLLBACK TO SAVEPOINT x` abandon only the tail. Other sessions do not see your uncommitted changes. In the default isolation level (`READ COMMITTED`) each statement sees what was committed when *it* started.

## Looking around with psql

`\d table` (columns, indexes), `\di` (indexes), `\l` (databases), `\conninfo`. They are just queries on the **system catalog**: `pg_indexes`, `pg_tables`, `information_schema.columns`. You can query those yourself.

## Common traps

- Believing an index will always be used.
- Forgetting that `EXPLAIN ANALYZE` executes the statement.
- A forgotten `COMMIT` leaves your work unsaved when the session ends.

Manual: <https://www.postgresql.org/docs/17/indexes.html>, <https://www.postgresql.org/docs/17/using-explain.html>
