# Week 9: Window functions

Focus: window functions: ranking, LAG/LEAD, running totals and frames.
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 09-03 | Price ranks inside categories | QUERY | done |
| 09-04 | Latest order per customer | QUERY | done |
| 09-05 | Gap between orders | QUERY | done |
| 09-06 | Next price up | QUERY | done |
| 09-07 | Revenue so far | QUERY | todo |
| 09-08 | Line and order totals together | QUERY | todo |
| 09-09 | Three-month average | QUERY | todo |
| 09-10 | Cheapest in the category | QUERY | todo |
| 09-11 | Order totals keep growing | DEBUG | todo |
| 09-12 | Tied cheapest products go missing | DEBUG | todo |
| 09-13 | Customers who went quiet | QUERY | todo |
| 09-14 | Best seller per category | QUERY | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews. Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 09-03: Price ranks inside categories ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: RANK and DENSE_RANK
- File: `modules/09-window-functions/03-query.sql`
- Request / symptom: "Rank products within their category by price, most expensive first: once with RANK and once with DENSE_RANK. Equal prices get equal ranks."
- Definition of done:
  - Columns: product_id, category_id, unit_price_cents, rnk, dense_rnk.
  - `pnpm check 09-03` is green.

## 09-04: Latest order per customer ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Top row per group
- File: `modules/09-window-functions/04-query.sql`
- Request / symptom: "Return the most recent order of each customer who has orders. If two orders share the latest timestamp, the higher order_id counts as the most recent."
- Definition of done:
  - Columns: customer_id, order_id, ordered_at.
  - `pnpm check 09-04` is green.

## 09-05: Gap between orders ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: LAG
- File: `modules/09-window-functions/05-query.sql`
- Request / symptom: "For every order: the number of complete 24-hour periods since the same customer's previous order (NULL for their first order). Previous = the one before it when sorted by ordered_at, then order_id."
- Definition of done:
  - Columns: order_id, customer_id, ordered_at, days_since_prev.
  - `pnpm check 09-05` is green.

## 09-06: Next price up ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: LEAD
- File: `modules/09-window-functions/06-query.sql`
- Request / symptom: "Within each category, sort products by price ascending (ties: lower product_id first). For each product also show the price of the next product in that order; NULL for the last one."
- Definition of done:
  - Columns: product_id, category_id, unit_price_cents, next_price_cents.
  - `pnpm check 09-06` is green.

## 09-07: Revenue so far
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Running totals
- File: `modules/09-window-functions/07-query.sql`
- Request / symptom: "Monthly revenue and its running total. Revenue = sum of quantity * unit_price_cents over the lines of orders whose status is not 'cancelled', grouped by the month of ordered_at (UTC). The running total adds up the months so far, in month order."
- Definition of done:
  - Columns: month (first day of the month, as a date), revenue_cents, running_cents.
  - `pnpm check 09-07` is green.

## 09-08: Line and order totals together
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Window aggregate over a whole partition
- File: `modules/09-window-functions/08-query.sql`
- Request / symptom: "For order lines of orders up to order_id 20: the line total (quantity * unit_price_cents) and the total of the whole order next to it."
- Definition of done:
  - Columns: order_item_id, order_id, line_cents, order_cents.
  - `pnpm check 09-08` is green.

## 09-09: Three-month average
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Frames: ROWS
- File: `modules/09-window-functions/09-query.sql`
- Request / symptom: "Take the monthly revenue of 09-07 (non-cancelled orders, grouped by month of ordered_at, UTC) and add a moving average over the current month and the 2 months before it (fewer at the start). Round to 2 decimals."
- Definition of done:
  - Columns: month (first day of the month, as a date), revenue_cents, moving_avg_cents.
  - `pnpm check 09-09` is green.

## 09-10: Cheapest in the category
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: FIRST_VALUE
- File: `modules/09-window-functions/10-query.sql`
- Request / symptom: "For each product, also show the name of the cheapest product in its category. If several share the lowest price, the one with the lower product_id counts."
- Definition of done:
  - Columns: product_id, category_id, name, cheapest_in_category.
  - `pnpm check 09-10` is green.

## 09-11: Order totals keep growing
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: Window ORDER BY changes the frame
- File: `modules/09-window-functions/11-debug.sql`
- Request / symptom: "order_cents grows from one row to the next inside each order instead of showing the order's total."
- Definition of done:
  - Fix the query: every line of an order shows the total of the whole order.
  - Columns: order_id, order_item_id, line_cents, order_cents.
  - `pnpm check 09-11` is green.

## 09-12: Tied cheapest products go missing
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: ROW_NUMBER versus RANK on ties
- File: `modules/09-window-functions/12-debug.sql`
- Request / symptom: "Some categories have two products tied for the lowest price, but only one of them shows up."
- Definition of done:
  - Fix the query: for each category, its cheapest product(s). When several tie for the lowest price, all of them must appear.
  - Columns: product_id, category_id, unit_price_cents.
  - `pnpm check 09-12` is green.

## 09-13: Customers who went quiet
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/09-window-functions/13-query.sql`
- Request / symptom: "The 10 customers with the largest gap in days between consecutive orders."
- Definition of done:
  - Columns: customer_id, max_gap_days. Sorted by max_gap_days desc, then customer_id.
  - `pnpm check 09-13` is green.

## 09-14: Best seller per category
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/09-window-functions/14-query.sql`
- Request / symptom: "The product with the most units sold in 2025, per category."
- Definition of done:
  - Columns: category_id, product_id, units. Sorted by category_id.
  - `pnpm check 09-14` is green.
