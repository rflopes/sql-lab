-- 02-10  QUERY
-- Concept: Pagination
-- Task: Customers sorted by customer_id, 20 per page: return page 3.
--       Columns: customer_id, email.   (ORDER MATTERS)
-- Run: pnpm check 02-10

-- Write your query below

SELECT customer_id, email
FROM customers
ORDER BY customer_id
LIMIT 20
OFFSET (3-1)*20
