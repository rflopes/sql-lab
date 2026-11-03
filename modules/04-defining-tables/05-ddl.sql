-- 04-05  DDL
-- Concept: ALTER TABLE ... ADD CONSTRAINT
-- Task: Make the database reject any customer whose email does not contain an "@". Existing rows are already fine.
-- Run: pnpm check 04-05

-- Write your statements below
ALTER TABLE customers ADD CONSTRAINT customers_valid_email CHECK (email LIKE '%@%')
