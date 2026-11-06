-- 05-14  QUERY
-- Concept: Set difference
-- Task: Return the product_id of every product that has been ordered at least once but has never been reviewed.
--       One column: product_id.
-- Run: pnpm check 05-14

-- Write your query below

SELECT product_id FROM order_items
EXCEPT
SELECT r.product_id FROM reviews r
