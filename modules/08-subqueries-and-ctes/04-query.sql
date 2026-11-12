-- 08-04  QUERY
-- Concept: Correlated subquery
-- Task: Return the products priced above the average price of their own category, with that average (rounded to 2 decimals).
--       Columns: product_id, name, unit_price_cents, category_avg_cents.
-- Run: pnpm check 08-04

-- Write your query below

-- SELECT p.product_id, p.name, p.unit_price_cents, (SELECT ROUND(AVG(sub.unit_price_cents), 2) FROM products sub WHERE sub.category_id = p.category_id) AS category_avg_cents
-- FROM products p
-- WHERE unit_price_cents > (SELECT AVG(sub.unit_price_cents) FROM products sub WHERE sub.category_id = p.category_id)


SELECT product_id, name, unit_price_cents, ROUND(products_avg, 2) AS category_avg_cents
FROM (
  SELECT p.*, (SELECT AVG(sub.unit_price_cents) FROM products sub WHERE sub.category_id = p.category_id) AS products_avg FROM products p
) AS p_avg
WHERE unit_price_cents > products_avg
