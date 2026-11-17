-- 10-04  PREDICT  (optional)
-- Concept: EXPLAIN: sorted output with LIMIT
-- Task: Which scan will the planner use on page_views? Write one of: Seq Scan, Index Scan, Index Only Scan, Bitmap Heap Scan on the GUESS line, then run the check.
--       Not graded.
-- GUESS: Index Scan
-- Run: pnpm check 10-04

-- Index Scan: the primary key's B-tree index keeps view_id already sorted, so walking it
-- from the start returns rows in ORDER BY view_id order with no Sort step.
-- Limit sits on top of the Index Scan and pulls rows from it one at a time; after 5 it
-- stops asking. EXPLAIN ANALYZE: Index Scan actual rows=5, out of ~200,000.
-- Not Index Only Scan: SELECT * needs every column, so each row is fetched from the table.
SELECT * FROM page_views ORDER BY view_id LIMIT 5;
