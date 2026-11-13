-- 08-09  QUERY
-- Concept: Recursive CTE: paths
-- Task: For every category, build its path from the top: names from the root down to the category, separated by " > " (for example: Camping > Tents).
--       Columns: category_id, path. A top-level category's path is just its name.
-- Run: pnpm check 08-09

-- Write your query below

WITH RECURSIVE category_path AS (
  SELECT category_id, name AS path FROM categories WHERE parent_id IS NULL
  UNION ALL
  SELECT c.category_id, concat_ws(' > ', p.path, c.name)
  FROM categories c JOIN category_path p ON c.parent_id = p.category_id
)
SELECT * FROM category_path;
