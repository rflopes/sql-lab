-- 08-13  QUERY
-- Concept: (not given: choosing the approach is part of the exercise)
-- Task: Bad first impressions: list the customers whose very first order (earliest ordered_at) is currently cancelled.
--       Columns: customer_id, first_order_id. Sorted by customer_id.   (ORDER MATTERS)
-- Run: pnpm check 08-13

-- Write your query below

-- 1 & 2: In case a customer has 2 orders placed at the same timestamp this will return 2 rows for said customer
-- 3, 4 & 5: break the tie with order_id (lowest wins), so each customer always gets exactly one row
-- 1.
WITH customer_first_order AS (
  SELECT o.customer_id, o.order_id, o.status
  FROM orders o
  WHERE o.ordered_at = (SELECT MIN(sub.ordered_at) FROM orders sub WHERE sub.customer_id = o.customer_id)
)
SELECT customer_id, order_id AS first_order_id
FROM customer_first_order
WHERE status = 'cancelled'
ORDER BY customer_id;

-- 2.
-- SELECT o.customer_id, o.order_id AS first_order_id
-- FROM orders o
-- WHERE o.ordered_at = (SELECT MIN(sub.ordered_at) FROM orders sub WHERE sub.customer_id = o.customer_id)
--   AND o.status = 'cancelled'
-- ORDER BY customer_id;

-- 3.
-- WITH customer_first_order AS (
--   SELECT DISTINCT ON (o.customer_id) o.customer_id, o.order_id, o.status
--   FROM orders o
--   ORDER BY o.customer_id, o.ordered_at, o.order_id
-- )
-- SELECT customer_id, order_id AS first_order_id
-- FROM customer_first_order
-- WHERE status = 'cancelled'
-- ORDER BY customer_id;

-- 4.
-- WITH customer_first_order AS (
--   SELECT o.customer_id, o.order_id, o.status
--   FROM orders o
--   WHERE o.order_id = (
--     SELECT sub.order_id FROM orders sub
--     WHERE sub.customer_id = o.customer_id
--     ORDER BY sub.ordered_at, sub.order_id
--     LIMIT 1
--   )
-- )
-- SELECT customer_id, order_id AS first_order_id
-- FROM customer_first_order
-- WHERE status = 'cancelled'
-- ORDER BY customer_id;

-- 5.
-- SELECT o.customer_id, o.order_id AS first_order_id
-- FROM orders o
-- WHERE o.order_id = (
--   SELECT sub.order_id FROM orders sub
--   WHERE sub.customer_id = o.customer_id
--   ORDER BY sub.ordered_at, sub.order_id
--   LIMIT 1
-- ) AND o.status = 'cancelled'
-- ORDER BY o.customer_id;
