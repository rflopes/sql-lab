# Week 8: Subqueries, CTEs, first windows

Focus: subqueries, CTEs (also recursive), and the first window functions.
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 08-03 | Empty leaf categories | QUERY | done |
| 08-04 | Above their own category average | QUERY | done |
| 08-05 | Customers who paid by transfer | QUERY | done |
| 08-06 | Average orders per customer | QUERY | done |
| 08-07 | Top five spenders | QUERY | done |
| 08-08 | Busy months of 2025 | QUERY | done |
| 08-09 | Category paths | QUERY | done |
| 08-10 | Everyone under the VP | QUERY | done |
| 08-11 | Nobody is left in the list | DEBUG | done |
| 08-12 | Error on the price comparison | DEBUG | done |
| 08-13 | Bad first impressions | QUERY | done |
| 08-14 | Revenue per top-level category | QUERY | done |
| 09-01 | Number the categories | QUERY | done |
| 09-02 | Number each customer's orders | QUERY | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews. Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 08-03: Empty leaf categories ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: NOT EXISTS
- File: `modules/08-subqueries-and-ctes/03-query.sql`
- Request / symptom: "Return the categories that have no subcategories and no products."
- Definition of done:
  - Columns: category_id, name.
  - `pnpm check 08-03` is green.

## 08-04: Above their own category average ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Correlated subquery
- File: `modules/08-subqueries-and-ctes/04-query.sql`
- Request / symptom: "Return the products priced above the average price of their own category, with that average (rounded to 2 decimals)."
- Definition of done:
  - Columns: product_id, name, unit_price_cents, category_avg_cents.
  - `pnpm check 08-04` is green.

## 08-05: Customers who paid by transfer ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: EXISTS
- File: `modules/08-subqueries-and-ctes/05-query.sql`
- Request / symptom: "Return the customers who have paid at least one order by "transfer". Each customer once."
- Definition of done:
  - Columns: customer_id, email.
  - `pnpm check 08-05` is green.

## 08-06: Average orders per customer ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Subquery in FROM
- File: `modules/08-subqueries-and-ctes/06-query.sql`
- Request / symptom: "What is the average number of orders per customer, counting only customers who ordered at least once? Round to 2 decimals."
- Definition of done:
  - One column: avg_orders_per_customer.
  - `pnpm check 08-06` is green.

## 08-07: Top five spenders ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: CTE
- File: `modules/08-subqueries-and-ctes/07-query.sql`
- Request / symptom: "The 5 customers who spent most on delivered orders. Spend is the sum of quantity * unit_price_cents over the lines of their delivered orders. Ties: lower customer_id first."
- Definition of done:
  - Columns: customer_id, spend_cents.
  - Row order matters.
  - `pnpm check 08-07` is green.

## 08-08: Busy months of 2025 ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: CTE used twice
- File: `modules/08-subqueries-and-ctes/08-query.sql`
- Request / symptom: "Among the months of 2025 (UTC), return those with more orders than the average monthly number of orders in 2025."
- Definition of done:
  - Columns: month (first day of the month, as a date), order_count.
  - `pnpm check 08-08` is green.

## 08-09: Category paths ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Recursive CTE: paths
- File: `modules/08-subqueries-and-ctes/09-query.sql`
- Request / symptom: "For every category, build its path from the top: names from the root down to the category, separated by " > " (for example: Camping > Tents)."
- Definition of done:
  - Columns: category_id, path. A top-level category's path is just its name.
  - `pnpm check 08-09` is green.

## 08-10: Everyone under the VP ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Recursive CTE: hierarchy
- File: `modules/08-subqueries-and-ctes/10-query.sql`
- Request / symptom: "Return everyone who reports to employee 3, directly or indirectly (not employee 3 itself), with the level: 1 for direct reports, 2 for their reports, and so on."
- Definition of done:
  - Columns: employee_id, level.
  - `pnpm check 08-10` is green.

## 08-11: Nobody is left in the list ✅
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: NOT IN and NULL
- File: `modules/08-subqueries-and-ctes/11-debug.sql`
- Request / symptom: "The query returns no rows at all, but plenty of customers have never referred anyone."
- Definition of done:
  - Fix the query: customers who have not referred any other customer.
  - Columns: customer_id, email.
  - `pnpm check 08-11` is green.

## 08-12: Error on the price comparison ✅
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: Subquery returning several rows
- File: `modules/08-subqueries-and-ctes/12-debug.sql`
- Request / symptom: "PostgreSQL reports an error about a subquery used as an expression."
- Definition of done:
  - Fix the query: products priced at least as much as the most expensive product of category 18.
  - Columns: product_id, name, unit_price_cents.
  - `pnpm check 08-12` is green.

## 08-13: Bad first impressions ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/08-subqueries-and-ctes/13-query.sql`
- Request / symptom: "Customers whose very first order is currently cancelled."
- Definition of done:
  - Columns: customer_id, first_order_id. Sorted by customer_id.
  - `pnpm check 08-13` is green.

## 08-14: Revenue per top-level category ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/08-subqueries-and-ctes/14-query.sql`
- Request / symptom: "Revenue in 2025 per top-level category, including every category below it."
- Definition of done:
  - Columns: category_name, revenue_eur. Sorted by category_name.
  - `pnpm check 08-14` is green.

## 09-01: Number the categories ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: ROW_NUMBER
- File: `modules/09-window-functions/01-query.sql`
- Request / symptom: "Number the categories 1, 2, 3... in alphabetical order of name."
- Definition of done:
  - Columns: category_id, name, row_num.
  - `pnpm check 09-01` is green.

## 09-02: Number each customer's orders
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: PARTITION BY
- File: `modules/09-window-functions/02-query.sql`
- Request / symptom: "Number each customer's orders chronologically: 1 for their first order, 2 for the second... If two orders have the same timestamp, the lower order_id comes first."
- Definition of done:
  - Columns: order_id, customer_id, order_number.
  - `pnpm check 09-02` is green.
