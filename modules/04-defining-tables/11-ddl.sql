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

BEGIN;

CREATE TABLE tags (
  tag_id        integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name          text NOT NULL UNIQUE
);

CREATE TABLE product_tags (
  product_id    integer,
  tag_id        integer,

  PRIMARY KEY (product_id, tag_id),

  CONSTRAINT product_tags_fk_tag FOREIGN KEY (tag_id) REFERENCES tags(tag_id),
  CONSTRAINT product_tags_fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

COMMIT;
