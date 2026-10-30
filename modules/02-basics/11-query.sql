-- 02-11  QUERY
-- Concept: Sorting text and collation
-- Task: Return the distinct values of last_name from customers exactly as stored (no cleaning), sorted ascending.
--       One column: last_name. Look at where lowercase and uppercase names land, then read about collation in the primer.   (ORDER MATTERS)
-- Run: pnpm check 02-11

-- Write your query below
SELECT DISTINCT last_name
FROM customers
ORDER BY last_name ASC 
