-- 06-11  DEBUG
-- Concept: Columns that are not grouped
-- Symptom: PostgreSQL complains about a column that must appear in the GROUP BY clause or be used in an aggregate.
-- Task: Fix the query: the number of products in each category.
--       Columns: category_id, product_count.
-- Run: pnpm check 06-11

-- The query below is broken. Fix it.
SELECT category_id, COUNT(*) AS product_count
FROM products
GROUP BY category_id;
