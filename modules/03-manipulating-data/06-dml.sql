-- 03-06  DML
-- Concept: ON CONFLICT (upsert)
-- Task: In ONE statement, write these two products into products:
--         sku "TNT-0001", name "Ridge 1P Tent v2", category_id 16, unit_price_cents 21000
--         sku "NEW-0001", name "Trail Towel", category_id 15, unit_price_cents 1500
--       A product with sku "TNT-0001" already exists: for it, update name and unit_price_cents instead of inserting a duplicate. All other columns keep their values.
-- Run: pnpm check 03-06

-- Write your statements below


