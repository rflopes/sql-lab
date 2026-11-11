-- 06-05  QUERY
-- Concept: GROUP BY with a join
-- Task: For each category that has products directly in it: the category name, the number of products and their average price in cents (rounded to 2 decimals).
--       Columns: category_name, product_count, avg_price_cents.
-- Run: pnpm check 06-05

-- Write your query below

SELECT categories.name AS category_name, COUNT(*) AS product_count, round(AVG(products.unit_price_cents), 2 ) AS avg_price_cents
FROM products, categories
WHERE products.category_id = categories.category_id
GROUP BY categories.name
