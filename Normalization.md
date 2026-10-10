# Database Normalization

## Overview

The schema in [schema.sql](schema.sql) separates customers, vendors, markets, products, preorders, and preorder lines into related tables. This reduces repeated facts and helps avoid insertion, update, and deletion anomalies. Most tables follow 1NF, 2NF, and 3NF. `po_line.market_id` is intentionally repeated from `preorder` so composite foreign keys can enforce market availability; this creates a partial dependency and is an exception to strict 2NF. `preorder.total_amount` is a separate derived-summary caveat described below.

## First Normal Form (1NF)

A table is in 1NF when each row is identifiable, each column holds one value per row, and there are no repeating groups or lists stored in a column.

Each table has a primary key. Customer names, email, and phone are stored as separate attributes. A preorder does not contain a list of products in one field: each vendor's product in an order has its own row in `po_line`, identified by `(preorder_id, vendor_id, product_id)`. The junction tables likewise store one market-vendor, vendor-product, or market-product association per row.

## Second Normal Form (2NF)

A table is in 2NF when it is in 1NF and every non-key attribute depends on the whole candidate key, not just part of a composite key.

Tables with a single-column primary key have no partial-key dependency. In tables with composite keys, the non-key values depend on the complete pair:

- `market_vendor`: `(market_id, vendor_id) -> vendor_booth_number`. A booth assignment belongs to a particular vendor at a particular market.
- `vendor_product`: `(vendor_id, product_id) -> unit_price`. The price belongs to a vendor's offering of a product.
- `market_product`: `(market_id, product_id) -> inventory_quantity`. The stock count belongs to a product at a particular market.
- `po_line`: `(preorder_id, vendor_id, product_id) -> quantity`. The quantity belongs to a vendor's product within a particular preorder.
- The non-key attributes of `vendor_product` and `market_product` depend on their complete composite keys.

`po_line.market_id` is also stored so the line can reference both `(preorder_id, market_id)` and `(market_id, product_id)` with foreign keys. Since `preorder_id -> market_id`, this repeats a value determined by part of the `po_line` key and is a deliberate 2NF exception. Removing the repeated column would require application-level validation instead of these declarative foreign keys.

## Third Normal Form (3NF)

A table is in 3NF when it is in 2NF and its non-key attributes depend on a key, the whole key, and nothing but a key. In other words, descriptive attributes are not stored in a table where they depend on another non-key attribute.

The main functional dependencies in the schema are:

- `vendor_id -> vendor_name, vendor_contact, vendor_bio, vendor_location`
- `market_id -> market_name, market_address, operating_hours`
- `product_id -> product_name, product_type, product_description`
- `customer_id -> customer_first_name, customer_last_name, customer_email, customer_phone`
- `preorder_id -> customer_id, market_id, pickup_date, order_date, total_amount, status`
- `(market_id, vendor_id) -> vendor_booth_number`
- `(vendor_id, product_id) -> unit_price`
- `(market_id, product_id) -> inventory_quantity`
- `preorder_id -> market_id` (also repeated on each `po_line`)
- `(preorder_id, vendor_id, product_id) -> market_id, quantity`

Product details are stored once in `product`; a vendor's price for a product is stored once in `vendor_product`, rather than repeated for each market or order line. This design assumes a vendor uses the same price at all markets. Customer details are stored once in `customer`; `preorder` refers to the customer by `customer_id` rather than copying their name and contact information. `po_line.market_id` repeats the preorder's market key so foreign keys can ensure each line's product is offered at that market and its vendor participates there.

`customer_email` is also declared unique, making it an alternate key for identifying a customer. The junction tables represent many-to-many relationships without duplicating the entities they connect.

## Order Total Note

`preorder.total_amount` is an order-level summary. If it is maintained as the sum of each line's `quantity * vendor_product.unit_price`, it duplicates a value that can be derived from `po_line` and `vendor_product`. The schema does not automatically calculate or synchronize this total. The application should update it in the same transaction as the order lines, or calculate it when reading orders to avoid stale totals.

The current schema stores the vendor's current `unit_price`, not a price snapshot on each order line. If prices can change and past orders must retain the price charged at purchase time, add a `unit_price_at_order` column to `po_line` and use that value to calculate historical totals. `market_product.inventory_quantity` records stock but does not by itself decrement inventory or prevent concurrent over-ordering; that requires transactional inventory handling in the application or a database procedure.

## Summary

The entity and junction tables keep most facts in their natural location. The deliberate `po_line.market_id` duplication is an exception to strict 2NF, and `preorder.total_amount` is a derived summary that must be kept consistent with detail rows. For strict normalization, remove the repeated market key and enforce market compatibility in application logic instead of foreign keys.
