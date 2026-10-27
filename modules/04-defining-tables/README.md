# Module 04: Defining tables

## CREATE TABLE

```sql
CREATE TABLE toys (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name       text        NOT NULL,
  price_cents integer    NOT NULL CHECK (price_cents >= 0),
  in_stock   boolean     NOT NULL DEFAULT true,
  added_at   timestamptz NOT NULL DEFAULT now()
);
```

### Types you will use daily

| Type | For |
| --- | --- |
| `integer`, `bigint` | whole numbers (about 2 billion / 9 quintillion) |
| `numeric(p, s)` | exact decimals: `p` digits in total, `s` after the point |
| `text` | any text (in PostgreSQL there is no reason to prefer `varchar(n)`) |
| `boolean` | true / false |
| `date` | a calendar day |
| `timestamptz` | an instant in time (use this, not plain `timestamp`) |

Never store money in floating point; use integer cents or `numeric`.

### Constraints

`NOT NULL`, `DEFAULT x`, `CHECK (condition)`, `UNIQUE`, `PRIMARY KEY`, and `REFERENCES other (col)` for a foreign key. A constraint on several columns is written after the column list: `PRIMARY KEY (a, b)`, `UNIQUE (a, b)`. The database enforces them for every client, which is why they beat checks in application code.

## Designing tables

Syntax is the easy part; the design decides how many bugs the data can contain.

- **Every table gets a key.** A surrogate `id` identity is the default; also add `UNIQUE` on the real-world identifier (a SKU, an email) so duplicates cannot sneak in.
- **One fact in one place.** If the same text repeats on many rows (`'Lisbon'` 300 times), it usually belongs in its own table, referenced by id. Changing it then means changing one row. This is *normalisation*.
- **Many-to-many needs a link table**: `pet_clubs (pet_id, club_id)` with `PRIMARY KEY (pet_id, club_id)`, so the same pair cannot appear twice.
- **Decide what a delete means.** A foreign key can say `ON DELETE RESTRICT` (the default behaviour: refuse to delete a parent that still has children), `ON DELETE CASCADE` (delete the children too) or `ON DELETE SET NULL`. Choose per relationship: deleting an owner should not silently delete invoices.
- **Uniqueness can apply to an expression**, not just a column: `CREATE UNIQUE INDEX ON owners (lower(name));` treats `Ana` and `ana` as the same.
- **Money is integer cents** (or `numeric`), never `float`.

## ALTER TABLE

```sql
ALTER TABLE toys ADD COLUMN colour text;
ALTER TABLE toys ADD CONSTRAINT price_sane CHECK (price_cents < 100000);
ALTER TABLE toys DROP COLUMN colour;
```

Adding a `NOT NULL` column to a table that has rows needs a `DEFAULT`, otherwise the existing rows would break the rule.

## DROP and TRUNCATE

`DROP TABLE toys;` removes the table. `TRUNCATE toys;` empties it quickly but keeps it; add `RESTART IDENTITY` to reset the id counter. Both are destructive: there is no undo outside a transaction.

## DDL is transactional

In PostgreSQL, structure changes can be rolled back:

```sql
BEGIN;
DROP TABLE toys;
ROLLBACK;        -- toys is still there
```

`SAVEPOINT name` / `ROLLBACK TO SAVEPOINT name` undo only the part after the mark. If a script ends in an open transaction, nothing was committed: the checker will tell you.

## Common traps

- A `serial`-style default is not the same as an identity column; use `GENERATED ... AS IDENTITY`.
- `numeric(5,2)` stores at most `999.99`.
- Forgetting `COMMIT` after `BEGIN`.

Manual: <https://www.postgresql.org/docs/17/ddl.html>
