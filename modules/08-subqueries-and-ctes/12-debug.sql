-- 08-12  DEBUG
-- Concept: Subquery returning several rows
-- Symptom: PostgreSQL reports an error about a subquery used as an expression.
-- Task: Fix the query: products priced at least as much as the most expensive product of category 18.
--       Columns: product_id, name, unit_price_cents.
-- Run: pnpm check 08-12

-- The query below is broken. Fix it.
SELECT product_id, name, unit_price_cents
FROM products
WHERE unit_price_cents >= (SELECT MAX(unit_price_cents) FROM products WHERE category_id = 18);
