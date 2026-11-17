-- 10-05  DML
-- Concept: Transactions and savepoints
-- Task: In ONE transaction: raise the price of product 1 by 10% (rounded to whole cents), then delete all reviews of product 1, then take back only the deletion.
--       After the script: the new price is stored and every review is still there.
-- Run: pnpm check 10-05

-- Write your statements below

BEGIN;

UPDATE products SET unit_price_cents = ROUND(unit_price_cents * 1.1, 0) WHERE product_id = 1;

SAVEPOINT before_delete_reviews;

DELETE FROM reviews WHERE product_id = 1;

ROLLBACK TO SAVEPOINT before_delete_reviews;

COMMIT;
