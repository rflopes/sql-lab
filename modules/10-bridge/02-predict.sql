-- 10-02  PREDICT  (optional)
-- Concept: EXPLAIN: filter without an index
-- Task: Which scan will the planner use on page_views? Write one of: Seq Scan, Index Scan, Index Only Scan, Bitmap Heap Scan on the GUESS line, then run the check.
--       Not graded.
-- GUESS: Seq Scan
-- Run: pnpm check 10-02

-- Seq Scan: customer_id has no index, so Postgres has to read every row and test
-- "customer_id = 17" on each one.
-- EXPLAIN ANALYZE: 644 rows returned, 199,333 removed by the filter (~0.3% kept).
-- A Seq Scan reads pages in order and is fine when a filter keeps a large share of the table;
-- here the filter is very selective, so almost all the work is wasted. An index would help.
SELECT * FROM page_views WHERE customer_id = 17;
