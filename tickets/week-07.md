# Week 7: Scalar functions and subqueries

Focus: scalar functions (text, numbers, dates, CASE, COALESCE) and your first subqueries.
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 07-01 | Messy emails | QUERY | done |
| 07-02 | Email domains | QUERY | done |
| 07-03 | One contact line | QUERY | done |
| 07-04 | Weights and boxes | QUERY | done |
| 07-05 | Order dates and months | QUERY | done |
| 07-06 | Weekday and hour of orders | QUERY | done |
| 07-07 | Days to ship | QUERY | done |
| 07-08 | Number inside the sku | QUERY | done |
| 07-09 | Price bands | QUERY | done |
| 07-10 | Line totals after discount | QUERY | todo |
| 07-11 | Email providers of buyers | QUERY | todo |
| 07-12 | Shipping speed in 2024 | QUERY | todo |
| 07-13 | Products with a season (jsonb) | QUERY | todo |
| 07-14 | Green products (jsonb) | QUERY | todo |
| 08-01 | Above the average price | QUERY | todo |
| 08-02 | Customers with a refund | QUERY | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews, product_specs (jsonb, optional exercises). Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 07-01: Messy emails ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: TRIM, LOWER
- File: `modules/07-scalar-functions/01-query.sql`
- Request / symptom: "Find customers whose stored email is not clean, meaning it differs from its trimmed, lowercase form. Show both."
- Definition of done:
  - Columns: customer_id, email, clean_email. Only rows where clean_email differs from email.
  - `pnpm check 07-01` is green.

## 07-02: Email domains ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: SPLIT_PART
- File: `modules/07-scalar-functions/02-query.sql`
- Request / symptom: "Return the domain of every customer's email: the text after the "@", taken from the trimmed, lowercase email."
- Definition of done:
  - Columns: customer_id, domain.
  - `pnpm check 07-02` is green.

## 07-03: One contact line ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Concatenation and NULL
- File: `modules/07-scalar-functions/03-query.sql`
- Request / symptom: "For each customer return one contact text: the non-NULL values among city and phone, joined with " / ". If only one exists there is no separator; if neither exists the result is an empty string (not NULL)."
- Definition of done:
  - Columns: customer_id, contact.
  - `pnpm check 07-03` is green.

## 07-04: Weights and boxes ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Numeric functions
- File: `modules/07-scalar-functions/04-query.sql`
- Request / symptom: "For products with a known weight: the weight in grams (whole number, rounded) and the number of 2.5 kg boxes needed to ship one unit (round up to a whole number of boxes)."
- Definition of done:
  - Columns: product_id, weight_g, boxes.
  - `pnpm check 07-04` is green.

## 07-05: Order dates and months ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Dates: casting and date_trunc
- File: `modules/07-scalar-functions/05-query.sql`
- Request / symptom: "For orders up to order_id 30: the calendar date of the order (UTC), and the first day of its month, both as dates."
- Definition of done:
  - Columns: order_id, order_date, order_month.
  - `pnpm check 07-05` is green.

## 07-06: Weekday and hour of orders ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: EXTRACT and TO_CHAR
- File: `modules/07-scalar-functions/06-query.sql`
- Request / symptom: "For orders with order_id from 100 to 130: the weekday as a 3-letter English abbreviation (Mon, Tue, ...) and the hour of the day (0 to 23), in UTC."
- Definition of done:
  - Columns: order_id, weekday, hour.
  - `pnpm check 07-06` is green.

## 07-07: Days to ship ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Intervals
- File: `modules/07-scalar-functions/07-query.sql`
- Request / symptom: "For shipped orders with order_id up to 60: the number of complete 24-hour periods between ordered_at and shipped_at (so 1 day 23 hours counts as 1)."
- Definition of done:
  - Columns: order_id, days_to_ship. Orders that were not shipped are left out.
  - `pnpm check 07-07` is green.

## 07-08: Number inside the sku ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Casting text to numbers
- File: `modules/07-scalar-functions/08-query.sql`
- Request / symptom: "Every sku looks like "TNT-0001". Return the numeric part as an integer."
- Definition of done:
  - Columns: product_id, sku, sku_number.
  - `pnpm check 07-08` is green.

## 07-09: Price bands ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: CASE
- File: `modules/07-scalar-functions/09-query.sql`
- Request / symptom: "Classify each product by price: "budget" under 5000 cents, "mid" from 5000 to 14999, "premium" from 15000 up."
- Definition of done:
  - Columns: product_id, price_band.
  - `pnpm check 07-09` is green.

## 07-10: Line totals after discount
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: COALESCE
- File: `modules/07-scalar-functions/10-query.sql`
- Request / symptom: "For order lines of orders up to order_id 25: the line total after discount, in cents, rounded to a whole number. discount_pct is a percentage; a NULL discount means no discount."
- Definition of done:
  - Columns: order_item_id, net_cents.
  - `pnpm check 07-10` is green.

## 07-11: Email providers of buyers
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/07-scalar-functions/11-query.sql`
- Request / symptom: "Count distinct buying customers per email domain."
- Definition of done:
  - Columns: domain, customers. Sorted by customers desc, then domain.
  - `pnpm check 07-11` is green.

## 07-12: Shipping speed in 2024
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: (not given)
- File: `modules/07-scalar-functions/12-query.sql`
- Request / symptom: "Average days from order to shipping, per month of 2024."
- Definition of done:
  - Columns: month, avg_days_to_ship. Sorted by month.
  - `pnpm check 07-12` is green.

## 07-13: Products with a season (jsonb)
- Type: QUERY (optional)
- Effort: 1 exercise (5 to 12 min)
- Concept: jsonb: reading a key
- File: `modules/07-scalar-functions/13-query.sql`
- Request / symptom: "Return every product whose specs contain the key "season"."
- Definition of done:
  - Columns: product_id, name, season. Sorted by product_id.
  - `pnpm check 07-13` is green.

## 07-14: Green products (jsonb)
- Type: QUERY (optional)
- Effort: 1 exercise (5 to 12 min)
- Concept: jsonb: looking inside an array
- File: `modules/07-scalar-functions/14-query.sql`
- Request / symptom: "Return the products available in "green"."
- Definition of done:
  - Columns: product_id, name. Sorted by product_id.
  - `pnpm check 07-14` is green.

## 08-01: Above the average price
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Scalar subquery
- File: `modules/08-subqueries-and-ctes/01-query.sql`
- Request / symptom: "Return the products whose price is above the average price of all products."
- Definition of done:
  - Columns: product_id, name, unit_price_cents.
  - `pnpm check 08-01` is green.

## 08-02: Customers with a refund
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: IN with a subquery
- File: `modules/08-subqueries-and-ctes/02-query.sql`
- Request / symptom: "Return the customers who have at least one order with status 'refunded'. Each customer once."
- Definition of done:
  - Columns: customer_id, email.
  - `pnpm check 08-02` is green.
