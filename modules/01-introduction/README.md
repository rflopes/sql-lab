# Module 01: Introduction

Read this once (5 minutes), then open `01-query.sql`.

## What a relational database is

Data lives in **tables**. A table has **columns** (name and type) and **rows** (one record each). Tables point at each other through keys: a **primary key** identifies a row, a **foreign key** stores another table's primary key. That is the whole idea; everything else is detail.

Throughout this primer we use a toy table that is *not* part of the project:

```
pets
 id | name  | species | age | owner_id
----+-------+---------+-----+---------
  1 | Biscuit | dog   |  4  | 10
  2 | Mochi   | cat   |  2  | 10
  3 | Pip     | bird  |  1  | 11
  4 | Rex     | dog   |  9  | NULL
  5 | Luna    | cat   |  6  | 12
```

## What SQL is

SQL is **declarative**: you describe the result you want, not the steps to compute it. The server decides how. Commands come in families:

| Family | Purpose | Examples |
| --- | --- | --- |
| Queries | read data | `SELECT` |
| DML | change rows | `INSERT`, `UPDATE`, `DELETE` |
| DDL | change structure | `CREATE TABLE`, `ALTER`, `DROP` |
| Transactions | group changes | `BEGIN`, `COMMIT`, `ROLLBACK` |

The smallest useful query:

```sql
SELECT name, species FROM pets;
```

`SELECT *` means "all columns". It is fine for exploring, but exercises ask for exact columns.

## Your tool: psql

`pnpm sql` opens `psql` on **`sqllab_play`**, a disposable copy of the dataset. Break things freely; `pnpm sql --reset` makes a fresh copy.

| Command | Does |
| --- | --- |
| `\dt` | list tables |
| `\d tablename` | columns, types, keys of one table |
| `\timing on` | show how long each query takes (already on here) |
| `\x auto` | switch to vertical output when rows are wide |
| `\q` | leave |

SQL statements end with `;`. Meta-commands starting with `\` do not.

## How the exercises work

Each exercise is a `.sql` file. The task is in a comment at the top, you write below it, then run `pnpm check 01-01`. The checker runs your file on a throwaway copy of the database and compares your result with the expected one. It tells you what is off (row counts, columns, a few of *your* wrong rows), never the answer.

`PREDICT` exercises are different: you write a guess first, then the checker tells you how far off you were. They are not graded.

## The dataset

An outdoor gear shop with nine tables: `categories`, `suppliers`, `products`, `customers`, `employees`, `orders`, `order_items`, `payments`, `reviews`. Money is stored in integer **cents**. Take five minutes with `\d` on each, to see what is there.

## Common traps

- Forgetting the `;` in `psql` and wondering why nothing happens (the prompt changes to `-#`: it is waiting).
- Text values use **single quotes** (`'dog'`). Double quotes are for identifiers.

PostgreSQL manual: <https://www.postgresql.org/docs/17/tutorial.html>
