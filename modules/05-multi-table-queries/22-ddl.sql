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


