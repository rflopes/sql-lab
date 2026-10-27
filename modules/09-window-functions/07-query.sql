-- 09-07  QUERY
-- Concept: Running totals
-- Task: Monthly revenue and its running total. Revenue = sum of quantity * unit_price_cents over the lines of orders whose status is not 'cancelled', grouped by the month of ordered_at (UTC). The running total adds up the months so far, in month order.
--       Columns: month (first day of the month, as a date), revenue_cents, running_cents.
-- Run: pnpm check 09-07

-- Write your query below


