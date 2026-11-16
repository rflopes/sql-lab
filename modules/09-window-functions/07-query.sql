-- 09-07  QUERY
-- Concept: Running totals
-- Task: Monthly revenue and its running total. Revenue = sum of quantity * unit_price_cents over the lines of orders whose status is not 'cancelled', grouped by the month of ordered_at (UTC). The running total adds up the months so far, in month order.
--       Columns: month (first day of the month, as a date), revenue_cents, running_cents.
-- Run: pnpm check 09-07

-- Write your query below

WITH monthly_orders AS (
  SELECT date_trunc('month', o.ordered_at, 'UTC')::date AS month, SUM(oi.unit_price_cents * oi.quantity) AS revenue_cents
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.status != 'cancelled'
  GROUP BY 1
  ORDER BY month
)
SELECT month, revenue_cents,
  SUM(revenue_cents) OVER (ORDER BY month) as running_cents
FROM monthly_orders
