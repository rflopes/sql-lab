-- 07-12  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: How fast did we ship in 2024? For orders placed in 2024 (UTC, by ordered_at) that have been shipped, compute per month of ordered_at
--       the average time from ordered_at to shipped_at, in days, measured exactly (36 hours counts as 1.5 days), rounded to 1 decimal.
--       Columns: month (text like '2024-03'), avg_days_to_ship. Sorted by month.   (ORDER MATTERS)
-- Run: pnpm check 07-12

-- Write your query below

SELECT TO_CHAR(ordered_at, 'YYYY-MM') AS month, ROUND(AVG(EXTRACT(EPOCH FROM shipped_at - ordered_at) / 86_400), 1) AS avg_days_to_ship
FROM orders
WHERE ordered_at >= '2024-01-01 00:00:00 UTC' AND ordered_at < '2025-01-01 00:00:00 UTC' AND shipped_at IS NOT NULL
GROUP BY month
ORDER BY month
