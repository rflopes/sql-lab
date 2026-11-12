-- 07-06  QUERY
-- Concept: EXTRACT and TO_CHAR
-- Task: For orders with order_id from 100 to 130: the weekday as a 3-letter English abbreviation (Mon, Tue, ...) and the hour of the day (0 to 23), in UTC.
--       Columns: order_id, weekday, hour.
-- Run: pnpm check 07-06

-- Write your query below

SELECT order_id, TO_CHAR(ordered_at, 'Dy') AS weekday, EXTRACT(HOUR FROM ordered_at) AS hour
FROM orders
WHERE order_id BETWEEN 100 AND 130;
