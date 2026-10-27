-- 04-03  DDL
-- Concept: Types, defaults, composite primary key
-- Task: Create a table stock_levels with:
--         warehouse_id  integer, required
--         product_id    integer, required
--         quantity      bigint, required, default 0
--         reserved      numeric with 8 digits in total and 2 after the point, required, default 0
--         active        boolean, required, default true
--         last_counted  date, optional
--         updated_at    timestamp with time zone, required, default now()
--       The primary key is the pair (warehouse_id, product_id).
-- Run: pnpm check 04-03

-- Write your statements below


