# BRIEF: hands-on SQL course "sql-lab"

> Specification for building the course (an exercise repo with an automatic checker).
> Course language: the whole repo (exercises, primers, README, `CHECKPOINTS.md`, `GOTCHAS.md`, `CLAUDE.md`, checker messages) and the hints are **in English**.

---

## 1. Context

A hands-on SQL course for people **starting from scratch** or who have not used SQL in a long time. It assumes nothing beyond knowing what a database is.

Format: **short exercises with a visible, immediate result**, organised in ~30-minute sessions (2 or 3 exercises each). Progress shows as the checker turning from red to green.

**Engine: PostgreSQL**, on a **local server the learner already has running**. Do not install or start servers: use the one that exists. Postgres rather than SQLite because it is what is used in production and because it gives explicit errors where SQLite fails silently.

**Curriculum basis:** the public syllabus of the roadmap.sh SQL course (modules and order of topics). **Only the syllabus is used as a guide.** The exercises, the dataset and the texts are original; do not copy or adapt the course's content.

---

## 2. Deliverables

1. A `sql-lab` repo with a realistic dataset, a **checker** that validates each exercise and **~100 exercises** across 9 modules, plus an optional bridge module.
2. A short **primer** per module (the explanation of the concept).
3. **Hints** per exercise, kept outside the repo, with no solutions (section 11).
4. Support files inside the repo (section 10).

---

## 3. Stack, server connection and structure

Check the **current stable versions** in the official registries before pinning dependencies.

- **PostgreSQL**, at the local server's version (`SHOW server_version`). Confirm it supports **window functions, recursive CTEs, `RETURNING`, `FILTER` and `GENERATED … AS IDENTITY` columns**; if the version is too old, warn instead of working around it.
- **Node (current LTS) + TypeScript + `pg` (node-postgres)** only for the checker and utilities. The learner writes **plain SQL** in `.sql` files; no JS is written in this course.
- **`psql` client** for the interactive shell (`pnpm sql`). `pnpm setup` checks that it exists and, if not, explains how to install it.
- Package manager: pnpm.

### Server connection and safety (critical)

The server is personal and **may hold other databases**. Rules:

1. **Never guess credentials.** Read the `PG*` / `SQLLAB_DATABASE_URL` variables from the environment or from a local `.env`; if they are missing, ask for host, port and user.
2. `.env` is in `.gitignore`; only `.env.example` (with no secrets) goes into the repo.
3. **Recommend a dedicated role**, without superuser privileges, with only `LOGIN` and `CREATEDB`. `README.md` gives the exact commands to run once, by hand. No admin command is ever run automatically with a superuser.
4. **The course only touches databases whose name starts with `sqllab`** (`sqllab` as the original and template, `sqllab_play` for the shell, temporary `sqllab_chk_*`). The checker and `setup` **refuse** to operate on any other name and **never** drop anything they did not create.
5. Before creating or dropping databases, `pnpm setup` says what it is about to do and asks for confirmation the first time.

### Repo structure

```
README.md  CLAUDE.md  CHECKPOINTS.md  GOTCHAS.md  progress.json
.env.example  .psqlrc
data/        schema.sql  seed.sql          (the `sqllab` database is built from here)
modules/
  01-introduction/   README.md (primer)  01-....sql  02-....sql ...
  02-basics/         ...
  ...
tools/       checker, runner, shell (checker code, in TypeScript)
checks/      expected results, stored only as hashes (section 5)
.vscode/settings.json   (section 10)
```

Commands (scripts at the root):
- `pnpm setup`: installs dependencies, checks the connection and `psql`, and builds the `sqllab` database from `data/`.
- `pnpm check <id>`: validates one exercise (id = `MM-NN`, for example `05-07`).
- `pnpm check module <MM>`: validates the whole module and shows a summary.
- `pnpm status`: progress table per module (done / total), read from `progress.json`.
- `pnpm sql`: opens `psql` on `sqllab_play`, a **disposable copy** of the database (never on the original). `pnpm sql --reset` recreates the copy. The project's `.psqlrc` (used only by this command) turns on `\timing on` and makes NULL visible (for example `\pset null '(null)'`).
- `pnpm db:reset`: rebuilds `sqllab` from scratch.
- `pnpm setup:bridge` (module 10 only, optional): creates the large table for the bridge module (section 7).

---

## 4. Dataset

A small but rich online shop, with an **original domain** (not a bookshop). Suggestion: an outdoor gear shop, or another domain, as long as it has these tables and relationships.

| Table | Notes |
|---|---|
| `categories` | 3-level tree with `parent_id` (for recursive CTEs) |
| `suppliers` | Some products have no supplier |
| `products` | `unit_price_cents integer`, `weight_kg numeric(6,2)` with NULLs, `is_active boolean`, `created_at timestamptz` |
| `customers` | `referred_by` self-reference, NULLs in phone/city, `signup_date date`, `marketing_opt_in boolean` |
| `employees` | `manager_id` self-reference, 4-level hierarchy |
| `orders` | `status` with `CHECK`, `ordered_at timestamptz`, `shipped_at` NULL, `employee_id` NULL (assisted sale) |
| `order_items` | `quantity`, `unit_price_cents`, `discount_pct numeric(5,2)` NULL |
| `payments` | Orders with no payment, and others with several partial payments |
| `reviews` | `rating` 1 to 5, `body` NULL |

Indicative sizes: ~300 customers, ~80 products, ~1500 orders, ~4000 order lines, ~600 reviews, ~25 employees, ~20 categories, two years of dates.

**Dataset requirements:**
- **Deterministic** (generated with a fixed seed); the generator **does not go into the repo**. The repo only has `schema.sql` and `seed.sql` (`INSERT` statements).
- **Native Postgres types** (`integer`, `numeric`, `text`, `boolean`, `date`, `timestamptz`), primary keys with `GENERATED … AS IDENTITY` and real foreign keys.
- **Deliberate, realistic imperfections**, for exercises on NULLs, cleaning and debugging: inconsistent spacing and capitalisation in names and emails, customers with no orders, products never ordered, categories with no products, reviews with no text, price ties, orders with timestamps on day and month boundaries (for the classic `timestamptz` vs `date` trap).
- **Deterministic results on any machine:** the `sqllab` database is created with **`LC_COLLATE`/`LC_CTYPE` = `C`** (from `template0`), so text ordering does not depend on the server's language, and every checker and shell session sets **`TimeZone = UTC`**. Mention this in the module 2 primer (text ordering depends on the *collation*, a good learning moment).
- **No expected result may depend on `now()`.** When an exercise needs "today", the task fixes a reference date (for example `2026-01-01`).

---

## 5. Exercise mechanism and checker

**One exercise = one `.sql` file.** The task is in a comment at the top; the learner writes the query below it.

**How the checker validates (`SELECT` queries):**
1. Creates a temporary database `sqllab_chk_<random id>` with `CREATE DATABASE … TEMPLATE sqllab` and runs the file in it (exercises are independent and never damage the original). At the end it drops it, and on start-up it cleans up any leftover `sqllab_chk_*`.
2. For query exercises, the file must end in a single query that returns rows; the checker runs every statement and compares **the result of the last one**.
3. Normalises the result: column order as given in the task, column names compared case-insensitively, `numeric` (which `pg` returns as text) converted and rounded to 2 decimal places, `timestamptz` as ISO UTC, NULL treated as a value.
4. Compares it with the expected result, which is stored **only as hashes** in `checks/`: hash of the whole result, number of rows, column names and **one hash per row**.
5. If the task says `ORDER MATTERS`, compares in sequence; otherwise, compares as a set of rows.

**Feedback on failure** (useful without revealing the answer):
- expected vs actual number of rows;
- missing or extra columns;
- how many of the **actual** rows do not exist in the expected result (and up to 3 examples of those rows);
- how many expected rows are missing (the number only);
- Postgres errors shown readably: message, line and, when present, the server's `HINT`.

**Data manipulation (INSERT/UPDATE/DELETE) and definition (CREATE/ALTER) exercises:** the checker runs the script in the temporary database and then runs **internal verification queries** (stored only as hashes, as above) to compare the state. If the script fails halfway, the temporary database is discarded and the message says where.

**Checker safety:** each exercise runs with a `statement_timeout` (for example 5 s) to catch accidental Cartesian products, with a clear message when it is exceeded. See also the connection rules in section 3.

**On passing:** the checker updates `progress.json` and shows a short message with the module's progress.

---

## 6. Exercise types and file format

| Type | What it is |
|---|---|
| `QUERY` | Write a query from a task description |
| `DEBUG` | A given query that returns the wrong result (or a server error); the file describes the symptom and the learner fixes it |
| `PREDICT` | A given query (already correct): the learner writes the number of rows they expect in a `-- GUESS: N` comment, runs it, and the checker reports the difference. **Not graded; it trains intuition.** |
| `DML` | INSERT, UPDATE, DELETE (module 3) |
| `DDL` | CREATE, ALTER, DROP (module 4) |

**`DEBUG` exercises start in module 2**, 2 to 3 per module. Traps to spread around (without listing them in the files): comparing with `= NULL`, `NOT IN` with NULLs in the subquery, a JOIN that multiplies rows and inflates a sum, `WHERE` vs `HAVING`, a `LEFT JOIN` turned into an `INNER` by a filter in `WHERE`, **integer division** (`integer / integer`), `timestamptz` compared with a `date` that excludes the last day, `COUNT(*)` vs `COUNT(column)`, `AVG` ignoring NULLs, `LIMIT` without `ORDER BY`, case-sensitive `LIKE` vs `ILIKE`, a window with `ORDER BY` giving a running total instead of a total (including the effect of ties under the default `RANGE`), `RANK` vs `ROW_NUMBER` on ties.

**Postgres rejects ungrouped columns in a `GROUP BY`** (unlike SQLite). Use this as an exercise in **reading and understanding the error message** (a `DEBUG` whose symptom is the error), not as a silent bug.

**File format:**

```sql
-- 05-07  QUERY
-- Concept: LEFT JOIN, filtering on the right-hand table
-- Task: List every customer who has never placed an order.
--       Return: customer_id, email. Sorted by customer_id.   (ORDER MATTERS)
-- Run: pnpm check 05-07

-- Write your query below


```

Rules:
- Neutral file names (nothing that gives away the technique to use). The concepts appear in the header.
- **Each module opens with 2 very easy warm-up exercises.**
- Each exercise should take **5 to 12 minutes**. If an idea takes longer, split it in two.
- Tasks say **which columns to return and with what names**; they never state the technique or the structure of the query.

---

## 7. Curriculum

Follow the order of the roadmap.sh modules, adapted to Postgres. Indicative counts (adjust to fit 30-minute sessions):

| Module | Topics | Exercises |
|---|---|---|
| 01 Introduction | Relational databases, what SQL is, kinds of commands. Exploring the dataset with `psql` (`\dt`, `\d table`, `\timing`). | 4 (`PREDICT`/exploration) |
| 02 SQL Basics | `SELECT`, aliases, constants, expressions, `DISTINCT`, `WHERE`, logical operators, `IN`/`BETWEEN`/`LIKE`/`ILIKE`, `ORDER BY` (and collation), `LIMIT`/`OFFSET`, NULLs, `IS DISTINCT FROM`, comments | 16 (2 to 3 `DEBUG`) |
| 03 Manipulating Data | `INSERT`, `UPDATE`, `DELETE`, `RETURNING`, `ON CONFLICT` | 6 |
| 04 Defining Tables | `CREATE TABLE`, Postgres types (`integer`/`bigint`/`numeric`/`text`/`boolean`/`date`/`timestamptz`), `GENERATED … AS IDENTITY`, `NOT NULL`, `DEFAULT`, `CHECK`, primary key, `ALTER`, `DROP`, `TRUNCATE`, transactional DDL | 10 |
| 05 Multi-Table Queries | 1:N and N:N relationships, `INNER`/`LEFT`/`FULL`/`CROSS JOIN`, `USING`, self joins, foreign keys, `UNION`/`INTERSECT`/`EXCEPT`, views | 18 (3 `DEBUG`) |
| 06 Aggregate Functions | `COUNT`/`SUM`/`AVG`/`MIN`/`MAX`, `COUNT(DISTINCT)`, `GROUP BY`, `HAVING`, `FILTER`, `STRING_AGG` | 12 (3 `DEBUG`) |
| 07 Scalar Functions | Text (`lower`, `trim`, `split_part`, `concat`, `\|\|`…), numbers, dates (`date_trunc`, `extract`, `to_char`, intervals), conversions (`CAST` and `::`), `CASE`, `COALESCE`, `NULLIF` | 10 |
| 08 Subqueries and CTEs | Subqueries, correlated subqueries, `EXISTS`, CTEs, **recursive CTEs** (employee and category hierarchies) | 12 (2 `DEBUG`) |
| 09 Window Functions | `OVER`, `PARTITION BY`, `ORDER BY`, `ROW_NUMBER`/`RANK`/`DENSE_RANK`, `LAG`/`LEAD`, running totals, frames (`ROWS` vs `RANGE`) | 12 (2 `DEBUG`) |
| 10 Bridge (optional) | Indexes, `EXPLAIN` and `EXPLAIN ANALYZE`, transactions and basic isolation, `psql` essentials | 6 |

Module 10 is a **bridge to the backend**: roadmap.sh does not include it. Mark each exercise `(optional)` in the header and focus on the "read and understand" level.

In this module, the dataset is too small for the planner to use indexes. `pnpm setup:bridge` creates a large table (for example ~200 thousand rows, generated with `generate_series`) **as a separate table**, only in the `sqllab` database. The `PREDICT` exercises here ask the learner to predict the plan node type (`-- GUESS: Seq Scan` or `Index Scan`), verified with `EXPLAIN (FORMAT JSON)` after `ANALYZE`; the `DDL` exercises check that the index exists. Validate that the plans are stable before fixing them.

---

## 8. Primers

One `README.md` per module, **in English**, to read before the first exercise:

- **At most ~600 words**, readable in 5 minutes.
- Explain the concept with **examples on a toy mini-table** that is **not part of the dataset** (for example a `pets` table with 5 rows, included in the text itself). That way no example gives away the answer to an exercise.
- End with a "Common traps" section of 2 or 3 lines (without the specific `DEBUG` exercises).
- Link to the official PostgreSQL documentation (for the server's version) where it helps.

The primers and the tutor may **teach concepts directly**. The anti-AI rule applies to **writing the exercise queries**, not to understanding the concepts.

---

## 9. Anti-solution rules (critical)

1. **No solutions in the repo, in the hints or in notes.** Expected results are stored only as hashes.
2. The reference solutions needed to generate the hashes and to test the checker live **in a temporary location, outside the repo and the hints**, and **are deleted at the end**.
3. **Never expose the reference solutions** in any output visible to the learner.
4. A **single initial commit** on `main`; no branches or tags. The history must not reveal anything.
5. Exercise files contain no code beyond the task (except `DEBUG` and `PREDICT`, which include the query to analyse, with no comments that give the defect away).
6. **Always check that each exercise has a single reasonable interpretation.** If two different but legitimate queries give different results, the task must remove the ambiguity (columns, ordering, handling of NULLs and ties).

---

## 10. Support files inside the repo (in English)

- `README.md`: installing, connecting to the local server, **creating the dedicated role** (commands to run by hand), running the checker, structure, workflow (below), and optional SQL clients (the project's `psql` is enough; a graphical client is optional).
- `CLAUDE.md`: tutor mode (below).
- `CHECKPOINTS.md`: checkpoint template (section 12), with no entries.
- `GOTCHAS.md`: empty, with one line of instruction: *"Write here, in your own words, every surprise or mistake you hit. Review it at each checkpoint."*
- `progress.json`: managed by the checker.
- `.env.example` and `.psqlrc`: see section 3.
- `.vscode/settings.json`: **turn off inline AI code suggestions** in this workspace (for example `editor.inlineSuggest.enabled: false`) and associate `.sql` with the PostgreSQL dialect if an extension exists. It is only the default; it can be changed.

**Workflow (for the README):**
1. Read the module primer (first session of each module only).
2. Open the next exercise, read the task, and **write a first attempt without AI**.
3. `pnpm check <id>`; read the feedback; iterate.
4. When green, commit (one commit per session is enough).
5. Anything that surprised you goes into `GOTCHAS.md`.
6. Stop when the planned exercises for the session are done. Note the next exercise id so the next session starts there.

**`CLAUDE.md` text (tutor mode):**

```
This repo is for practice. The goal is to learn SQL, not to finish exercises.
Assume the learner is starting from scratch.

Never:
- write, complete or correct the query for an exercise (QUERY, DEBUG, DML, DDL);
- reveal which technique an exercise needs before the learner has made an attempt;
- read any hint file;
- edit files under modules/, checks/ or data/ on the learner's behalf;
- run anything against a database whose name does not start with "sqllab", and never use superuser credentials unless the learner explicitly provides them for a specific task.

You may:
- explain SQL concepts clearly and directly, using small examples on made-up tables that are NOT the project dataset;
- ask guiding questions (ladder: question, general direction, only then a concrete pointer);
- after an attempt, review the query and explain what the checker feedback means, by asking questions rather than listing fixes;
- explain PostgreSQL error messages;
- help with tooling (pnpm, psql, the connection setup) that is not the exercise itself;
- if the learner has been stuck on one exercise for more than two sessions, offer pair work: they type, you ask questions.

If asked to "just write it", kindly restate the goal and offer a question to unblock them.
```

---

## 11. Hints (outside the repo, no solutions)

**One file per module** (`02-basics.md`, …), kept outside the repo, with one section per `QUERY`/`DEBUG`/`DML`/`DDL` exercise, in English, with **only two levels**:

1. **Level 1:** which part of SQL to think about (a clause or an idea), without saying how to combine them.
2. **Level 2:** the *shape* of the answer (for example "one row per customer, so what do you group by?"), without writing any SQL.

**No manifest, no solutions, no full or partial queries.** If the learner gets stuck, the way out is pair work with the tutor (section 10).

---

## 12. Checkpoints (in English, in `CHECKPOINTS.md`)

10-minute limit, 3 or 4 lines. **A checkpoint never adds tasks**; it only adjusts pace, order or difficulty.

- **Concept checkpoint (end of each module):** explain the module's main idea in your own words, without looking anything up; answer one prediction question ("what would happen if…?") and verify it in `psql`; list what is still foggy and pick one thing to revisit; skim `GOTCHAS.md`.
- **Weekly checkpoint:** sessions done vs planned; what got in the way; one adjustment for next week.
- If they coincide, merge them into one.

---

## 13. Final verification (mandatory)

- [ ] `pnpm setup`, `pnpm status`, `pnpm sql` and `pnpm check module 01` work on a clean clone, with a role **without** superuser privileges (only `LOGIN` and `CREATEDB`).
- [ ] The course only created, used and dropped databases with the `sqllab` prefix; **no other database on the server was touched**; no `sqllab_chk_*` databases were left behind.
- [ ] Every exercise has a reference solution that passes the checker, and a set of plausible wrong attempts (empty result, `SELECT *`, missing `DISTINCT`, an extra JOIN, wrong ordering) that **fail** with understandable feedback.
- [ ] No expected result depends on `now()`, the server's *collation*, the time zone or unspecified ordering; `ORDER MATTERS` exercises have a deterministic tie-break.
- [ ] `DEBUG` exercises fail as described and can be fixed for a single reason each.
- [ ] `DML`/`DDL` exercises do not change the original database and are independent of each other.
- [ ] The checker has a `statement_timeout` and shows clear messages for Postgres errors.
- [ ] Primers are ≤ ~600 words and **do not use dataset tables** in their examples.
- [ ] No solutions anywhere (repo, hints, notes); temporary location deleted; no secrets in the repo.
- [ ] `git log` with a single commit, `main` only.
- [ ] Final report: **counts only** (exercises per module and per type), how to run the course and where to start (module 01 primer).

---

## 14. Possible extensions

- A second dataset, from another domain, to practise analysis on different data.
- A variant of the course on another engine (for example SQLite), with the dialect differences as exercises.
- Decided based on the checkpoints. **Do not implement any of this in the first version.**
