-- 02-17  PREDICT
-- Concept: What is one row of the result?
-- Task: Read the query, predict how many rows it returns, write the number on the GUESS line, then run the check.
--       Not graded: it trains your intuition. Before guessing, ask: what does ONE row of this result stand for?
-- GUESS: 32
-- Run: pnpm check 02-17

SELECT DISTINCT city, marketing_opt_in
FROM customers
