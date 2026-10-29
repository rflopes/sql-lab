# Week 1: Meet the data

Focus: meet the dataset in psql, first SELECTs, filtering, NULL, sorting.
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 01-01 | List all categories | QUERY | todo |
| 01-02 | Supplier names and countries | QUERY | todo |
| 01-03 | How many pricey products? | PREDICT | todo |
| 01-04 | How many sales employees? | PREDICT | todo |
| 02-01 | Product names and prices | QUERY | todo |
| 02-02 | Look up one employee | QUERY | todo |
| 02-03 | Prices in euros | QUERY | todo |
| 02-04 | Cities of our customers | QUERY | todo |
| 02-05 | Mid-priced active products | QUERY | todo |
| 02-06 | Customers in three cities | QUERY | todo |
| 02-07 | Find the jackets | QUERY | todo |
| 02-08 | Customers without a phone | QUERY | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews. Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 01-01: List all categories ✅

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Reading a whole table
- File: `modules/01-introduction/01-query.sql`
- Request / symptom: "Return every row and every column of the categories table."
- Definition of done:
  - Columns: category_id, name, parent_id.
  - `pnpm check 01-01` is green.

## 01-02: Supplier names and countries ✅

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Choosing columns
- File: `modules/01-introduction/02-query.sql`
- Request / symptom: "Return the name and country of every supplier."
- Definition of done:
  - Columns: name, country.
  - `pnpm check 01-02` is green.

## 01-03: How many pricey products? ✅

- Type: PREDICT
- Effort: 1 exercise (5 to 12 min)
- Concept: Filtering rows
- File: `modules/01-introduction/03-predict.sql`
- Request / symptom: "Read the query, predict how many rows it returns, write the number on the GUESS line, then run the check."
- Definition of done:
  - You wrote your prediction on the `-- GUESS:` line before running anything.
  - `pnpm check 01-03` ran and you know why you were right or wrong. Not graded.

## 01-04: How many sales employees? ✅

- Type: PREDICT
- Effort: 1 exercise (5 to 12 min)
- Concept: Filtering rows on text
- File: `modules/01-introduction/04-predict.sql`
- Request / symptom: "Read the query, predict how many rows it returns, write the number on the GUESS line, then run the check."
- Definition of done:
  - You wrote your prediction on the `-- GUESS:` line before running anything.
  - `pnpm check 01-04` ran and you know why you were right or wrong. Not graded.

## 02-01: Product names and prices ✅

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: SELECT, choosing columns
- File: `modules/02-basics/01-query.sql`
- Request / symptom: "Return the name and unit_price_cents of every product."
- Definition of done:
  - Columns: name, unit_price_cents.
  - `pnpm check 02-01` is green.

## 02-02: Look up one employee

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: WHERE with a single value
- File: `modules/02-basics/02-query.sql`
- Request / symptom: "Return the first name, last name and title of the employee whose employee_id is 7."
- Definition of done:
  - Columns: first_name, last_name, title.
  - `pnpm check 02-02` is green.

## 02-03: Prices in euros

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Aliases and expressions
- File: `modules/02-basics/03-query.sql`
- Request / symptom: "Return each product with its price in euros (not cents), as a decimal number: 12950 cents is 129.50."
- Definition of done:
  - Columns: sku, name, price_eur.
  - `pnpm check 02-03` is green.

## 02-04: Cities of our customers

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: DISTINCT, NULL, ORDER BY
- File: `modules/02-basics/04-query.sql`
- Request / symptom: "List the different cities where customers live, ignoring customers without a city."
- Definition of done:
  - One column: city. Sorted alphabetically.
  - Row order matters.
  - `pnpm check 02-04` is green.

## 02-05: Mid-priced active products

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Combining conditions
- File: `modules/02-basics/05-query.sql`
- Request / symptom: "Return the active products priced from 5000 to 15000 cents, both limits included."
- Definition of done:
  - Columns: product_id, name, unit_price_cents. Sorted by product_id.
  - Row order matters.
  - `pnpm check 02-05` is green.

## 02-06: Customers in three cities

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Matching a list of values
- File: `modules/02-basics/06-query.sql`
- Request / symptom: "Return customers who live in Lisbon, Porto or Braga."
- Definition of done:
  - Columns: customer_id, city. Sorted by customer_id.
  - Row order matters.
  - `pnpm check 02-06` is green.

## 02-07: Find the jackets

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Pattern matching and case
- File: `modules/02-basics/07-query.sql`
- Request / symptom: "Return products whose name contains the text "jacket", in any capitalisation."
- Definition of done:
  - Columns: product_id, name. Sorted by product_id.
  - Row order matters.
  - `pnpm check 02-07` is green.

## 02-08: Customers without a phone

- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Testing for NULL
- File: `modules/02-basics/08-query.sql`
- Request / symptom: "Return customers who have no phone number recorded."
- Definition of done:
  - Columns: customer_id, first_name, last_name. Sorted by customer_id.
  - Row order matters.
  - `pnpm check 02-08` is green.
