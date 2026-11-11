-- 06-10  DEBUG
-- Concept: WHERE versus HAVING
-- Symptom: PostgreSQL reports an error about where an aggregate function may appear.
-- Task: Fix the query: customers with at least 10 orders.
--       Columns: customer_id, order_count.
-- Run: pnpm check 06-10

-- The query below is broken. Fix it.
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 10
