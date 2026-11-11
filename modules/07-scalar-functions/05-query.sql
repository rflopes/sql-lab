-- 07-05  QUERY
-- Concept: Dates: casting and date_trunc
-- Task: For orders up to order_id 30: the calendar date of the order (UTC), and the first day of its month, both as dates.
--       Columns: order_id, order_date, order_month.
-- Run: pnpm check 07-05

-- Write your query below


-- SELECT order_id, CAST(ordered_at AS date) AS order_date, CAST(DATE_TRUNC('month', ordered_at) AS date) AS order_month
SELECT order_id, ordered_at::date AS order_date, DATE_TRUNC('month', ordered_at)::date AS order_month
FROM orders
WHERE order_id <= 30
