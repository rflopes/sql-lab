-- 05-15  QUERY
-- Concept: Set intersection
-- Task: Return the customer_id of customers who have written at least one review and also have at least one order with status 'cancelled'.
--       One column: customer_id.
-- Run: pnpm check 05-15

-- Write your query below
SELECT customer_id FROM reviews
INTERSECT
SELECT o.customer_id FROM orders o WHERE o.status = 'cancelled'
