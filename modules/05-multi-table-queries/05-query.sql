-- 05-05  QUERY
-- Concept: Finding rows with no match
-- Task: Return customers who have never placed an order.
--       Columns: customer_id, email. Sorted by customer_id.   (ORDER MATTERS)
-- Run: pnpm check 05-05

-- Write your query below

SELECT c.customer_id, c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id
