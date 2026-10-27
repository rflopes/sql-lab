-- 09-05  QUERY
-- Concept: LAG
-- Task: For every order: the number of complete 24-hour periods since the same customer's previous order (NULL for their first order). Previous = the one before it when sorted by ordered_at, then order_id.
--       Columns: order_id, customer_id, ordered_at, days_since_prev.
-- Run: pnpm check 09-05

-- Write your query below


