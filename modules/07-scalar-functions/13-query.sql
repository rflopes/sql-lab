-- 07-13  QUERY  (optional)
-- Concept: jsonb: reading a key
-- Task: The table product_specs keeps extra details per product as jsonb. Return every product whose specs contain the key "season",
--       with the season as text.
--       Columns: product_id, name, season. Sorted by product_id.   (ORDER MATTERS)
-- Run: pnpm check 07-13

-- Write your query below

SELECT ps.product_id, p.name, ps.specs->>'season' AS season
FROM product_specs ps
JOIN products p ON ps.product_id = p.product_id
WHERE ps.specs ? 'season'
ORDER BY product_id;
