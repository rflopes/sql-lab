-- 07-08  QUERY
-- Concept: Casting text to numbers
-- Task: Every sku looks like "TNT-0001". Return the numeric part as an integer.
--       Columns: product_id, sku, sku_number.
-- Run: pnpm check 07-08

-- Write your query below

SELECT product_id, sku, CAST(NULLIF(SPLIT_PART(sku, '-', 2), '') AS integer) AS sku_number
FROM products
