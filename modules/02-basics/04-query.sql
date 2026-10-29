-- 02-04  QUERY
-- Concept: DISTINCT, NULL, ORDER BY
-- Task: List the different cities where customers live, ignoring customers without a city.
--       One column: city. Sorted alphabetically.   (ORDER MATTERS)
-- Run: pnpm check 02-04

-- Write your query below
SELECT DISTINCT city
FROM customers
WHERE city IS NOT NULL
ORDER BY city ASC
