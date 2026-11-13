-- 08-10  QUERY
-- Concept: Recursive CTE: hierarchy
-- Task: Return everyone who reports to employee 3, directly or indirectly (not employee 3 itself), with the level: 1 for direct reports, 2 for their reports, and so on.
--       Columns: employee_id, level.
-- Run: pnpm check 08-10

-- Write your query below

WITH RECURSIVE employee_reporters AS (
  SELECT e.employee_id, 1 AS level FROM employees e WHERE e.manager_id = 3
  UNION ALL
  SELECT e.employee_id, er.level + 1 AS level
  FROM employees e JOIN employee_reporters er ON e.manager_id = er.employee_id
)
SELECT * FROM employee_reporters;
