-- 05-07  QUERY
-- Concept: Self join
-- Task: Return every employee with the name of their manager. The CEO has no manager: show NULL.
--       Columns: employee_id, employee_name, manager_name. A name is first_name, one space, last_name.
-- Run: pnpm check 05-07

-- Write your query below

SELECT e.employee_id, concat_ws(' ', e.first_name, e.last_name) AS employee_name, m.first_name || ' ' || m.last_name AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
