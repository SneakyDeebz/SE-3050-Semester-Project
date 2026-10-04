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
- Manage order records and statuses
- Track inventory to prevent over-ordering

## Technology Stack

The application will be developed using the .NET framework, which provides strong support for relational databases, structured application design, and user interface development. .NET will allow the team to build a reliable backend for processing orders and managing data, along with a clean and responsive graphical interface for customers and vendors.

---

## Database Design

The application will use a relational database made up of entities representing farmers markets, vendors, products, customers, pre-orders, and the items included in each pre-order.

The database will establish relationships between these entities to support the application’s major features and ensure that information is organized without unnecessary duplication.

### Primary Entities

- Market: stores information about individual farmers markets, including ID, name, address, and operating hours.
- Vendor: stores vendor information, including vendor ID, name, contact details, location, and business description.
- Market_Vendor: represents the many-to-many relationship between vendors and markets, including booth assignment at each market.
- Product: stores product information, including ID, name, type, description, and unit price.
- Market_Product: stores market-specific pricing and inventory information for each product.
- Customer: stores customer details, including name, email address, and phone number.
- Pre-Order: stores overall order details such as customer, market, pickup date, order date, total amount, and status.
- PO_Line: represents the individual products included in a pre-order and records quantity requested.

These relationships allow the application to retrieve vendors associated with a market, identify available products by vendor or market, and connect customer orders to the products they have requested.

### Entity-Relationship Diagram (ERD)

An ERD will be created to visually represent the relationships between markets, vendors, products, customers, pre-orders, and order line items. This diagram will serve as the blueprint for the database structure and guide the implementation of foreign keys and relational constraints.

### Database Constraints

The database will use foreign keys to enforce relationships between markets, vendors, products, customers, and orders. These constraints will ensure referential integrity, prevent orphaned records, and maintain consistent relationships across the system.

### Relationships Between Markets, Vendors, and Products

- Many-to-many relationship between markets and vendors through the `MARKET_VENDOR` table.
- Booth numbers are tracked in the relationship to allow a vendor to have different market locations.
- Vendors are associated with products through a sells relationship.
- Products are associated with markets through a pickup_at relationship for market-specific availability.

---

## Pre-Order Process

Customers will be able to create a pre-order by selecting products and specifying the quantities they want to purchase. Each pre-order will be associated with a customer and a farmers market, along with a pickup date.

The `PREORDER` entity stores information about the overall order, while the `PO_LINE` entity stores the individual products and quantities included in that order. This structure allows a single pre-order to contain multiple products while maintaining a separate record for each product and quantity.

For example, a customer could submit a single pre-order containing:

| Product | Quantity |
| --- | ---: |
| Tomatoes | 2 |
| Honey | 1 |
| Fresh Eggs | 2 |

The `PREORDER` record would represent the overall order, while three corresponding `PO_LINE` records would represent the individual items.

## Database Transaction

Placing a pre-order will be handled using a database transaction.

When a customer submits an order, the application will create the pre-order and its associated `PO_LINE` records as part of a single transaction. This ensures that all related records are created together.

If all required database operations are successful, the transaction will be committed. If an operation fails, the transaction will be rolled back so the database does not contain an incomplete pre-order or only a partial set of its associated order items.

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

This project will demonstrate the full lifecycle of designing and implementing a relational database application. By combining a structured database, realistic sample data, SQL queries, and a functional .NET user interface, the application will show how relational systems support real-world workflows such as browsing markets, managing vendors, tracking inventory, and placing customer pre-orders.
