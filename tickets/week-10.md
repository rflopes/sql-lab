# Week 10: Bridge to the backend

Focus: bridge to the backend: indexes, EXPLAIN, transactions (core), the catalog (optional).
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 10-01 | Predict: lookup by primary key | PREDICT | done |
| 10-02 | Predict: lookup by customer | PREDICT | todo |
| 10-03 | Index for customer lookups | DDL | todo |
| 10-04 | Predict: first rows in id order | PREDICT | todo |
| 10-05 | Undo only half a transaction | DML | todo |
| 10-06 | Which indexes exist? | QUERY | todo |
| 10-07 | One index, two conditions | DDL | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews. Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 10-01: Predict: lookup by primary key ✅
- Type: PREDICT
- Effort: 1 exercise (5 to 12 min)
- Concept: EXPLAIN: primary key lookup
- File: `modules/10-bridge/01-predict.sql`
- Request / symptom: "Which scan will the planner use on page_views? Write one of: Seq Scan, Index Scan, Index Only Scan, Bitmap Heap Scan on the GUESS line, then run the check."
- Definition of done:
  - You wrote your prediction on the `-- GUESS:` line before running anything.
  - `pnpm check 10-01` ran and you know why you were right or wrong. Not graded.

## 10-02: Predict: lookup by customer
- Type: PREDICT (optional)
- Effort: 1 exercise (5 to 12 min)
- Concept: EXPLAIN: filter without an index
- File: `modules/10-bridge/02-predict.sql`
- Request / symptom: "Which scan will the planner use on page_views? Write one of: Seq Scan, Index Scan, Index Only Scan, Bitmap Heap Scan on the GUESS line, then run the check."
- Definition of done:
  - You wrote your prediction on the `-- GUESS:` line before running anything.
  - `pnpm check 10-02` ran and you know why you were right or wrong. Not graded.

## 10-03: Index for customer lookups
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: CREATE INDEX
- File: `modules/10-bridge/03-ddl.sql`
- Request / symptom: "Make lookups of page_views by customer_id able to use an index: create one on that column."
- Definition of done:
  - Make lookups of page_views by customer_id able to use an index: create one on that column.
  - `pnpm check 10-03` is green.

## 10-04: Predict: first rows in id order
- Type: PREDICT (optional)
- Effort: 1 exercise (5 to 12 min)
- Concept: EXPLAIN: sorted output with LIMIT
- File: `modules/10-bridge/04-predict.sql`
- Request / symptom: "Which scan will the planner use on page_views? Write one of: Seq Scan, Index Scan, Index Only Scan, Bitmap Heap Scan on the GUESS line, then run the check."
- Definition of done:
  - You wrote your prediction on the `-- GUESS:` line before running anything.
  - `pnpm check 10-04` ran and you know why you were right or wrong. Not graded.

## 10-05: Undo only half a transaction
- Type: DML
- Effort: 1 exercise (5 to 12 min)
- Concept: Transactions and savepoints
- File: `modules/10-bridge/05-dml.sql`
- Request / symptom: "In ONE transaction: raise the price of product 1 by 10% (rounded to whole cents), then delete all reviews of product 1, then take back only the deletion."
- Definition of done:
  - In ONE transaction: raise the price of product 1 by 10% (rounded to whole cents), then delete all reviews of product 1, then take back only the deletion.
  - After the script: the new price is stored and every review is still there.
  - `pnpm check 10-05` is green.

## 10-06: Which indexes exist?
- Type: QUERY (optional)
- Effort: 1 exercise (5 to 12 min)
- Concept: The system catalog
- File: `modules/10-bridge/06-query.sql`
- Request / symptom: "Return the names of all indexes that exist on the table page_views."
- Definition of done:
  - One column: indexname.
  - `pnpm check 10-06` is green.

## 10-07: One index, two conditions
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: Indexes on more than one column
- File: `modules/10-bridge/07-ddl.sql`
- Request / symptom: "Create ONE index for "what did customer X view between date A and date B?"."
- Definition of done:
  - Exactly one new index on page_views.
  - `pnpm check 10-07` is green.
