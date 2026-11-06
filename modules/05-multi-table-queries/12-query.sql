-- 05-12  QUERY
-- Concept: All combinations
-- Task: Return every combination of a supplier with a top-level category (a category that has no parent).
--       Columns: supplier_name, category_name.
-- Run: pnpm check 05-12

-- Write your query below

SELECT s.name AS supplier_name, c.name AS category_name
FROM suppliers s
CROSS JOIN categories c
WHERE c.parent_id IS NULL
