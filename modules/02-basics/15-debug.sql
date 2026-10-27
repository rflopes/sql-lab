-- 02-15  DEBUG
-- Concept: LIMIT needs an order
-- Symptom: These were supposed to be the 3 cheapest products, but they look arbitrary, and changing nothing in the data can change them.
-- Task: Fix the query: the 3 cheapest products, ties broken by the lower product_id first.
--       Columns: product_id, name, unit_price_cents.   (ORDER MATTERS)
-- Run: pnpm check 02-15

-- The query below is broken. Fix it.
SELECT product_id, name, unit_price_cents FROM products LIMIT 3;
