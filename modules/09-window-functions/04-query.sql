-- 09-04  QUERY
-- Concept: Top row per group
-- Task: Return the most recent order of each customer who has orders. If two orders share the latest timestamp, the higher order_id counts as the most recent.
--       Columns: customer_id, order_id, ordered_at.
-- Run: pnpm check 09-04

-- Write your query below

WITH sorted_orders_by_customer AS (
  SELECT customer_id, order_id, ordered_at, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ordered_at DESC, order_id DESC) AS rn
  FROM orders
)
SELECT customer_id, order_id, ordered_at
FROM sorted_orders_by_customer
WHERE rn = 1
