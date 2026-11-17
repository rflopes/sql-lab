-- 10-03  DDL
-- Concept: CREATE INDEX
-- Task: Make lookups of page_views by customer_id able to use an index: create one on that column.
-- Run: pnpm check 10-03

-- Write your statements below

-- Omitting the index name makes it use the default <table>_<column>_idx
CREATE INDEX page_views_customer_id_idx ON page_views (customer_id);
-- Use CONCURRENTLY on production so that creating an index does not block
-- writing on the table. It cannot run inside a transaction and if an index creation
-- fails mid-creation the index is left as INVALID and must be manually removed and
-- created again
-- CREATE INDEX CONCURRENTLY page_views_customer_id_idx ON page_views (customer_id)
