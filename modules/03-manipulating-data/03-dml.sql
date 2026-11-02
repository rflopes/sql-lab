-- 03-03  DML
-- Concept: INSERT several rows, RETURNING
-- Task: Insert two categories whose parent is the existing category named "Navigation": "Compasses" and "GPS Devices", in one statement.
--       The same statement must return the generated category_id and the name of the new rows (columns category_id, name).
-- Run: pnpm check 03-03

-- Write your statements below

-- INSERT INTO categories (name, parent_id) VALUES
--  ('Compasses', (SELECT category_id FROM categories WHERE name = 'Navigation')),
--  ('GPS Devices', (SELECT category_id FROM categories WHERE name = 'Navigation'))
-- RETURNING category_id, name

INSERT INTO categories (name, parent_id)
SELECT v.name, (SELECT category_id FROM categories WHERE name = 'Navigation')
FROM (VALUES ('Compasses'), ('GPS Devices')) as v(name)
RETURNING category_id, name
