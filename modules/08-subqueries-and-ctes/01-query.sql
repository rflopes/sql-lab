-- 08-01  QUERY
-- Concept: Scalar subquery
-- Task: Return the products whose price is above the average price of all products.
--       Columns: product_id, name, unit_price_cents.
-- Run: pnpm check 08-01

-- Write your query below

SELECT product_id, name, unit_price_cents
FROM products
WHERE unit_price_cents > (SELECT AVG(unit_price_cents) FROM products)
