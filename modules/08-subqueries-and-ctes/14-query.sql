-- 08-14  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Revenue per top-level category (a category with no parent) in 2025, counting products in that category or in ANY category below it.
--       Revenue of an order line = quantity * unit_price_cents * (1 - discount_pct / 100), where a NULL discount means no discount.
--       Count only orders placed in 2025 (UTC, by ordered_at) whose status is not cancelled or refunded.
--       Return every top-level category, with 0 if it had no revenue.
--       Columns: category_name, revenue_eur (in euros, rounded to 2 decimals). Sorted by category_name.   (ORDER MATTERS)
-- Run: pnpm check 08-14

-- Write your query below


