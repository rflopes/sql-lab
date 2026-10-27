-- 04-11  DDL
-- Concept: Many-to-many relationships, composite keys
-- Task: Products need free-form tags ("ultralight", "vegan", ...). A product can have many tags and a tag can be on many products.
--       Create a table tags:
--         tag_id  integer, generated always as identity, primary key
--         name    text, required, no two tags with the same name
--       and a table product_tags that links them, with exactly two columns, product_id and tag_id:
--         both required, each must refer to an existing row, and the same tag cannot be put on the same product twice.
-- Run: pnpm check 04-11

-- Write your statements below


