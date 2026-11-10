# Week 5: Joins, part two

Focus: joins, part two: self joins, set operations, views, and debugging joins.
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 05-10 | Categories and their parents | QUERY | done |
| 05-11 | Employees and orders, both ways | QUERY | done |
| 05-12 | Every supplier with every top category | QUERY | done |
| 05-13 | One list of all emails | QUERY | done |
| 05-14 | Ordered but never reviewed | QUERY | done |
| 05-15 | Reviewers with cancelled orders | QUERY | done |
| 05-16 | A view of active products | DDL | done |
| 05-17 | Customers vanish from the list | DEBUG | done |
| 05-18 | Paid orders appear several times | DEBUG | done |
| 05-19 | Predict: one customer, two joins | PREDICT | done |
| 05-20 | Referrals across cities | QUERY | done |
| 05-21 | Recent buyers without reviews | QUERY | todo |
| 05-22 | Cities get their own table | DDL | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews. Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 05-10: Categories and their parents ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Joining a table to itself through a link
- File: `modules/05-multi-table-queries/10-query.sql`
- Request / symptom: "Return every product with the name of its category and the name of that category's parent category (NULL when the category has no parent)."
- Definition of done:
  - Columns: product_id, category_name, parent_category_name.
  - `pnpm check 05-10` is green.

## 05-11: Employees and orders, both ways ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Keeping unmatched rows on both sides
- File: `modules/05-multi-table-queries/11-query.sql`
- Request / symptom: "Pair employees with the orders they handled: one row per (employee, order) pair. Include employees who never handled an order (order columns NULL) and orders handled by nobody (employee columns NULL)."
- Definition of done:
  - Columns: employee_id, last_name, order_id, status. employee_id and last_name come from employees; order_id and status from orders.
  - `pnpm check 05-11` is green.

## 05-12: Every supplier with every top category ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: All combinations
- File: `modules/05-multi-table-queries/12-query.sql`
- Request / symptom: "Return every combination of a supplier with a top-level category (a category that has no parent)."
- Definition of done:
  - Columns: supplier_name, category_name.
  - `pnpm check 05-12` is green.

## 05-13: One list of all emails ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Stacking results
- File: `modules/05-multi-table-queries/13-query.sql`
- Request / symptom: "Return one list with every distinct email address stored in the database: customer emails and supplier contact emails, exactly as stored."
- Definition of done:
  - One column: email.
  - `pnpm check 05-13` is green.

## 05-14: Ordered but never reviewed ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Set difference
- File: `modules/05-multi-table-queries/14-query.sql`
- Request / symptom: "Return the product_id of every product that has been ordered at least once but has never been reviewed."
- Definition of done:
  - One column: product_id.
  - `pnpm check 05-14` is green.

## 05-15: Reviewers with cancelled orders ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Set intersection
- File: `modules/05-multi-table-queries/15-query.sql`
- Request / symptom: "Return the customer_id of customers who have written at least one review and also have at least one order with status 'cancelled'."
- Definition of done:
  - One column: customer_id.
  - `pnpm check 05-15` is green.

## 05-16: A view of active products ✅
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: Views
- File: `modules/05-multi-table-queries/16-ddl.sql`
- Request / symptom: "Create a view named active_products with the columns product_id, name and unit_price_cents of the products that are active."
- Definition of done:
  - Create a view named active_products with the columns product_id, name and unit_price_cents of the products that are active.
  - `pnpm check 05-16` is green.

## 05-17: Customers vanish from the list ✅
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: Outer join and WHERE
- File: `modules/05-multi-table-queries/17-debug.sql`
- Request / symptom: "Customers who have no cancelled order have disappeared from the result, although the goal was to list everyone."
- Definition of done:
  - Fix the query: return every customer, together with their cancelled orders. Customers without a cancelled order still appear once, with order_id NULL.
  - Columns: customer_id, email, order_id.
  - `pnpm check 05-17` is green.

## 05-18: Paid orders appear several times ✅
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: Joins that multiply rows
- File: `modules/05-multi-table-queries/18-debug.sql`
- Request / symptom: "Each paid order shows up several times. It should appear exactly once."
- Definition of done:
  - Fix the query: paid orders, each one exactly once.
  - Columns: order_id, status.
  - `pnpm check 05-18` is green.

## 05-19: Predict: one customer, two joins ✅
- Type: PREDICT
- Effort: 1 exercise (5 to 12 min)
- Concept: How joins change the number of rows
- File: `modules/05-multi-table-queries/19-predict.sql`
- Request / symptom: "Customer 12 placed 2 orders. Predict how many rows the query returns."
- Definition of done:
  - You wrote your prediction on the `-- GUESS:` line before running anything.
  - `pnpm check 05-19` ran and you know why you were right or wrong. Not graded.

## 05-20: Referrals across cities ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/05-multi-table-queries/20-query.sql`
- Request / symptom: "List every customer who was referred by a customer living in a different city."
- Definition of done:
  - Columns: customer_id, city, referrer_city. Sorted by customer_id.
  - `pnpm check 05-20` is green.

## 05-21: Recent buyers without reviews
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/05-multi-table-queries/21-query.sql`
- Request / symptom: "Customers who ordered in December 2024 and have never written a review."
- Definition of done:
  - Columns: customer_id, email. Sorted by customer_id.
  - `pnpm check 05-21` is green.

## 05-22: Cities get their own table
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: Normalisation: moving repeated text into its own table
- File: `modules/05-multi-table-queries/22-ddl.sql`
- Request / symptom: "Move customer cities into their own table and point customers at it."
- Definition of done:
  - All four steps in the file are done.
  - `pnpm check 05-22` is green.
