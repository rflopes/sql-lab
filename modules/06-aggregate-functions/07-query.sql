-- 06-07  QUERY
-- Concept: COUNT(DISTINCT)
-- Task: For each product that was ordered, how many different customers bought it?
--       Columns: product_id, buyers.
-- Run: pnpm check 06-07

-- Write your query below

SELECT oi.product_id, COUNT(DISTINCT o.customer_id) AS buyers
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY oi.product_id
