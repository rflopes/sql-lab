-- 08-05  QUERY
-- Concept: EXISTS
-- Task: Return the customers who have paid at least one order by "transfer". Each customer once.
--       Columns: customer_id, email.
-- Run: pnpm check 08-05

-- Write your query below

SELECT c.customer_id, c.email
FROM customers c
WHERE EXISTS (
  SELECT 1
  FROM orders o
  JOIN payments p ON o.order_id = p.order_id
  WHERE o.customer_id = c.customer_id AND p.method = 'transfer'
)
