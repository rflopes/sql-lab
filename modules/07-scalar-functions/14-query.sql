-- 07-14  QUERY  (optional)
-- Concept: jsonb: looking inside an array
-- Task: Some specs list the available colours in an array under "colors". Return the products available in "green".
--       Columns: product_id, name. Sorted by product_id.   (ORDER MATTERS)
-- Run: pnpm check 07-14

-- Write your query below

SELECT ps.product_id, p.name
FROM product_specs ps
JOIN products p ON ps.product_id = p.product_id
WHERE ps.specs ? 'colors' AND ps.specs['colors'] ? 'green'
ORDER BY product_id;
