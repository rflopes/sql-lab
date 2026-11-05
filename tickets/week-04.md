# Week 4: Joins, part one

Focus: joins, part one: matching rows across tables and finding rows with no match.
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 05-01 | Orders with customer emails | QUERY | done |
| 05-02 | Products with category names | QUERY | done |
| 05-03 | What is in order 100? | QUERY | todo |
| 05-04 | Products and their suppliers | QUERY | todo |
| 05-05 | Customers who never ordered | QUERY | todo |
| 05-06 | Products nobody bought | QUERY | todo |
| 05-07 | Who reports to whom | QUERY | todo |
| 05-08 | Who referred whom | QUERY | todo |
| 05-09 | Error on the customer/order list | DEBUG | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews. Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 05-01: Orders with customer emails ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Joining two tables
- File: `modules/05-multi-table-queries/01-query.sql`
- Request / symptom: "For orders with order_id up to 10, return the order and the email of the customer who placed it."
- Definition of done:
  - Columns: order_id, status, email.
  - `pnpm check 05-01` is green.

## 05-02: Products with category names ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Joining with aliases
- File: `modules/05-multi-table-queries/02-query.sql`
- Request / symptom: "Return every product together with the name of its category."
- Definition of done:
  - Columns: product_name, category_name.
  - `pnpm check 05-02` is green.

## 05-03: What is in order 100?
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Many-to-many through a link table
- File: `modules/05-multi-table-queries/03-query.sql`
- Request / symptom: "List what was bought in order 100: one row per line."
- Definition of done:
  - Columns: order_id, product_name, quantity.
  - `pnpm check 05-03` is green.

## 05-04: Products and their suppliers
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Keeping rows without a match
- File: `modules/05-multi-table-queries/04-query.sql`
- Request / symptom: "Return every product with its supplier name. Products without a supplier must still appear, with a NULL supplier name."
- Definition of done:
  - Columns: product_id, product_name, supplier_name.
  - `pnpm check 05-04` is green.

## 05-05: Customers who never ordered
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Finding rows with no match
- File: `modules/05-multi-table-queries/05-query.sql`
- Request / symptom: "Return customers who have never placed an order."
- Definition of done:
  - Columns: customer_id, email. Sorted by customer_id.
  - Row order matters.
  - `pnpm check 05-05` is green.

## 05-06: Products nobody bought
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Finding rows with no match, again
- File: `modules/05-multi-table-queries/06-query.sql`
- Request / symptom: "Return products that have never been ordered."
- Definition of done:
  - Columns: product_id, name.
  - `pnpm check 05-06` is green.

## 05-07: Who reports to whom
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Self join
- File: `modules/05-multi-table-queries/07-query.sql`
- Request / symptom: "Return every employee with the name of their manager. The CEO has no manager: show NULL."
- Definition of done:
  - Columns: employee_id, employee_name, manager_name. A name is first_name, one space, last_name.
  - `pnpm check 05-07` is green.

## 05-08: Who referred whom
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Self join on customers
- File: `modules/05-multi-table-queries/08-query.sql`
- Request / symptom: "Return the customers who were referred by another customer, together with the email of whoever referred them."
- Definition of done:
  - Columns: customer_id, referrer_email.
  - `pnpm check 05-08` is green.

## 05-09: Error on the customer/order list
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: Ambiguous column names
- File: `modules/05-multi-table-queries/09-debug.sql`
- Request / symptom: "PostgreSQL refuses to run the query. Read the message: which name does it complain about, and why?"
- Definition of done:
  - Fix the query: customers with their orders, for order_id up to 20.
  - Columns: customer_id, email, order_id.
  - `pnpm check 05-09` is green.
