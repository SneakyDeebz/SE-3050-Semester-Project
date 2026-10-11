# Database Normalization

## Overview

The schema in [schema.sql](schema.sql) contains nine tables. Every table is in Third Normal Form (3NF), and every table also meets Boyce-Codd Normal Form (BCNF). This document shows the functional dependencies for each table, checks them against each normal form, and explains the design decisions that keep the schema normalized.

The definitions used below follow the course slides for Chapter 6 (Relational Databases).

## Tables and Keys

| Table | Primary key | Purpose |
| --- | --- | --- |
| `vendor` | `vendor_id` | Farmers and vendors |
| `market` | `market_id` | Farmers markets |
| `product` | `product_id` | Products, described once |
| `customer` | `customer_id` (alternate key: `customer_email`) | Customers who place pre-orders |
| `preorder` | `preorder_id` | One pre-order, picked up at one market |
| `market_vendor` | `(market_id, vendor_id)` | Which vendors attend which markets |
| `vendor_product` | `(vendor_id, product_id)` | Which products each vendor sells, and at what price |
| `market_vendor_product` | `(market_id, vendor_id, product_id)` | Which products a vendor brings to a market, and how many are in stock |
| `po_line` | `(preorder_id, vendor_id, product_id)` | One vendor's product within a pre-order |

## Functional Dependencies

These functional dependencies hold in the schema, and every other non-trivial dependency follows from them. In every one, the left side is a candidate key of its table.

| Table | Functional dependency |
| --- | --- |
| `vendor` | `vendor_id → vendor_name, vendor_contact, vendor_bio, vendor_location` |
| `market` | `market_id → market_name, market_address, operating_hours` |
| `product` | `product_id → product_name, product_type, product_description` |
| `customer` | `customer_id → customer_first_name, customer_last_name, customer_email, customer_phone` |
| `customer` | `customer_email → customer_id, customer_first_name, customer_last_name, customer_phone` |
| `preorder` | `preorder_id → customer_id, market_id, pickup_date, order_date, status` |
| `market_vendor` | `(market_id, vendor_id) → vendor_booth_number` |
| `vendor_product` | `(vendor_id, product_id) → unit_price` |
| `market_vendor_product` | `(market_id, vendor_id, product_id) → inventory_quantity` |
| `po_line` | `(preorder_id, vendor_id, product_id) → quantity, unit_price_at_order` |

## First Normal Form (1NF)

A relation is in 1NF when every attribute type is atomic and single-valued, with no composite or multivalued attribute types (Chapter 6, slide 32).

- **Composite attributes are split.** Customer names are stored as `customer_first_name` and `customer_last_name`, not as one combined name.
- **Multivalued facts get their own rows.** A pre-order does not store a list of products. Each product in an order is its own `po_line` row. A vendor's markets, products, and stock are likewise stored one association per row in `market_vendor`, `vendor_product`, and `market_vendor_product`.
- **Every table has a primary key,** so every row is uniquely identifiable.

Two attributes hold descriptive text by design: `market.operating_hours` (for example, "Sat 8 AM–1 PM") and `vendor.vendor_contact`. The application displays each as one value and never searches or calculates on its parts, so each is treated as a single atomic value. If the application later needs hours per day, they would move to a separate table with one row per market and day, following the department-location example on Chapter 6, slide 33.

**Result:** all nine tables are in 1NF.

## Second Normal Form (2NF)

A relation is in 2NF when it is in 1NF and every non-prime attribute type is fully functionally dependent on any key of the relation, meaning no attribute depends on only part of a composite key (Chapter 6, slides 36–37).

- **Single-column keys:** `vendor`, `market`, `product`, `customer`, and `preorder` have one-column primary keys, so a partial dependency is impossible.
- **Composite keys:** each non-key attribute needs the entire key.
  - `vendor_booth_number` needs both the market and the vendor. The same vendor can have a different booth at each market.
  - `unit_price` needs both the vendor and the product. Different vendors can charge different prices for the same product.
  - `inventory_quantity` needs all three of market, vendor, and product. Stock belongs to one vendor's product at one market.
  - `quantity` and `unit_price_at_order` need all three of pre-order, vendor, and product. They describe one line of one order.

**A partial dependency this design avoids:** an earlier draft stored `market_id` in `po_line` as well as in `preorder`. Since `preorder_id → market_id`, that column depended on only part of `po_line`'s key, which violates 2NF. The current schema stores the market only in `preorder`, and each line reaches it through `preorder_id`.

**Result:** all nine tables are in 2NF.

## Third Normal Form (3NF)

A relation is in 3NF when it is in 2NF and no non-prime attribute type is transitively dependent on the primary key, meaning no non-key attribute determines another non-key attribute (Chapter 6, slide 40).

- **`preorder`** stores `customer_id` and `market_id` as foreign keys only. Customer names and market addresses stay in `customer` and `market`, so no customer or market detail depends on `preorder_id` through another column.
- **`vendor_product`** holds the price. Price is not stored on `product`, because price depends on which vendor sells it, not on the product alone.
- **`market_vendor_product`** holds stock. Stock is not stored on `product` or `market`, because it depends on the vendor, the product, and the market together.
- **No calculated values are stored.** The order total is not a column. It is calculated when needed as `SUM(quantity * unit_price_at_order)` across an order's `po_line` rows, so it can never fall out of sync with the lines.

**`unit_price_at_order` is not redundant.** It may look like a copy of `vendor_product.unit_price`, but it is a separate fact: the price charged when the order was placed. If a vendor later changes its price, `vendor_product.unit_price` changes while every past order keeps the price the customer actually agreed to. The value is fully determined by its own `po_line` row, not by `vendor_product`, so it creates no transitive dependency.

**Result:** all nine tables are in 3NF.

## Boyce-Codd Normal Form (BCNF)

A relation is in BCNF when the left side of every non-trivial functional dependency is a superkey (Chapter 6, slide 43). In the functional dependency table above, every left side is a candidate key of its table. This includes `customer_email`, which is unique and determines every other customer attribute.

**Result:** all nine tables are also in BCNF.

## Mapping the ERD to Tables

The schema follows the ER-to-relational mapping rules from Chapter 6.

| ERD element | Mapped to | Mapping rule |
| --- | --- | --- |
| Entities VENDOR, MARKET, PRODUCT, CUSTOMER, PREORDER | One table each | Entity types (slide 49) |
| PLACES (each pre-order is placed by exactly one customer) | `preorder.customer_id`, a NOT NULL foreign key | Binary 1:N (slides 55–56) |
| PICKED_UP_AT (each pre-order is picked up at exactly one market) | `preorder.market_id`, a NOT NULL foreign key | Binary 1:N (slides 55–56) |
| ATTENDS (M:N, with `vendor_booth_number`) | `market_vendor` | Binary M:N (slides 58–60) |
| SELLS (M:N, with `unit_price`) | `vendor_product` | Binary M:N (slides 58–60) |
| STOCKS (ternary: market, vendor, product) | `market_vendor_product` | n-ary (slides 66–68) |
| INCLUDES (ternary: pre-order, vendor, product) | `po_line` | n-ary (slides 66–68) |

STOCKS and INCLUDES are ternary relationships. Following Chapter 6, slides 66–68, each maps to one table whose primary key combines the foreign keys of all three participating entities, and the relationship's attributes become columns of that table. Chapter 3, slides 23–24 explain why these relationships cannot be split into separate binary ones without losing information. Knowing that a vendor sells honey and attends Market 1 does not tell you whether that vendor brings honey to Market 1.

## Rules the ERD Cannot Show, and Where They Are Enforced

The ER model cannot guarantee consistency across multiple relationship types, and it does not include domains (allowed values) (Chapter 3, slides 29–30). The rules below fall into those categories. Each is enforced by either the schema or the pre-order transaction.

| Rule | Enforced by |
| --- | --- |
| A vendor can only stock a product at a market if that vendor attends the market and sells the product | Schema: `market_vendor_product` has composite foreign keys to `market_vendor` and `vendor_product` |
| An order line can only use a product the vendor sells | Schema: `po_line` has a composite foreign key to `vendor_product` |
| An order line can only use a product the vendor brings to the pre-order's market | Pre-order transaction: checks `market_vendor_product` for the pre-order's market before inserting each line |
| An order cannot exceed available stock | Pre-order transaction: checks `inventory_quantity`, then reduces it for each line |
| A pre-order must contain at least one item | Pre-order transaction: rolls back if no lines are inserted |
| Each order line records the price charged at the time of the order | Pre-order transaction: copies `vendor_product.unit_price` into `unit_price_at_order` |
| Prices and stock cannot be negative, and quantities must be positive | Schema: CHECK constraints |
| Status must be one of Pending, Ready, Picked Up, or Cancelled | Schema: CHECK constraint `ck_preorder_status` |
| A pickup date cannot fall before the order date | Schema: CHECK constraint `ck_preorder_pickup_date` |
| Each customer email is used only once | Schema: UNIQUE constraint `uq_customer_email` |

The pre-order transaction is part of the application built for the final submission, and its steps are listed in the README. It runs all of its steps as one unit. If any check fails, the entire pre-order is rolled back, so the database never holds a partial order or an incorrect stock count.

## Assumptions

- A vendor charges the same price for a product at every market it attends.
- `inventory_quantity` is a vendor's current available stock of a product at a market. It is not tracked separately for each market day.
- Each pre-order is picked up at one market but can include products from several vendors at that market.
