# Week 6: Aggregates

Focus: aggregates: counting, grouping, filtering groups, and the classic traps.
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 06-01 | How many customers? | QUERY | done |
| 06-02 | Price range | QUERY | done |
| 06-03 | What do we actually know about products? | QUERY | done |
| 06-04 | Orders per status | QUERY | done |
| 06-05 | Products per category | QUERY | done |
| 06-06 | Best sellers by quantity | QUERY | done |
| 06-07 | How many different buyers? | QUERY | done |
| 06-08 | Payments by method, large ones apart | QUERY | done |
| 06-09 | Employees per department, as text | QUERY | done |
| 06-10 | Error on the frequent customers | DEBUG | done |
| 06-11 | Error on the product count | DEBUG | done |
| 06-12 | Paid amounts are inflated | DEBUG | done |
| 06-13 | Predict: customers and statuses | PREDICT | done |
| 06-14 | Categories that reach many people | QUERY | done |
| 06-15 | Payment methods in 2024 | QUERY | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews. Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 06-01: How many customers? ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: COUNT
- File: `modules/06-aggregate-functions/01-query.sql`
- Request / symptom: "How many customers are there?"
- Definition of done:
  - One column: customer_count.
  - `pnpm check 06-01` is green.

## 06-02: Price range ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: MIN, MAX, AVG
- File: `modules/06-aggregate-functions/02-query.sql`
- Request / symptom: "One row with the lowest, highest and average product price in cents. Round the average to 2 decimals."
- Definition of done:
  - Columns: min_price, max_price, avg_price.
  - `pnpm check 06-02` is green.

## 06-03: What do we actually know about products? ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: COUNT(*) versus COUNT(column)
- File: `modules/06-aggregate-functions/03-query.sql`
- Request / symptom: "One row with: the number of products, how many of them have a weight recorded, and how many have a supplier."
- Definition of done:
  - Columns: total_products, with_weight, with_supplier.
  - `pnpm check 06-03` is green.

## 06-04: Orders per status ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: GROUP BY
- File: `modules/06-aggregate-functions/04-query.sql`
- Request / symptom: "How many orders are there in each status?"
- Definition of done:
  - Columns: status, order_count.
  - `pnpm check 06-04` is green.

## 06-05: Products per category ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: GROUP BY with a join
- File: `modules/06-aggregate-functions/05-query.sql`
- Request / symptom: "For each category that has products directly in it: the category name, the number of products and their average price in cents (rounded to 2 decimals)."
- Definition of done:
  - Columns: category_name, product_count, avg_price_cents.
  - `pnpm check 06-05` is green.

## 06-06: Best sellers by quantity ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: HAVING and SUM
- File: `modules/06-aggregate-functions/06-query.sql`
- Request / symptom: "Return the products ordered in a total quantity of at least 200 units (add up quantity over all order lines)."
- Definition of done:
  - Columns: product_id, total_qty.
  - `pnpm check 06-06` is green.

## 06-07: How many different buyers? ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: COUNT(DISTINCT)
- File: `modules/06-aggregate-functions/07-query.sql`
- Request / symptom: "For each product that was ordered, how many different customers bought it?"
- Definition of done:
  - Columns: product_id, buyers.
  - `pnpm check 06-07` is green.

## 06-08: Payments by method, large ones apart ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: FILTER
- File: `modules/06-aggregate-functions/08-query.sql`
- Request / symptom: "For each payment method: how many payments there are, and how many of them are for 20000 cents or more."
- Definition of done:
  - Columns: method, payment_count, large_count.
  - `pnpm check 06-08` is green.

## 06-09: Employees per department, as text ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: STRING_AGG
- File: `modules/06-aggregate-functions/09-query.sql`
- Request / symptom: "For each department, one text value with the employees' last names in alphabetical order, separated by a comma and a space."
- Definition of done:
  - Columns: department, last_names.
  - `pnpm check 06-09` is green.

## 06-10: Error on the frequent customers ✅
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: WHERE versus HAVING
- File: `modules/06-aggregate-functions/10-debug.sql`
- Request / symptom: "PostgreSQL reports an error about where an aggregate function may appear."
- Definition of done:
  - Fix the query: customers with at least 10 orders.
  - Columns: customer_id, order_count.
  - `pnpm check 06-10` is green.

## 06-11: Error on the product count ✅
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: Columns that are not grouped
- File: `modules/06-aggregate-functions/11-debug.sql`
- Request / symptom: "PostgreSQL complains about a column that must appear in the GROUP BY clause or be used in an aggregate."
- Definition of done:
  - Fix the query: the number of products in each category.
  - Columns: category_id, product_count.
  - `pnpm check 06-11` is green.

## 06-12: Paid amounts are inflated ✅
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: Aggregates over joins that multiply rows
- File: `modules/06-aggregate-functions/12-debug.sql`
- Request / symptom: "The paid amounts are much larger than what customers actually paid; some are multiples of the real value."
- Definition of done:
  - Fix the query: for orders up to 50 that have payments, the total amount paid.
  - Columns: order_id, paid_cents. Sorted by order_id.
  - Row order matters.
  - `pnpm check 06-12` is green.

## 06-13: Predict: customers and statuses ✅
- Type: PREDICT
- Effort: 1 exercise (5 to 12 min)
- Concept: What is one row of a grouped result?
- File: `modules/06-aggregate-functions/13-predict.sql`
- Request / symptom: "Predict how many rows the grouped query returns."
- Definition of done:
  - You wrote your prediction on the `-- GUESS:` line before running anything.
  - `pnpm check 06-13` ran and you know why you were right or wrong. Not graded.

## 06-14: Categories that reach many people ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/06-aggregate-functions/14-query.sql`
- Request / symptom: "Per category, distinct customers who bought from it in 2025; at least 20."
- Definition of done:
  - Columns: category_name, customers. Sorted by customers desc, then category_name.
  - `pnpm check 06-14` is green.

## 06-15: Payment methods in 2024
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/06-aggregate-functions/15-query.sql`
- Request / symptom: "Per payment method: total in euros and payments on cancelled or refunded orders."
- Definition of done:
  - Columns: method, total_eur, payments_on_lost_orders.
  - `pnpm check 06-15` is green.
