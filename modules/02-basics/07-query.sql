-- 02-07  QUERY
-- Concept: Pattern matching and case
-- Task: Return products whose name contains the text "jacket", in any capitalisation.
--       Columns: product_id, name. Sorted by product_id.   (ORDER MATTERS)
-- Run: pnpm check 02-07

-- Write your query below
SELECT product_id, name
FROM products
WHERE name ILIKE '%jacket%'
ORDER BY product_id
