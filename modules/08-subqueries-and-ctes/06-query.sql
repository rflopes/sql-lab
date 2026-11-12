-- 08-06  QUERY
-- Concept: Subquery in FROM
-- Task: What is the average number of orders per customer, counting only customers who ordered at least once? Round to 2 decimals.
--       One column: avg_orders_per_customer.
-- Run: pnpm check 08-06

-- Write your query below

SELECT ROUND(AVG(orders_count), 2) AS avg_orders_per_customer
FROM (
  SELECT o.customer_id, COUNT(*) AS orders_count
  FROM orders o
  GROUP BY o.customer_id
) AS orders_by_customer
