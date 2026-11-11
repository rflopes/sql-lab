-- 07-01  QUERY
-- Concept: TRIM, LOWER
-- Task: Find customers whose stored email is not clean, meaning it differs from its trimmed, lowercase form. Show both.
--       Columns: customer_id, email, clean_email. Only rows where clean_email differs from email.
-- Run: pnpm check 07-01

-- Write your query below

SELECT customer_id, email, TRIM(LOWER(email)) AS clean_email
FROM customers
WHERE email != TRIM(LOWER(email))
