-- 05-10  QUERY
-- Concept: Joining a table to itself through a link
-- Task: Return every product with the name of its category and the name of that category's parent category (NULL when the category has no parent).
--       Columns: product_id, category_name, parent_category_name.
-- Run: pnpm check 05-10

-- Write your query below

SELECT p.product_id, c.name AS category_name, pc.name AS parent_category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN categories pc ON c.parent_id = pc.category_id
