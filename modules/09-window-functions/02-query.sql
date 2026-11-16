-- 09-02  QUERY
-- Concept: PARTITION BY
-- Task: Number each customer's orders chronologically: 1 for their first order, 2 for the second... If two orders have the same timestamp, the lower order_id comes first.
--       Columns: order_id, customer_id, order_number.
-- Run: pnpm check 09-02

-- Write your query below

SELECT order_id, customer_id, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ordered_at, order_id) AS order_number
FROM orders
