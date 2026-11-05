-- 05-03  QUERY
-- Concept: Many-to-many through a link table
-- Task: List what was bought in order 100: one row per line.
--       Columns: order_id, product_name, quantity.
-- Run: pnpm check 05-03

-- Write your query below

SELECT oi.order_id, p.name as product_name, oi.quantity
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE oi.order_id = 100
