-- 04-04  DDL
-- Concept: CHECK, NOT NULL, text primary key
-- Task: Create a table coupons with:
--         code          text, primary key
--         discount_pct  numeric(5,2), required, and the database must reject values below 0 or above 100
--         valid_until   date, optional
-- Run: pnpm check 04-04

-- Write your statements below
CREATE TABLE coupons (
  code            text PRIMARY KEY,
  discount_pct    numeric(5,2) NOT NULL CONSTRAINT coupons_discount_pct_range CHECK (discount_pct BETWEEN 0 AND 100),
  valid_until     date
);
