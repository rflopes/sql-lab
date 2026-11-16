-- 09-09  QUERY
-- Concept: Frames: ROWS
-- Task: Take the monthly revenue of 09-07 (non-cancelled orders, grouped by month of ordered_at, UTC) and add a moving average over the current month and the 2 months before it (fewer at the start). Round to 2 decimals.
--       Columns: month (first day of the month, as a date), revenue_cents, moving_avg_cents.
-- Run: pnpm check 09-09

-- Write your query below

-- 1. ROWS BETWEEN 2 PRECEDING counts lines, not months. If a month does not have any sale, it does not show up on the CTE.
-- In that case the "3 month" average does not cover 3 consecutive months, but only 3 consecutive months WITH sales.
WITH monthly_orders AS (
  SELECT date_trunc('month', o.ordered_at, 'UTC')::date AS month, SUM(oi.unit_price_cents * oi.quantity) AS revenue_cents
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.status != 'cancelled'
  GROUP BY 1
  ORDER BY month
)
SELECT month, revenue_cents,
  ROUND(AVG(revenue_cents) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_cents
FROM monthly_orders;

-- 2. Generate every month between the first and last order and LEFT JOIN the revenue, so a month without sales shows up as 0
-- and counts as 0 in the average. RANGE '2 months' makes the window follow the calendar, not the row count.
-- WITH months AS (
--   SELECT generate_series(
--     (SELECT date_trunc('month', MIN(ordered_at)) FROM orders),
--     (SELECT date_trunc('month', MAX(ordered_at)) FROM orders),
--     INTERVAL '1 month'
--   )::date AS month
-- ),
-- monthly_orders AS (
--   SELECT date_trunc('month', o.ordered_at, 'UTC')::date AS month, SUM(oi.unit_price_cents * oi.quantity) AS revenue_cents
--   FROM orders o
--   JOIN order_items oi ON o.order_id = oi.order_id
--   WHERE o.status != 'cancelled'
--   GROUP BY 1
--   ORDER BY month
-- )
-- SELECT m.month, COALESCE(mo.revenue_cents, 0) AS revenue_cents,
--   ROUND(AVG(COALESCE(mo.revenue_cents, 0)) OVER (ORDER BY m.month RANGE BETWEEN '2 months' PRECEDING AND CURRENT ROW), 2) AS moving_avg_cents
-- FROM months m
-- LEFT JOIN monthly_orders mo ON m.month = mo.month;

-- 3. RANGE makes the window use the month value, not the row number. A month without sales is not in the CTE,
-- so it is left out of the average (not counted as 0): the average covers 3 calendar months but only the months WITH sales.
-- WITH monthly_orders AS (
--   SELECT date_trunc('month', o.ordered_at, 'UTC')::date AS month, SUM(oi.unit_price_cents * oi.quantity) AS revenue_cents
--   FROM orders o
--   JOIN order_items oi ON o.order_id = oi.order_id
--   WHERE o.status != 'cancelled'
--   GROUP BY 1
--   ORDER BY month
-- )
-- SELECT month, revenue_cents,
--   ROUND(AVG(revenue_cents) OVER (ORDER BY month RANGE BETWEEN '2 months' PRECEDING AND CURRENT ROW), 2) AS moving_avg_cents
-- FROM monthly_orders
