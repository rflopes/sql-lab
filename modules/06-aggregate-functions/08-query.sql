-- 06-08  QUERY
-- Concept: FILTER
-- Task: For each payment method: how many payments there are, and how many of them are for 20000 cents or more.
--       Columns: method, payment_count, large_count.
-- Run: pnpm check 06-08

-- Write your query below

SELECT payments.method, COUNT(*) AS payment_count, COUNT(*) FILTER (WHERE amount_cents >= 20000) AS large_count
FROM payments
GROUP BY payments.method
