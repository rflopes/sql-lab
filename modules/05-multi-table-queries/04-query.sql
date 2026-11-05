-- 05-04  QUERY
-- Concept: Keeping rows without a match
-- Task: Return every product with its supplier name. Products without a supplier must still appear, with a NULL supplier name.
--       Columns: product_id, product_name, supplier_name.
-- Run: pnpm check 05-04

-- Write your query below
SELECT p.product_id as product_id, p.name as product_name, s.name as supplier_name
FROM products p
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
