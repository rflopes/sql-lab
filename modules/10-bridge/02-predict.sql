-- 10-02  PREDICT  (optional)
-- Concept: EXPLAIN: filter without an index
-- Task: Which scan will the planner use on page_views? Write one of: Seq Scan, Index Scan, Index Only Scan, Bitmap Heap Scan on the GUESS line, then run the check.
--       Not graded.
-- GUESS: 
-- Run: pnpm check 10-02

SELECT * FROM page_views WHERE customer_id = 17;
