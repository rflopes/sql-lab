-- 02-14  DEBUG
-- Concept: Comparing with NULL
-- Symptom: The query runs without errors but returns no rows, although many customers have no city.
-- Task: Fix the query so it returns customers with no city recorded.
--       Columns: customer_id, email.
-- Run: pnpm check 02-14

-- The query below is broken. Fix it.
SELECT customer_id, email FROM customers WHERE city = NULL;
