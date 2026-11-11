-- 07-03  QUERY
-- Concept: Concatenation and NULL
-- Task: For each customer return one contact text: the non-NULL values among city and phone, joined with " / ". If only one exists there is no separator; if neither exists the result is an empty string (not NULL).
--       Columns: customer_id, contact.
-- Run: pnpm check 07-03

-- Write your query below
SELECT customer_id, CONCAT_WS(' / ',city, phone) AS contact
FROM customers
