-- 07-04  QUERY
-- Concept: Numeric functions
-- Task: For products with a known weight: the weight in grams (whole number, rounded) and the number of 2.5 kg boxes needed to ship one unit (round up to a whole number of boxes).
--       Columns: product_id, weight_g, boxes.
-- Run: pnpm check 07-04

-- Write your query below

SELECT product_id, round(weight_kg * 1000) AS weight_g, ceil(weight_kg / 2.5)AS boxes
FROM products
WHERE weight_kg IS NOT NULL
