-- 04-10  DDL
-- Concept: DROP
-- Task: Remove the table reviews completely, and remove the column weight_kg from products.
-- Run: pnpm check 04-10

-- Write your statements below

BEGIN;
  DROP TABLE reviews;
  ALTER TABLE products DROP COLUMN weight_kg;
COMMIT;
