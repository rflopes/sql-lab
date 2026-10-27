-- 05-19  PREDICT
-- Concept: How joins change the number of rows
-- Task: Customer 12 placed 2 orders. Read the query, predict how many rows it returns, write the number on the GUESS line, then run the check.
--       Not graded. Use pnpm sql to look at that customer's order items and payments afterwards, and explain the number to yourself.
-- GUESS: 
-- Run: pnpm check 05-19

SELECT o.order_id
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN payments p ON p.order_id = o.order_id
WHERE o.customer_id = 12;
