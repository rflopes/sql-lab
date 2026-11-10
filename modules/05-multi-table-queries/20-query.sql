-- 05-20  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Marketing wants to know how far referrals travel. List every customer who was referred by a customer living in a different city.
--       Leave out pairs where either customer has no city recorded.
--       Columns: customer_id, city, referrer_city. Sorted by customer_id.   (ORDER MATTERS)
-- Run: pnpm check 05-20

-- Write your query below

SELECT c.customer_id, c.city, r.city as referrer_city
FROM customers c
JOIN customers r ON c.referred_by = r.customer_id
WHERE c.city != r.city
ORDER BY c.customer_id
