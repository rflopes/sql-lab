-- 09-08  QUERY
-- Concept: Window aggregate over a whole partition
-- Task: For order lines of orders up to order_id 20: the line total (quantity * unit_price_cents) and the total of the whole order next to it.
--       Columns: order_item_id, order_id, line_cents, order_cents.
-- Run: pnpm check 09-08

-- Write your query below

SELECT order_item_id, order_id, unit_price_cents * quantity AS line_cents, SUM(unit_price_cents * quantity) OVER (PARTITION BY order_id) AS order_cents
FROM order_items
WHERE order_id <= 20
