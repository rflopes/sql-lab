-- 05-06  QUERY
-- Concept: Finding rows with no match, again
-- Task: Return products that have never been ordered.
--       Columns: product_id, name.
-- Run: pnpm check 05-06

-- Write your query below

SELECT p.product_id, p.name as name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
