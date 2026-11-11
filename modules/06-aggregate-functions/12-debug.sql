-- 06-12  DEBUG
-- Concept: Aggregates over joins that multiply rows
-- Symptom: The paid amounts are much larger than what customers actually paid; some are multiples of the real value.
-- Task: Fix the query: for orders up to 50 that have payments, the total amount paid.
--       Columns: order_id, paid_cents. Sorted by order_id.   (ORDER MATTERS)
-- Run: pnpm check 06-12

-- The query below is broken. Fix it.
SELECT o.order_id, SUM(p.amount_cents) AS paid_cents
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE o.order_id <= 50
GROUP BY o.order_id
ORDER BY o.order_id;
