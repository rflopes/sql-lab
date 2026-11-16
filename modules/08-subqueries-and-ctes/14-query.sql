-- 08-14  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Revenue per top-level category (a category with no parent) in 2025, counting products in that category or in ANY category below it.
--       Revenue of an order line = quantity * unit_price_cents * (1 - discount_pct / 100), where a NULL discount means no discount.
--       Count only orders placed in 2025 (UTC, by ordered_at) whose status is not cancelled or refunded.
--       Return every top-level category, with 0 if it had no revenue.
--       Columns: category_name, revenue_eur (in euros, rounded to 2 decimals). Sorted by category_name.   (ORDER MATTERS)
-- Run: pnpm check 08-14

-- Write your query below

WITH RECURSIVE category_path AS (
  SELECT t.category_id AS top_category_id, t.category_id FROM categories t WHERE parent_id IS NULL
  UNION ALL
  SELECT p.top_category_id, c.category_id
  FROM categories c JOIN category_path p ON c.parent_id = p.category_id
),
line_revenue AS (
  SELECT cp.top_category_id, oi.quantity * (oi.unit_price_cents - (oi.unit_price_cents * COALESCE(oi.discount_pct, 0) / 100)) AS revenue_cents
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  JOIN products p ON oi.product_id = p.product_id
  JOIN category_path cp ON p.category_id = cp.category_id
  WHERE o.ordered_at >= '2025-01-01 00:00:00 UTC' AND ordered_at < '2026-01-01 00:00:00 UTC' AND o.status NOT IN ('cancelled', 'refunded')
)
SELECT c.name AS category_name, ROUND(COALESCE(SUM(lr.revenue_cents) / 100, 0), 2) AS revenue_eur
FROM categories c
LEFT JOIN line_revenue lr ON lr.top_category_id = c.category_id
WHERE c.parent_id IS NULL
GROUP BY c.category_id, c.name
ORDER BY 1
