-- 02-03  QUERY
-- Concept: Aliases and expressions
-- Task: Return each product with its price in euros (not cents), as a decimal number: 12950 cents is 129.50.
--       Columns: sku, name, price_eur.
-- Run: pnpm check 02-03

-- Write your query below

SELECT sku, name, (unit_price_cents / 100) AS price_eur
FROM products
