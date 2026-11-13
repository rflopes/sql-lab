-- 08-11  DEBUG
-- Concept: NOT IN and NULL
-- Symptom: The query returns no rows at all, but plenty of customers have never referred anyone.
-- Task: Fix the query: customers who have not referred any other customer.
--       Columns: customer_id, email.
-- Run: pnpm check 08-11

-- The query below is broken. Fix it.
SELECT customer_id, email
FROM customers
WHERE customer_id NOT IN (SELECT referred_by FROM customers WHERE referred_by IS NOT NULL);

-- SELECT c.customer_id, c.email
-- FROM customers c
-- WHERE NOT EXISTS (SELECT 1 FROM customers sub WHERE sub.referred_by = c.customer_id);
