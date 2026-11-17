-- 09-10  QUERY
-- Concept: FIRST_VALUE
-- Task: For each product, also show the name of the cheapest product in its category. If several share the lowest price, the one with the lower product_id counts.
--       Columns: product_id, category_id, name, cheapest_in_category.
-- Run: pnpm check 09-10

-- Write your query below

SELECT product_id, category_id, name,
  FIRST_VALUE(name) OVER (PARTITION BY category_id ORDER BY unit_price_cents, product_id) AS cheapest_in_category
FROM products
