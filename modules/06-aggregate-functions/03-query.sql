-- 06-03  QUERY
-- Concept: COUNT(*) versus COUNT(column)
-- Task: One row with: the number of products, how many of them have a weight recorded, and how many have a supplier.
--       Columns: total_products, with_weight, with_supplier.
-- Run: pnpm check 06-03

-- Write your query below

SELECT COUNT(*) AS total_products, COUNT(weight_kg) AS with_weight, COUNT(supplier_id) AS with_supplier
FROM products;
