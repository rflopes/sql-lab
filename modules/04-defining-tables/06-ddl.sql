-- 04-06  DDL
-- Concept: ADD COLUMN with NOT NULL and DEFAULT
-- Task: Add a required integer column loyalty_points to customers, with default 0. Every existing customer must end up with 0.
-- Run: pnpm check 04-06

-- Write your statements below
ALTER TABLE customers ADD COLUMN loyalty_points integer NOT NULL DEFAULT 0
