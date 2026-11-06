-- 05-18  DEBUG
-- Concept: Joins that multiply rows
-- Symptom: Each paid order shows up several times. It should appear exactly once.
-- Task: Fix the query: paid orders, each one exactly once.
--       Columns: order_id, status.
-- Run: pnpm check 05-18

-- The query below is broken. Fix it.
SELECT o.order_id, o.status
FROM orders o
WHERE o.status = 'paid';
