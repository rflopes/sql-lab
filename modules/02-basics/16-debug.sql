-- 02-16  DEBUG
-- Concept: Reading an error message
-- Symptom: PostgreSQL reports an error. Read the message and the position marker carefully.
-- Task: Fix the query: products priced above 100 euros.
--       Columns: name, price_eur.
-- Run: pnpm check 02-16

-- The query below is broken. Fix it.
SELECT name, unit_price_cents / 100.0 AS price_eur
FROM products
WHERE price_eur > 100;
