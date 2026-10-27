-- sql-lab schema (PostgreSQL). The "outdoor gear" shop.

CREATE TABLE categories (
  category_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        text    NOT NULL,
  parent_id   integer REFERENCES categories (category_id)
);

CREATE TABLE suppliers (
  supplier_id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name          text NOT NULL,
  country       text NOT NULL,
  contact_email text NOT NULL
);

CREATE TABLE products (
  product_id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  sku              text          NOT NULL UNIQUE,
  name             text          NOT NULL,
  category_id      integer       NOT NULL REFERENCES categories (category_id),
  supplier_id      integer       REFERENCES suppliers (supplier_id),
  unit_price_cents integer       NOT NULL CHECK (unit_price_cents > 0),
  weight_kg        numeric(6,2),
  is_active        boolean       NOT NULL DEFAULT true,
  created_at       timestamptz   NOT NULL DEFAULT now()
);

CREATE TABLE customers (
  customer_id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name       text    NOT NULL,
  last_name        text    NOT NULL,
  email            text    NOT NULL UNIQUE,
  phone            text,
  city             text,
  signup_date      date    NOT NULL,
  marketing_opt_in boolean NOT NULL DEFAULT false,
  referred_by      integer REFERENCES customers (customer_id)
);

CREATE TABLE employees (
  employee_id  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name   text    NOT NULL,
  last_name    text    NOT NULL,
  title        text    NOT NULL,
  department   text    NOT NULL,
  manager_id   integer REFERENCES employees (employee_id),
  hire_date    date    NOT NULL,
  salary_cents integer NOT NULL
);

CREATE TABLE orders (
  order_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id integer     NOT NULL REFERENCES customers (customer_id),
  employee_id integer     REFERENCES employees (employee_id),
  status      text        NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'refunded')),
  ordered_at  timestamptz NOT NULL,
  shipped_at  timestamptz
);

CREATE TABLE order_items (
  order_item_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id         integer      NOT NULL REFERENCES orders (order_id),
  product_id       integer      NOT NULL REFERENCES products (product_id),
  quantity         integer      NOT NULL CHECK (quantity > 0),
  unit_price_cents integer      NOT NULL,
  discount_pct     numeric(5,2),
  UNIQUE (order_id, product_id)
);

CREATE TABLE payments (
  payment_id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id     integer     NOT NULL REFERENCES orders (order_id),
  amount_cents integer     NOT NULL,
  method       text        NOT NULL CHECK (method IN ('card', 'paypal', 'transfer')),
  paid_at      timestamptz NOT NULL
);

CREATE TABLE reviews (
  review_id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id  integer     NOT NULL REFERENCES products (product_id),
  customer_id integer     NOT NULL REFERENCES customers (customer_id),
  rating      integer     NOT NULL CHECK (rating BETWEEN 1 AND 5),
  body        text,
  created_at  timestamptz NOT NULL
);

CREATE TABLE product_specs (
  product_id integer PRIMARY KEY REFERENCES products (product_id),
  specs      jsonb   NOT NULL
);
