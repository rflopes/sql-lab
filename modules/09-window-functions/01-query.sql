-- 09-01  QUERY
-- Concept: ROW_NUMBER
-- Task: Number the categories 1, 2, 3... in alphabetical order of name.
--       Columns: category_id, name, row_num.
-- Run: pnpm check 09-01

-- Write your query below


SELECT category_id, name, ROW_NUMBER() OVER (ORDER BY name) AS row_num
FROM categories
