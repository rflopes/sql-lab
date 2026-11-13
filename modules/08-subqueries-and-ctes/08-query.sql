-- 08-08  QUERY
-- Concept: CTE used twice
-- Task: Among the months of 2025 (UTC), return those with more orders than the average monthly number of orders in 2025.
--       Columns: month (first day of the month, as a date), order_count.
-- Run: pnpm check 08-08

-- Write your query below

WITH monthly_orders AS (
  SELECT date_trunc('month', ordered_at, 'UTC')::date AS month, COUNT(*) AS order_count
  FROM orders
  WHERE ordered_at >= '2025-01-01 00:00:00 UTC' AND ordered_at < '2026-01-01 00:00:00 UTC'
  GROUP BY 1
  ORDER BY month
)
SELECT month, order_count
FROM monthly_orders
WHERE monthly_orders.order_count > (SELECT AVG(monthly_orders.order_count) FROM monthly_orders)
