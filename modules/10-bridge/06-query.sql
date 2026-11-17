-- 10-06  QUERY  (optional)
-- Concept: The system catalog
-- Task: Return the names of all indexes that exist on the table page_views.
--       One column: indexname.
-- Run: pnpm check 10-06

-- Write your query below
SELECT indexname
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'page_views'
