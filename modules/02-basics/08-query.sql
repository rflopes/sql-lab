-- 02-08  QUERY
-- Concept: Testing for NULL
-- Task: Return customers who have no phone number recorded.
--       Columns: customer_id, first_name, last_name. Sorted by customer_id.   (ORDER MATTERS)
-- Run: pnpm check 02-08

-- Write your query below

SELECT customer_id, first_name, last_name
FROM customers
WHERE phone IS NULL OR TRIM(phone) = ''
ORDER BY customer_id
