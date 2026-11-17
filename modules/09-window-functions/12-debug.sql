-- 09-12  DEBUG
-- Concept: ROW_NUMBER versus RANK on ties
-- Symptom: Some categories have two products tied for the lowest price, but only one of them shows up.
-- Task: Fix the query: for each category, its cheapest product(s). When several tie for the lowest price, all of them must appear.
--       Columns: product_id, category_id, unit_price_cents.
-- Run: pnpm check 09-12

-- The query below is broken. Fix it.
SELECT product_id, category_id, unit_price_cents
FROM (
  SELECT product_id, category_id, unit_price_cents,
         RANK() OVER (PARTITION BY category_id ORDER BY unit_price_cents) AS rnk
  FROM products
) t
WHERE rnk = 1;
