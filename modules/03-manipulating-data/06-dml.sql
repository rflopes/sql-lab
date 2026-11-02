-- 03-06  DML
-- Concept: ON CONFLICT (upsert)
-- Task: In ONE statement, write these two products into products:
--         sku "TNT-0001", name "Ridge 1P Tent v2", category_id 16, unit_price_cents 21000
--         sku "NEW-0001", name "Trail Towel", category_id 15, unit_price_cents 1500
--       A product with sku "TNT-0001" already exists: for it, update name and unit_price_cents instead of inserting a duplicate. All other columns keep their values.
-- Run: pnpm check 03-06

-- Write your statements below

INSERT INTO products(sku, name, category_id, unit_price_cents)
VALUES ('TNT-0001', 'Ridge 1P Tent v2', 16, 21000),
('NEW-0001', 'Trail Towel', 15, 1500)
ON CONFLICT (sku) DO UPDATE SET
  name = EXCLUDED.name,
  unit_price_cents = EXCLUDED.unit_price_cents;
