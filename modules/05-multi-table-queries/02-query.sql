-- 05-02  QUERY
-- Concept: Joining with aliases
-- Task: Return every product together with the name of its category.
--       Columns: product_name, category_name.
-- Run: pnpm check 05-02

-- Write your query below

SELECT p.name as product_name, c.name as category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id
