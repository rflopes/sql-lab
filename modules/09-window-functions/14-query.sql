-- 09-14  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Best seller per category in 2025: for each category (the product's own category), the product with the most units sold
--       (sum of quantity) in orders placed in 2025 (UTC, by ordered_at, any status). On a tie, pick the lower product_id.
--       Categories with no sales in 2025 are left out.
--       Columns: category_id, product_id, units. Sorted by category_id.   (ORDER MATTERS)
-- Run: pnpm check 09-14

-- Write your query below


