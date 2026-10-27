-- 01-03  PREDICT
-- Concept: Filtering rows
-- Task: Read the query, predict how many rows it returns, write the number on the GUESS line, then run the check.
--       Not graded: it trains your intuition. Use pnpm sql to explore if you like.
-- GUESS: 
-- Run: pnpm check 01-03

SELECT * FROM products WHERE unit_price_cents > 10000;
