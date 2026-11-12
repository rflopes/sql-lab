-- 08-02  QUERY
-- Concept: IN with a subquery
-- Task: Return the customers who have at least one order with status 'refunded'. Each customer once.
--       Columns: customer_id, email.
-- Run: pnpm check 08-02

-- Write your query below

SELECT c.customer_id, c.email
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'refunded')
