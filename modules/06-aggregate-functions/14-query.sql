-- 06-14  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Which categories reached many different people in 2025? For each category, count the distinct customers who placed an order
--       in 2025 (UTC, by ordered_at, any status) containing at least one product of that category (the product's own category, not its parents).
--       Keep only categories with at least 20 such customers.
--       Columns: category_name, customers. Sorted by customers (highest first), then category_name.   (ORDER MATTERS)
-- Run: pnpm check 06-14

-- Write your query below

SELECT c.name AS category_name, COUNT(DISTINCT customer_id) AS customers
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.ordered_at >= '2025-01-01 00:00:00 UTC' AND o.ordered_at < '2026-01-01 00:00:00 UTC'
GROUP BY c.category_id
HAVING COUNT(DISTINCT customer_id) >= 20
ORDER BY customers DESC, category_name
