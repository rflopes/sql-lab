-- 10-01  PREDICT
-- Concept: EXPLAIN: primary key lookup
-- Task: Which scan will the planner use on page_views? Write one of: Seq Scan, Index Scan, Index Only Scan, Bitmap Heap Scan on the GUESS line, then run the check.
--       Requires: pnpm run setup:bridge (once). Not graded.
-- GUESS: 
-- Run: pnpm check 10-01

SELECT * FROM page_views WHERE view_id = 12345;
