-- 04-12  DDL
-- Concept: Foreign keys: what happens on delete
-- Task: Create a table supplier_contacts:
--         contact_id   integer, generated always as identity, primary key
--         supplier_id  integer, required, must refer to an existing supplier
--         name         text, required
--         phone        text, optional
--       Contacts only make sense with their supplier: when a supplier is deleted, the database itself must delete that supplier's contacts.
-- Run: pnpm check 04-12

-- Write your statements below


