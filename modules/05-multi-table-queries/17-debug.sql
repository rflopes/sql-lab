-- 05-17  DEBUG
-- Concept: Outer join and WHERE
-- Symptom: Customers who have no cancelled order have disappeared from the result, although the goal was to list everyone.
-- Task: Fix the query: return every customer, together with their cancelled orders. Customers without a cancelled order still appear once, with order_id NULL.
--       Columns: customer_id, email, order_id.
-- Run: pnpm check 05-17

-- The query below is broken. Fix it.
SELECT c.customer_id, c.email, o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'cancelled';
