-- 09-03  QUERY
-- Concept: RANK and DENSE_RANK
-- Task: Rank products within their category by price, most expensive first: once with RANK and once with DENSE_RANK. Equal prices get equal ranks.
--       Columns: product_id, category_id, unit_price_cents, rnk, dense_rnk.
-- Run: pnpm check 09-03

-- Write your query below

SELECT product_id, category_id, unit_price_cents,
  RANK() OVER (PARTITION BY category_id ORDER BY unit_price_cents DESC) AS rnk,
  DENSE_RANK() OVER (PARTITION BY category_id ORDER BY unit_price_cents DESC) AS dense_rnk
FROM products
