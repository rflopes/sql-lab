-- 07-10  QUERY
-- Concept: COALESCE
-- Task: For order lines of orders up to order_id 25: the line total after discount, in cents, rounded to a whole number. discount_pct is a percentage; a NULL discount means no discount.
--       Columns: order_item_id, net_cents.
-- Run: pnpm check 07-10

-- Write your query below

SELECT oi.order_item_id, ROUND(oi.quantity * (oi.unit_price_cents - (oi.unit_price_cents * COALESCE(oi.discount_pct, 0) / 100))) AS net_cents
FROM orders o, order_items oi
WHERE o.order_id <= 25 AND o.order_id = oi.order_id;
