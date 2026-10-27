# Week 3: Defining tables

Focus: defining tables: types, constraints, ALTER, DROP, transactions around DDL.
Planned: up to 5 sessions of 30 min, 2 or 3 exercises each. Slipping is fine.

| Ticket | Title | Type | Status |
| --- | --- | --- | --- |
| 04-01 | Create the warehouses table | DDL | todo |
| 04-02 | Notes for suppliers | DDL | todo |
| 04-03 | Stock levels table | DDL | todo |
| 04-04 | Coupons that cannot be nonsense | DDL | todo |
| 04-05 | Reject bad emails | DDL | todo |
| 04-06 | Loyalty points | DDL | todo |
| 04-07 | Wishlists | DDL | todo |
| 04-08 | Empty the payments table | DDL | todo |
| 04-09 | Two tables, one survives | DDL | todo |
| 04-10 | Remove reviews and weights | DDL | todo |
| 04-11 | Tags for products | DDL | todo |
| 04-12 | Supplier contacts | DDL | todo |
| 04-13 | One email, any capitalisation | DDL | todo |

Tables: categories, suppliers, products, customers, employees, orders, order_items, payments, reviews. Explore with `pnpm sql` (`\dt`, `\d table`). Money is in integer cents. "Today" is never `now()`: statements fix their own dates.

---

## 04-01: Create the warehouses table
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: CREATE TABLE, primary key, identity
- File: `modules/04-defining-tables/01-ddl.sql`
- Request / symptom: "Create a table warehouses with:"
- Definition of done:
  - Create a table warehouses with:
  - warehouse_id  integer, generated always as identity, primary key
  - name          text, required
  - city          text, optional
  - `pnpm check 04-01` is green.

## 04-02: Notes for suppliers
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: ALTER TABLE ... ADD COLUMN
- File: `modules/04-defining-tables/02-ddl.sql`
- Request / symptom: "Add an optional text column notes to the existing table suppliers."
- Definition of done:
  - Add an optional text column notes to the existing table suppliers.
  - `pnpm check 04-02` is green.

## 04-03: Stock levels table
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: Types, defaults, composite primary key
- File: `modules/04-defining-tables/03-ddl.sql`
- Request / symptom: "Create a table stock_levels with:"
- Definition of done:
  - Create a table stock_levels with:
  - warehouse_id  integer, required
  - product_id    integer, required
  - quantity      bigint, required, default 0
  - reserved      numeric with 8 digits in total and 2 after the point, required, default 0
  - active        boolean, required, default true
  - last_counted  date, optional
  - updated_at    timestamp with time zone, required, default now()
  - The primary key is the pair (warehouse_id, product_id).
  - `pnpm check 04-03` is green.

## 04-04: Coupons that cannot be nonsense
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: CHECK, NOT NULL, text primary key
- File: `modules/04-defining-tables/04-ddl.sql`
- Request / symptom: "Create a table coupons with:"
- Definition of done:
  - Create a table coupons with:
  - code          text, primary key
  - discount_pct  numeric(5,2), required, and the database must reject values below 0 or above 100
  - valid_until   date, optional
  - `pnpm check 04-04` is green.

## 04-05: Reject bad emails
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: ALTER TABLE ... ADD CONSTRAINT
- File: `modules/04-defining-tables/05-ddl.sql`
- Request / symptom: "Make the database reject any customer whose email does not contain an "@". Existing rows are already fine."
- Definition of done:
  - Make the database reject any customer whose email does not contain an "@". Existing rows are already fine.
  - `pnpm check 04-05` is green.

## 04-06: Loyalty points
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: ADD COLUMN with NOT NULL and DEFAULT
- File: `modules/04-defining-tables/06-ddl.sql`
- Request / symptom: "Add a required integer column loyalty_points to customers, with default 0. Every existing customer must end up with 0."
- Definition of done:
  - Add a required integer column loyalty_points to customers, with default 0. Every existing customer must end up with 0.
  - `pnpm check 04-06` is green.

## 04-07: Wishlists
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: Foreign keys and UNIQUE
- File: `modules/04-defining-tables/07-ddl.sql`
- Request / symptom: "Create a table wishlists with:"
- Definition of done:
  - Create a table wishlists with:
  - wishlist_id  integer, generated always as identity, primary key
  - customer_id  integer, required, must refer to an existing customer
  - product_id   integer, required, must refer to an existing product
  - added_at     timestamp with time zone, required, default now()
  - A customer cannot have the same product twice on the list.
  - `pnpm check 04-07` is green.

## 04-08: Empty the payments table
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: TRUNCATE and identity reset
- File: `modules/04-defining-tables/08-ddl.sql`
- Request / symptom: "Remove every row from payments but keep the table. The next payment inserted afterwards must get payment_id 1."
- Definition of done:
  - Remove every row from payments but keep the table. The next payment inserted afterwards must get payment_id 1.
  - `pnpm check 04-08` is green.

## 04-09: Two tables, one survives
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: Transactional DDL
- File: `modules/04-defining-tables/09-ddl.sql`
- Request / symptom: "Inside a single transaction, create tables trial_a and trial_b (each with one integer column id)."
- Definition of done:
  - Inside a single transaction, create tables trial_a and trial_b (each with one integer column id).
  - When the script ends, trial_a must exist and trial_b must not. trial_b has to be created and then undone inside that same transaction; do not just skip it.
  - `pnpm check 04-09` is green.

## 04-10: Remove reviews and weights
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: DROP
- File: `modules/04-defining-tables/10-ddl.sql`
- Request / symptom: "Remove the table reviews completely, and remove the column weight_kg from products."
- Definition of done:
  - Remove the table reviews completely, and remove the column weight_kg from products.
  - `pnpm check 04-10` is green.

## 04-11: Tags for products
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: Many-to-many relationships, composite keys
- File: `modules/04-defining-tables/11-ddl.sql`
- Request / symptom: "Products need free-form tags. A product can have many tags and a tag can be on many products."
- Definition of done:
  - Tables tags and product_tags exist as described in the file.
  - `pnpm check 04-11` is green.

## 04-12: Supplier contacts
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: Foreign keys: what happens on delete
- File: `modules/04-defining-tables/12-ddl.sql`
- Request / symptom: "Create a table supplier_contacts; when a supplier is deleted, its contacts go too."
- Definition of done:
  - Table supplier_contacts exists as described in the file.
  - `pnpm check 04-12` is green.

## 04-13: One email, any capitalisation
- Type: DDL
- Effort: 1 exercise (5 to 12 min)
- Concept: Uniqueness on an expression
- File: `modules/04-defining-tables/13-ddl.sql`
- Request / symptom: "Reject a supplier whose contact_email matches an existing one when capitalisation is ignored."
- Definition of done:
  - Existing suppliers are unchanged.
  - `pnpm check 04-13` is green.
