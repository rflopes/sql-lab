-- 07-09  QUERY
-- Concept: CASE
-- Task: Classify each product by price: "budget" under 5000 cents, "mid" from 5000 to 14999, "premium" from 15000 up.
--       Columns: product_id, price_band.
-- Run: pnpm check 07-09

-- Write your query below

SELECT product_id,
  CASE WHEN unit_price_cents < 5000 THEN 'budget'
    WHEN unit_price_cents < 15000 THEN 'mid'
    ELSE 'premium'
  END AS price_band
FROM products

-- option 1: every band explicit, no ELSE
-- CASE WHEN unit_price_cents < 5000  THEN 'budget'
--      WHEN unit_price_cents < 15000 THEN 'mid'
--      WHEN unit_price_cents >= 15000 THEN 'premium'
-- END                                   -- NULL price gives NULL (CASE with no ELSE)

-- -- option 2: handle NULL explicitly, first
-- CASE WHEN unit_price_cents IS NULL THEN 'unknown'
--      WHEN unit_price_cents < 5000  THEN 'budget'
--      WHEN unit_price_cents < 15000 THEN 'mid'
--      ELSE 'premium'
-- END
