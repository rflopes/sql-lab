-- 07-02  QUERY
-- Concept: SPLIT_PART
-- Task: Return the domain of every customer's email: the text after the "@", taken from the trimmed, lowercase email.
--       Columns: customer_id, domain.
-- Run: pnpm check 07-02

-- Write your query below

SELECT customer_id, SPLIT_PART(TRIM(LOWER(email)), '@', 2) AS domain
FROM customers
