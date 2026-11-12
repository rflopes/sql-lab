-- 07-11  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Which email providers do our buyers use? For customers who have placed at least one order, take the part of the email after the "@",
--       lowercased and without surrounding spaces, and count the distinct customers per domain.
--       Columns: domain, customers. Sorted by customers (highest first), then domain.   (ORDER MATTERS)
-- Run: pnpm check 07-11

-- Write your query below

SELECT NULLIF(SPLIT_PART(TRIM(LOWER(c.email)), '@', 2), '') AS domain, COUNT(DISTINCT c.customer_id) AS customers
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY NULLIF(SPLIT_PART(TRIM(LOWER(c.email)), '@', 2), '')
ORDER BY customers DESC, domain
