-- 08-07  QUERY
-- Concept: CTE
-- Task: The 5 customers who spent most on delivered orders. Spend is the sum of quantity * unit_price_cents over the lines of their delivered orders. Ties: lower customer_id first.
--       Columns: customer_id, spend_cents.   (ORDER MATTERS)
-- Run: pnpm check 08-07

-- Write your query below

WITH totals AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS order_total
  FROM order_items
  GROUP BY order_id
)
SELECT o.customer_id, SUM(t.order_total) AS spend_cents
FROM orders o
JOIN totals t ON t.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY o.customer_id
ORDER BY spend_cents DESC, o.customer_id ASC
LIMIT 5;

-- WITH delivered_orders AS (
--   SELECT order_id, customer_id FROM orders WHERE status = 'delivered'
-- )
-- SELECT d.customer_id, SUM(quantity * unit_price_cents) AS spend_cents
-- FROM delivered_orders d
-- JOIN order_items oi ON oi.order_id = d.order_id
-- GROUP BY d.customer_id
-- ORDER BY spend_cents DESC, d.customer_id ASC
-- LIMIT 5;
