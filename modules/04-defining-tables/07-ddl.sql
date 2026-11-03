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
CREATE TABLE wishlists (
  wishlist_id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id       integer NOT NULL,
  product_id        integer NOT NULL,
  added_at          timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT wishlists_fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT wishlists_fk_product FOREIGN KEY (product_id) REFERENCES products(product_id),

  CONSTRAINT wishlists_customer_products_key UNIQUE (customer_id, product_id)
)
