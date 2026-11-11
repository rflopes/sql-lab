-- 06-09  QUERY
-- Concept: STRING_AGG
-- Task: For each department, one text value with the employees' last names in alphabetical order, separated by a comma and a space.
--       Columns: department, last_names.
-- Run: pnpm check 06-09

-- Write your query below

SELECT employees.department, STRING_AGG(last_name, ', ' ORDER BY last_name) AS last_names
FROM employees
GROUP BY department
