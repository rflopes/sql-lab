-- 06-13  PREDICT
-- Concept: What is one row of a grouped result?
-- Task: 244 customers have placed at least one order. Read the query, predict whether it returns fewer, exactly 244, or more rows,
--       then write your best number on the GUESS line and run the check. Not graded.
-- GUESS: 
-- Run: pnpm check 06-13

SELECT customer_id, status, count(*) AS orders
FROM orders
GROUP BY customer_id, status;
