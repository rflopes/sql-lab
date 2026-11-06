-- 05-08  QUERY
-- Concept: Self join on customers
-- Task: Return the customers who were referred by another customer, together with the email of whoever referred them.
--       Columns: customer_id, referrer_email.
-- Run: pnpm check 05-08

-- Write your query below
SELECT c.customer_id, r.email AS referrer_email
FROM customers c
JOIN customers r ON r.customer_id = c.referred_by
