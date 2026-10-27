# sql-lab

Learn SQL on PostgreSQL by making a checker go from red to green. About 100 small exercises (5 to 12 minutes each) over a small outdoor-gear shop dataset. You write plain SQL in `.sql` files; no JavaScript.

Plan: up to 5 sessions of 30 minutes a week, 2 or 3 exercises per session. See `tickets/` for the week-by-week plan.

## Requirements

- A PostgreSQL 13+ server you can reach (this project was built against 17).
- The `psql` client on your `PATH`.
- Node (LTS) and pnpm.

## Install

```sh
pnpm install
```

### Connect to your local server

The project never guesses credentials and never uses a superuser. Create a dedicated role **once**, with your usual admin account (replace the host, port and password):

```sh
psql -h localhost -p 5432 -d postgres
```

```sql
CREATE ROLE sqllab LOGIN CREATEDB PASSWORD 'choose-a-password';
```

`LOGIN` and `CREATEDB` are the only privileges it has. Then:

```sh
cp .env.example .env     # git-ignored; put your host, port, user and password in it
pnpm run setup
```

> Run it as **`pnpm run setup`**, not `pnpm setup`: the latter is a built-in pnpm command that edits your shell configuration.

`pnpm run setup` checks `psql` and the connection, tells you what it will create, and asks once for confirmation. It creates **one** database, `sqllab`, from `data/schema.sql` and `data/seed.sql`.

### Which databases are touched

Only databases whose name starts with `sqllab`:

| Database | What | Lifetime |
| --- | --- | --- |
| `sqllab` | the original dataset and the template for everything else | permanent |
| `sqllab_play` | disposable copy for `pnpm sql` | until `pnpm sql --reset` |
| `sqllab_chk_*` | one temporary copy per check | dropped right after the check |

Any other database on the server is never read, changed or dropped. The code refuses names outside `sqllab*`, and only drops databases the role itself owns.

## Commands

| Command | Does |
| --- | --- |
| `pnpm run setup` | verify the connection and build `sqllab` (first time) |
| `pnpm check 05-07` | check one exercise |
| `pnpm check module 05` | check a whole module and print a summary |
| `pnpm status` | progress per module, and what is next |
| `pnpm sql` | `psql` on the disposable copy `sqllab_play` |
| `pnpm sql --reset` | recreate that copy from scratch |
| `pnpm db:reset` | rebuild `sqllab` from `data/` (asks first) |
| `pnpm run setup:bridge` | module 10 only: create the big `page_views` table |

## Structure

```
data/        schema.sql, seed.sql           the dataset
modules/     01-introduction ... 10-bridge  README.md (primer) + one .sql per exercise
tickets/     week-01.md ... week-10.md      the plan, exercise by exercise
tools/       the checker (TypeScript)
checks/      expected results, as hashes only
CHECKPOINTS.md, GOTCHAS.md, progress.json
```

An exercise id looks like `05-07` (module 05, exercise 07). Its file is `modules/05-multi-table-queries/07-query.sql`.

## Workflow

1. Read the module primer (first session of each module only).
2. Open the next exercise, read the task, and **write a first attempt without AI**.
3. `pnpm check <id>`; read the feedback; iterate.
4. When green, commit (one commit per session is enough).
5. Anything that surprised you goes into `GOTCHAS.md`.
6. Stop when the planned exercises for the session are done, even with energy left. Note the next exercise id so the next session starts there.

## A graphical SQL client (optional)

`psql` via `pnpm sql` is enough. If you prefer a GUI (pgAdmin, TablePlus, DBeaver...), connect it to **`sqllab_play`**, never to `sqllab`: PostgreSQL cannot copy a database while someone is connected to it, and every check copies `sqllab`. If a check says another session is connected, disconnect your client from `sqllab`.

## Notes

- Results never depend on the server's language settings: `sqllab` uses the `C` collation and every session runs in UTC.
- No expected result depends on `now()`; statements that need a date fix it themselves.
- Each statement has a 5 second limit, which catches accidental cartesian products.
