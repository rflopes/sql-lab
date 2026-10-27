-- 01-04  PREDICT
-- Concept: Filtering rows on text
-- Task: Read the query, predict how many rows it returns, write the number on the GUESS line, then run the check.
--       Not graded: it trains your intuition.
-- GUESS: 
-- Run: pnpm check 01-04

SELECT first_name, last_name FROM employees WHERE department = 'Sales';
