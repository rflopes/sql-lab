-- 03-05  DML
-- Concept: DELETE
-- Task: Delete the reviews that have a rating of 1 and no text (body is NULL). Keep every other review.
-- Run: pnpm check 03-05

-- Write your statements below

DELETE FROM reviews
WHERE rating = 1 AND body IS NULL
