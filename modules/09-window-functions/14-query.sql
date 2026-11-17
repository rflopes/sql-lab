-- 09-14  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Best seller per category in 2025: for each category (the product's own category), the product with the most units sold
--       (sum of quantity) in orders placed in 2025 (UTC, by ordered_at, any status). On a tie, pick the lower product_id.
--       Categories with no sales in 2025 are left out.
--       Columns: category_id, product_id, units. Sorted by category_id.   (ORDER MATTERS)
-- Run: pnpm check 09-14

-- Write your query below

-- 1. All products whose units equal their category's max, so tied products all appear.
-- WITH orders_in_2025 AS (
--   SELECT order_id
--   FROM orders
--   WHERE ordered_at  >= '2025-01-01 00:00:00 UTC' AND ordered_at < '2026-01-01 00:00:00 UTC'
-- ),
-- product_sales AS (
--   SELECT p.product_id, p.category_id, SUM(oi.quantity) AS product_units
--   FROM order_items oi
--   JOIN products p ON p.product_id = oi.product_id
--   JOIN orders_in_2025 o2025 ON o2025.order_id = oi.order_id
--   GROUP BY p.product_id
-- ),
-- max_per_category AS (
--   SELECT ps.category_id, ps.product_id, ps.product_units, MAX(ps.product_units) OVER (PARTITION BY ps.category_id) AS max_category_units
--   FROM product_sales ps
-- )
-- SELECT mpc.category_id, mpc.product_id, mpc.max_category_units AS units
-- FROM max_per_category mpc
-- WHERE mpc.product_units = max_category_units
-- ORDER BY mpc.category_id

-- 2. Single winner: ROW_NUMBER picks one per category; on a tie, the lower product_id wins.
WITH orders_in_2025 AS (
  SELECT order_id
  FROM orders
  WHERE ordered_at  >= '2025-01-01 00:00:00 UTC' AND ordered_at < '2026-01-01 00:00:00 UTC'
),
product_sales AS (
  SELECT p.product_id, p.category_id, SUM(oi.quantity) AS product_units
  FROM order_items oi
  JOIN products p ON p.product_id = oi.product_id
  JOIN orders_in_2025 o2025 ON o2025.order_id = oi.order_id
  GROUP BY p.product_id
),
ranked_per_category AS (
  SELECT ps.category_id, ps.product_id, ps.product_units,
    ROW_NUMBER() OVER (PARTITION BY ps.category_id ORDER BY ps.product_units DESC, ps.product_id) AS rn
  FROM product_sales ps
)
SELECT rpc.category_id, rpc.product_id, rpc.product_units AS units
FROM ranked_per_category rpc
WHERE rpc.rn = 1
ORDER BY rpc.category_id
