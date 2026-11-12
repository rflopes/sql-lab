-- 08-03  QUERY
-- Concept: NOT EXISTS
-- Task: Return the categories that have no subcategories and no products.
--       Columns: category_id, name.
-- Run: pnpm check 08-03

-- Write your query below

SELECT c.category_id, c.name
FROM categories c
WHERE NOT EXISTS (SELECT 1 FROM categories sub WHERE sub.parent_id = c.category_id)
  AND NOT EXISTS (SELECT 1 FROM products p WHERE p.category_id = c.category_id);
