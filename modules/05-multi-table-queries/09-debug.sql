-- 05-09  DEBUG
-- Concept: Ambiguous column names
-- Symptom: PostgreSQL refuses to run the query. Read the message: which name does it complain about, and why?
-- Task: Fix the query: customers with their orders, for order_id up to 20.
--       Columns: customer_id, email, order_id.
-- Run: pnpm check 05-09

-- The query below is broken. Fix it.
SELECT customer_id, email, order_id
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE order_id <= 20;
