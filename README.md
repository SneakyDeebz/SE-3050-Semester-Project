# SE-3050 Semester Project

This repository contains the semester project for the University of Minnesota Crookston course SE 3050 (E90).

## Team Members

- Gavin Sullivan
- Travis Gurske
- Max Netteberg

## GitHub Project

- Project board: https://github.com/users/SneakyDeebz/projects/1/views/1

<img width="2532" height="1188" alt="Project planning board screenshot" src="https://github.com/user-attachments/assets/b7dcfbdc-a35c-4231-b5df-b0b186955cd5" />

---

# Project Proposal

## Project Overview

Our project is a farmers market management and pre-ordering application designed to connect customers with local farmers and vendors. The application gives users an easy way to browse farmers markets, view participating vendors, search for products, and place pre-orders for items they want to pick up at the market.

The system will use a relational database to store information about farmers markets, vendors, products, product availability, customers, and pre-orders. The database will maintain relationships between these entities while allowing the application to efficiently search for products and process customer orders.

## Application Features

The application will provide the following core features:

- Browse farmers markets and view their details
- View market-specific vendor information
- Search products across all markets
- View product availability, pricing, and inventory information
- Place pre-orders for pickup at a selected market
- View a customer's pre-orders and their current status
- Track inventory to prevent over-ordering

## Technology Stack

- **Database:** Microsoft SQL Server
- **Application:** The application framework will be confirmed before Milestone 4.

The application will provide a graphical user interface that connects directly to the SQL Server database. The application is built for customers: browsing markets, viewing vendors, searching products, and placing pre-orders. It handles only pre-orders placed through the app. In-person purchases at the market are outside the scope of this project.

---

## Database Design

The application will use a relational database made up of entities representing farmers markets, vendors, products, customers, pre-orders, and the items included in each pre-order.

The database will establish relationships between these entities to support the application’s major features and ensure that information is organized without unnecessary duplication.

### Tables

The database has nine tables, defined in [schema.sql](schema.sql).

| Table | Stores |
| --- | --- |
| `market` | Each farmers market: name, address, and operating hours |
| `vendor` | Each farmer or vendor: name, contact details, business description, and location |
| `product` | Each product: name, type, and description |
| `customer` | Each customer: first name, last name, email address, and phone number |
| `market_vendor` | Which vendors attend which markets, and each vendor's booth number at that market |
| `vendor_product` | Which products each vendor sells, and that vendor's unit price |
| `market_vendor_product` | Which products a vendor brings to a specific market, and how many are in stock there |
| `preorder` | Each pre-order: customer, pickup market, pickup date, order date, and status |
| `po_line` | Each vendor's product within a pre-order: quantity and the price charged when the order was placed |

The order total is not stored. It is calculated from the order's lines as quantity times the price charged.

### Entity-Relationship Diagram (ERD)

![Entity-Relationship Diagram](ERD%20Image.png)

The ERD uses Chen notation. Each (min..max) cardinality is read across the relationship diamond. For example, a pre-order is placed by exactly one (1..1) customer, and a customer places zero or more (0..N) pre-orders.

### Relationships

- **ATTENDS** (`market_vendor`): many-to-many between markets and vendors. A vendor can have a different booth at each market.
- **SELLS** (`vendor_product`): many-to-many between vendors and products. Each vendor sets its own price.
- **STOCKS** (`market_vendor_product`): a three-way relationship between markets, vendors, and products. It records which vendor brings which product to which market, and that vendor's stock there.
- **PLACES** (`preorder.customer_id`): each pre-order is placed by exactly one customer.
- **PICKED_UP_AT** (`preorder.market_id`): each pre-order is picked up at exactly one market.
- **INCLUDES** (`po_line`): a three-way relationship between pre-orders, vendors, and products. Each line records one vendor's product in the order.

### Database Constraints

- **Foreign keys** link every table that references another table, so no pre-order, order line, booth, price, or stock record can point to a market, vendor, product, customer, or pre-order that does not exist.
- **Composite foreign keys** on `market_vendor_product` ensure a vendor can only stock a product at a market if the vendor attends that market and sells that product.
- **CHECK constraints** keep prices and stock from going negative, require order quantities to be positive, limit pre-order status to Pending, Ready, Picked Up, or Cancelled, and prevent a pickup date earlier than the order date.
- **A UNIQUE constraint** ensures each customer email is used only once.

### Rules Enforced Outside the ERD

The ER model cannot guarantee consistency across multiple relationship types (Chapter 3, slide 29). The following rules are therefore enforced by the application's pre-order transaction (see Database Transaction below) rather than shown in the ERD:

- Each order line must be a product the vendor brings to the pre-order's market.
- An order cannot request more than the vendor's available stock at that market.
- Each pre-order must contain at least one item.

See [Normalization.md](Normalization.md) for how the design achieves Third Normal Form and where each rule is enforced.

---

## Pre-Order Process

Customers will be able to create a pre-order by selecting products and specifying the quantities they want to purchase. Each pre-order will be associated with a customer and a farmers market, along with a pickup date.

The `preorder` table stores the overall order, while the `po_line` table (the INCLUDES relationship in the ERD) stores each vendor's product and quantity in that order. This structure allows a single pre-order to contain several products from several vendors at the same market, with a separate record for each.

For example, a customer could submit a single pre-order containing:

| Vendor | Product | Quantity |
| --- | --- | ---: |
| Green Acres Farm | Tomatoes | 2 |
| Prairie Bee Co. | Honey | 1 |
| Green Acres Farm | Fresh Eggs | 2 |

The `preorder` record would represent the overall order, while three corresponding `po_line` records would represent the individual items.

## Database Transaction

Placing a pre-order will be handled using a database transaction.

When a customer submits an order, the application performs these steps inside a single transaction:

1. Create the `preorder` record for the customer, pickup market, and pickup date.
2. For each item in the order:
   - Confirm the vendor brings that product to the pre-order's market (`market_vendor_product`).
   - Confirm the requested quantity does not exceed the vendor's available stock there.
   - Insert the `po_line` record, copying the vendor's current unit price into `unit_price_at_order`.
   - Reduce the vendor's `inventory_quantity` at that market by the quantity ordered.
3. Confirm the order contains at least one item.

If every step succeeds, the transaction is committed. If any step fails, the entire transaction is rolled back, so the database never contains an incomplete pre-order, a partial set of order items, or an incorrect stock count.

Using transactions will help maintain the consistency and integrity of the database when customers submit pre-orders.

---

## Sample Data

The database will be populated with realistic sample data for development, testing, and demonstration purposes.

The project will include at least:

- 10 farmers markets
- 20 farmers/vendors
- 50 unique products

Additional customers, pre-orders, and order line items will be included to demonstrate the application’s ordering functionality and provide enough data for testing SQL queries.

The sample data will represent realistic relationships between vendors, markets, and products. Vendors may participate in multiple markets, and markets may have multiple vendors and products.

---

## SQL Queries

The application will use SQL queries to retrieve and manipulate information stored in the database. The major queries will support the application’s primary features, including:

- Retrieving a list of farmers markets
- Retrieving the details of a specific market
- Finding all vendors participating in a specific market
- Finding products associated with a particular market
- Finding products offered by a particular vendor
- Searching for products by name or type
- Finding markets and vendors associated with a particular product
- Retrieving a customer’s pre-orders
- Retrieving the products and quantities included in a pre-order
- Creating and processing new pre-orders

These queries will demonstrate the use of joins and relationships between multiple database entities.

---

## Application Goals

The primary goal of this project is to demonstrate the complete lifecycle of a relational database application. The project will progress from designing the database and creating an Entity-Relationship Diagram, to populating the database with realistic sample data, developing SQL queries, and finally creating a graphical user interface that interacts with the database.

The completed application will allow users to browse farmers markets, explore vendors and products, search for products across the database, and place pre-orders for items they want to pick up at the market.

Through this project, the group will demonstrate how a relational database can represent a real-world system and how that database can support the features of a functional application.

---

## Summary

This project will demonstrate the full lifecycle of designing and implementing a relational database application. By combining a structured database, realistic sample data, SQL queries, and a functional graphical user interface, the application will show how relational systems support real-world workflows such as browsing markets, viewing vendors, searching products, tracking inventory, and placing customer pre-orders.
