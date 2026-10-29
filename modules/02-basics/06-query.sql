-- 02-06  QUERY
-- Concept: Matching a list of values
-- Task: Return customers who live in Lisbon, Porto or Braga.
--       Columns: customer_id, city. Sorted by customer_id.   (ORDER MATTERS)
-- Run: pnpm check 02-06

-- Write your query below
SELECT customer_id, city
FROM customers
WHERE LOWER(TRIM(city)) IN ('porto', 'lisbon', 'braga')
ORDER BY customer_id
