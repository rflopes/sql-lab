# Week 2: Sorting, paging, first debugging, changing data

Focus: sorting and paging, debugging your first queries, then changing data with INSERT, UPDATE and DELETE.
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 02-09 | Five most expensive products | QUERY | todo |
| 02-10 | Page 3 of the customer list | QUERY | todo |
| 02-11 | Last names, as stored | QUERY | todo |
| 02-12 | Everything except one supplier | QUERY | todo |
| 02-13 | Orders of March 2025 | QUERY | todo |
| 02-14 | Customers without a city: empty result | DEBUG | todo |
| 02-15 | The "cheapest" products look random | DEBUG | todo |
| 02-16 | Error on the price filter | DEBUG | todo |
| 02-17 | Predict: cities and opt-ins | PREDICT | todo |
| 03-01 | Add a supplier | DML | todo |
| 03-02 | Deactivate one product | DML | todo |
| 03-03 | New categories, get the ids back | DML | todo |
| 03-04 | Rain jacket sale | DML | todo |
| 03-05 | Clean up empty 1-star reviews | DML | todo |
| 03-06 | Update or add products in one go | DML | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews. Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 02-09: Five most expensive products ✅
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: ORDER BY with several keys, LIMIT
- File: `modules/02-basics/09-query.sql`
- Request / symptom: "Return the 5 most expensive products. When prices tie, the product with the lower product_id comes first."
- Definition of done:
  - Columns: product_id, name, unit_price_cents.
  - Row order matters.
  - `pnpm check 02-09` is green.

## 02-10: Page 3 of the customer list
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Pagination
- File: `modules/02-basics/10-query.sql`
- Request / symptom: "Customers sorted by customer_id, 20 per page: return page 3."
- Definition of done:
  - Columns: customer_id, email.
  - Row order matters.
  - `pnpm check 02-10` is green.

## 02-11: Last names, as stored
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Sorting text and collation
- File: `modules/02-basics/11-query.sql`
- Request / symptom: "Return the distinct values of last_name from customers exactly as stored (no cleaning), sorted ascending."
- Definition of done:
  - One column: last_name. Look at where lowercase and uppercase names land, then read about collation in the primer.
  - Row order matters.
  - `pnpm check 02-11` is green.

## 02-12: Everything except one supplier
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: NULL-safe comparison
- File: `modules/02-basics/12-query.sql`
- Request / symptom: "Return products that are NOT supplied by supplier 3. Products with no supplier at all must be included."
- Definition of done:
  - Columns: product_id, name.
  - `pnpm check 02-12` is green.

## 02-13: Orders of March 2025
- Type: QUERY
- Effort: 1 exercise (5 to 12 min)
- Concept: Timestamps and half-open ranges
- File: `modules/02-basics/13-query.sql`
- Request / symptom: "Return the orders placed in March 2025 (UTC): from 2025-03-01 00:00:00 up to, but not including, 2025-04-01 00:00:00."
- Definition of done:
  - Columns: order_id, ordered_at. Sorted by order_id.
  - Row order matters.
  - `pnpm check 02-13` is green.

## 02-14: Customers without a city: empty result
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: Comparing with NULL
- File: `modules/02-basics/14-debug.sql`
- Request / symptom: "The query runs without errors but returns no rows, although many customers have no city."
- Definition of done:
  - Fix the query so it returns customers with no city recorded.
  - Columns: customer_id, email.
  - `pnpm check 02-14` is green.

## 02-15: The "cheapest" products look random
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: LIMIT needs an order
- File: `modules/02-basics/15-debug.sql`
- Request / symptom: "These were supposed to be the 3 cheapest products, but they look arbitrary, and changing nothing in the data can change them."
- Definition of done:
  - Fix the query: the 3 cheapest products, ties broken by the lower product_id first.
  - Columns: product_id, name, unit_price_cents.
  - Row order matters.
  - `pnpm check 02-15` is green.

## 02-16: Error on the price filter
- Type: DEBUG
- Effort: 1 exercise (5 to 12 min)
- Concept: Reading an error message
- File: `modules/02-basics/16-debug.sql`
- Request / symptom: "PostgreSQL reports an error. Read the message and the position marker carefully."
- Definition of done:
  - Fix the query: products priced above 100 euros.
  - Columns: name, price_eur.
  - `pnpm check 02-16` is green.

## 02-17: Predict: cities and opt-ins
- Type: PREDICT
- Effort: 1 exercise (5 to 12 min)
- Concept: What is one row of the result?
- File: `modules/02-basics/17-predict.sql`
- Request / symptom: "Read the query, predict how many rows it returns, write the number on the GUESS line, then run the check."
- Definition of done:
  - You wrote your prediction on the `-- GUESS:` line before running anything.
  - `pnpm check 02-17` ran and you know why you were right or wrong. Not graded.

## 03-01: Add a supplier
- Type: DML
- Effort: 1 exercise (5 to 12 min)
- Concept: INSERT
- File: `modules/03-manipulating-data/01-dml.sql`
- Request / symptom: "Insert one new supplier: name "Fjord Outfitters", country "Norway", contact_email "hello@fjord.example"."
- Definition of done:
  - Insert one new supplier: name "Fjord Outfitters", country "Norway", contact_email "hello@fjord.example".
  - `pnpm check 03-01` is green.

## 03-02: Deactivate one product
- Type: DML
- Effort: 1 exercise (5 to 12 min)
- Concept: UPDATE with WHERE
- File: `modules/03-manipulating-data/02-dml.sql`
- Request / symptom: "Deactivate the product with sku 'TNT-0001' (set is_active to false). No other product may change."
- Definition of done:
  - Deactivate the product with sku 'TNT-0001' (set is_active to false). No other product may change.
  - `pnpm check 03-02` is green.

## 03-03: New categories, get the ids back
- Type: DML
- Effort: 1 exercise (5 to 12 min)
- Concept: INSERT several rows, RETURNING
- File: `modules/03-manipulating-data/03-dml.sql`
- Request / symptom: "Insert two categories whose parent is the existing category named "Navigation": "Compasses" and "GPS Devices", in one statement."
- Definition of done:
  - Insert two categories whose parent is the existing category named "Navigation": "Compasses" and "GPS Devices", in one statement.
  - The same statement must return the generated category_id and the name of the new rows (columns category_id, name).
  - `pnpm check 03-03` is green.

## 03-04: Rain jacket sale
- Type: DML
- Effort: 1 exercise (5 to 12 min)
- Concept: UPDATE with an expression
- File: `modules/03-manipulating-data/04-dml.sql`
- Request / symptom: "Cut the price of every product in category 22 by 12.5%. Store the new price as whole cents, rounded to the nearest cent (halves round up)."
- Definition of done:
  - Cut the price of every product in category 22 by 12.5%. Store the new price as whole cents, rounded to the nearest cent (halves round up).
  - Products in other categories must not change.
  - `pnpm check 03-04` is green.

## 03-05: Clean up empty 1-star reviews
- Type: DML
- Effort: 1 exercise (5 to 12 min)
- Concept: DELETE
- File: `modules/03-manipulating-data/05-dml.sql`
- Request / symptom: "Delete the reviews that have a rating of 1 and no text (body is NULL). Keep every other review."
- Definition of done:
  - Delete the reviews that have a rating of 1 and no text (body is NULL). Keep every other review.
  - `pnpm check 03-05` is green.

## 03-06: Update or add products in one go
- Type: DML
- Effort: 1 exercise (5 to 12 min)
- Concept: ON CONFLICT (upsert)
- File: `modules/03-manipulating-data/06-dml.sql`
- Request / symptom: "In ONE statement, write these two products into products:"
- Definition of done:
  - In ONE statement, write these two products into products:
  - sku "TNT-0001", name "Ridge 1P Tent v2", category_id 16, unit_price_cents 21000
  - sku "NEW-0001", name "Trail Towel", category_id 15, unit_price_cents 1500
  - A product with sku "TNT-0001" already exists: for it, update name and unit_price_cents instead of inserting a duplicate. All other columns keep their values.
  - `pnpm check 03-06` is green.
