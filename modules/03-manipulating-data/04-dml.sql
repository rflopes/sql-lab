-- 03-04  DML
-- Concept: UPDATE with an expression
-- Task: Cut the price of every product in category 22 by 12.5%. Store the new price as whole cents, rounded to the nearest cent (halves round up).
--       Products in other categories must not change.
-- Run: pnpm check 03-04

-- Write your statements below
UPDATE products SET unit_price_cents = round(unit_price_cents * 0.875)
WHERE category_id = 22
