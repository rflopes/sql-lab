-- 02-02  QUERY
-- Concept: WHERE with a single value
-- Task: Return the first name, last name and title of the employee whose employee_id is 7.
--       Columns: first_name, last_name, title.
-- Run: pnpm check 02-02

-- Write your query below
SELECT first_name, last_name, title
FROM employees
WHERE employee_id = 7
