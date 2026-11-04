-- 04-08  DDL
-- Concept: TRUNCATE and identity reset
-- Task: Remove every row from payments but keep the table. The next payment inserted afterwards must get payment_id 1.
-- Run: pnpm check 04-08

-- Write your statements below

TRUNCATE payments RESTART IDENTITY;
