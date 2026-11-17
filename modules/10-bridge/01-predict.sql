-- 10-01  PREDICT
-- Concept: EXPLAIN: primary key lookup
-- Task: Which scan will the planner use on page_views? Write one of: Seq Scan, Index Scan, Index Only Scan, Bitmap Heap Scan on the GUESS line, then run the check.
--       Requires: pnpm run setup:bridge (once). Not graded.
-- GUESS: Index Scan
-- Run: pnpm check 10-01

-- Index Scan: view_id has a B-tree index (created by the PRIMARY KEY), and "= 12345" matches
-- at most one row, so reading the index is far cheaper than scanning the whole table.
-- Not Index Only Scan: the index only stores view_id plus a pointer to the row (heap);
-- SELECT * needs every column, so Postgres follows the pointer and reads the row from the table.
SELECT * FROM page_views WHERE view_id = 12345;
