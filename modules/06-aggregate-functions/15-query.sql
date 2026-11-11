-- 06-15  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Finance report for payments made in 2024 (UTC, by paid_at). For each payment method return:
--         total_eur                the sum of the amounts, in euros (12950 cents is 129.50)
--         payments_on_lost_orders  how many of those payments belong to an order whose status is now cancelled or refunded
--       Columns: method, total_eur, payments_on_lost_orders.
-- Run: pnpm check 06-15

-- Write your query below

SELECT method, round(SUM(p.amount_cents) / 100.0, 2) AS total_eur, COUNT(*) FILTER (WHERE o.status IN ('refunded', 'cancelled')) as payments_on_lost_orders
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE p.paid_at >= '2024-01-01 00:00:00 UTC' AND p.paid_at < '2025-01-01 00:00:00 UTC'
GROUP BY p.method
