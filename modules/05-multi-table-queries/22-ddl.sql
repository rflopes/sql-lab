-- 05-22  DDL
-- Concept: Normalisation: moving repeated text into its own table
-- Task: Customer cities are stored as repeated text. Move them into their own table:
--         1. Create a table cities: city_id (integer, generated always as identity, primary key) and name (text, required, unique).
--         2. Fill it with every distinct city that appears in customers (one row per city, no NULL).
--         3. Give customers a column city_id that refers to cities, set so each customer points to the city it had.
--            Customers without a city keep city_id NULL.
--         4. Remove the old text column city from customers.
-- Run: pnpm check 05-22

-- Write your statements below

CREATE TABLE cities (
  city_id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name         text NOT NULL UNIQUE
);

INSERT INTO cities(name)
SELECT DISTINCT city FROM customers WHERE city IS NOT NULL;

ALTER TABLE customers ADD COLUMN city_id integer REFERENCES cities (city_id) ON DELETE SET NULL;
UPDATE customers SET city_id = (SELECT ct.city_id FROM cities ct WHERE ct.name = customers.city);

ALTER TABLE customers DROP COLUMN city;
