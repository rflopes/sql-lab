-- 05-21  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: We want to ask recent buyers for a first review. List the customers who placed at least one order in December 2024
--       (UTC, by ordered_at, any order status) and have never written a review of any product.
--       Columns: customer_id, email (as stored). One row per customer. Sorted by customer_id.   (ORDER MATTERS)
-- Run: pnpm check 05-21

-- Write your query below

(
  SELECT c.customer_id, c.email
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  WHERE o.ordered_at  >= '2024-12-01 00:00:00 UTC' AND ordered_at < '2025-01-01 00:00:00 UTC'
)
EXCEPT
(
  SELECT c.customer_id, c.email
  FROM customers c
  JOIN reviews r ON c.customer_id = r.customer_id
)
ORDER BY customer_id
