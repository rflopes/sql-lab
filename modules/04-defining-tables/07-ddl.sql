-- 04-07  DDL
-- Concept: Foreign keys and UNIQUE
-- Task: Create a table wishlists with:
--         wishlist_id  integer, generated always as identity, primary key
--         customer_id  integer, required, must refer to an existing customer
--         product_id   integer, required, must refer to an existing product
--         added_at     timestamp with time zone, required, default now()
--       A customer cannot have the same product twice on the list.
-- Run: pnpm check 04-07

-- Write your statements below


