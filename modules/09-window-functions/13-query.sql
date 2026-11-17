-- 09-13  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Which customers went quiet the longest? For each customer, look at the dates (UTC) of their orders in time order and find the largest number
--       of days between one order and the next. Customers with a single order have no gap and are left out.
--       Return the 10 customers with the largest gap.
--       Columns: customer_id, max_gap_days (a whole number of days). Sorted by max_gap_days (highest first), then customer_id.   (ORDER MATTERS)
-- Run: pnpm check 09-13

-- Write your query below

WITH customer_order_distance AS (
  SELECT customer_id,
    (ordered_at AT TIME ZONE 'UTC')::date  - (LAG((ordered_at AT TIME ZONE 'UTC')::date) OVER (PARTITION BY customer_id ORDER BY ordered_at, order_id)) AS days_since_prev
  FROM orders
)
SELECT customer_id, MAX(days_since_prev) AS max_gap_days
FROM customer_order_distance
WHERE days_since_prev IS NOT NULL
GROUP BY customer_id
ORDER BY 2 DESC, customer_id
LIMIT 10
