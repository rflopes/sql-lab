-- 09-11  DEBUG
-- Concept: Window ORDER BY changes the frame
-- Symptom: order_cents grows from one row to the next inside each order instead of showing the order's total.
-- Task: Fix the query: every line of an order shows the total of the whole order.
--       Columns: order_id, order_item_id, line_cents, order_cents.
-- Run: pnpm check 09-11

-- The query below is broken. Fix it.
SELECT order_id, order_item_id,
       quantity * unit_price_cents AS line_cents,
       SUM(quantity * unit_price_cents) OVER (PARTITION BY order_id) AS order_cents
FROM order_items
WHERE order_id <= 10;
