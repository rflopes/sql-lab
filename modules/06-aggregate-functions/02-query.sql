-- 06-02  QUERY
-- Concept: MIN, MAX, AVG
-- Task: One row with the lowest, highest and average product price in cents. Round the average to 2 decimals.
--       Columns: min_price, max_price, avg_price.
-- Run: pnpm check 06-02

-- Write your query below

SELECT MIN(unit_price_cents) AS min_price, MAX(unit_price_cents) AS max_price,  round(AVG(unit_price_cents), 2) AS avg_price
FROM products
