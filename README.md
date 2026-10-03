# SE-3050-Semester-Project
This is a repository for a semester long project at the University of Minnesota Crookson for course SE 3050 (E90)

Team Members- Gavin Sullivan, Travis Gurske, and Max Netteberg

GitHubt Projects URL - https://github.com/users/SneakyDeebz/projects/1/views/1

<img width="2532" height="1188" alt="image" src="https://github.com/user-attachments/assets/b7dcfbdc-a35c-4231-b5df-b0b186955cd5" />

Project Proposal

Project Overview:

Our project will be a farmers market management and pre-ordering application designed to connect customers with local farmers and vendors.  The application will provide users with an easy way to browse farmers markets, view the vendors participating in each market, search for products, and place pre-orders for products they would like to pick up at market.  

The application will use a relational database to store information about farmers markets, vendors, products, product availability, customers, and pre-orders. The database will be designed to maintain relationships between these entities while allowing the application to efficiently search for products and process customer orders.  

Application Features:

The application will provide the following core features:

Browse Farmers Markets: Users will be able to view a list of available farmers markets. Each market will include information such as its name, location, operating days and hours, and other relevant details.
View Market Details: Users will be able to select a specific market and view its details, including the vendors participating in that market.
View Vendor Information: The application will display information about vendors and the products they offer at participating markets. 
Search Products: Users will be able to search for products across all markets. Search results will provide information about the product, vendor, market where it is available, price, and available quantity.
View Product Availability: Products will be associated with specific vendors and markets so that the application can display market specific pricing and inventory information.
Place Pre-Orders: Customers will be able to select available products and quantities and submit a pre-order for pickup at a selected farmers market.
Order Management: The database will store each pre-order and its individual order items, including the products ordered, quantities, prices, and order status.
Inventory Management: Product listings will maintain available quantities so that the application can prevent customers from ordering more products than a vendor has available.  



Technology Stack:
 
The application will be developed using the .NET framework, which provides strong support for relational databases, structured application design, and user interface development. .NET will allow the team to build a reliable backend for processing orders and managing data, along with a clean and responsive graphical user interface for customers and vendors.

Database Design:

The application will use a relational database consisting of entities representing farmers markets, vendors, products, customers, pre-orders, and the individual products included in each pre-order.

The database will establish relationships between these entities to support the application’s major features and ensure that information is organized without unnecessary duplication.

The primary entities in the database will include:

Market - Stores information about individual farmers markets, including ID, name, address, and operating hours.
Vendor - Stores information about farmers and other vendors, including their vendor ID, name, contact information, location, and business biography or description.
Market_Vendor - Represents the relationship between vendors and farmers markets. Because a vendor may participate in multiple markets and a market may have multiple vendors, this relationship allows the database to represent the many-to-many relationship between vendors and markets. The relationship also stores the vendor’s booth number at a particular market.
Product - Stores information about products sold by vendors, including the product ID, name, type, description, and a unit price.
Market_Product - Stores market‑specific product information, including the vendor offering the product, the market where it is available, the price at that market, and the available quantity. This table supports inventory tracking and ensures that product availability is tied to specific markets rather than global product listings.
Customer - Stores information about customers who use the application to place pre-orders. Customer information will include their name, email address, and phone number.
Pre-Order - Stores information about customer pre-orders, including the customer placing the order, the associated market, pickup date, order date, total amount, and order status.
PO_Line - Represents the individual products included in a pre-order.  Each PO_Line connects a product to a specific pre-order and records the quantity requested by the customer.

The relationships between these entities will allow the application to retrieve vendors associated with a market, identify products offered by vendors, determine which products are associated with a market for pickup, and connect customer orders to the products they have requested. 

Entity‑Relationship Diagram (ERD)  

An ERD will be created to visually represent the relationships between markets, vendors, products, customers, pre‑orders, and order line items. This diagram will serve as the blueprint for the database structure and guide the implementation of foreign keys and relational constraints.

Database Constraints  

The database will use foreign keys to enforce relationships between markets, vendors, products, customers, and orders. These constraints will ensure referential integrity, prevent orphaned records, and maintain consistent relationships across the system.

Relationships Between Markets, Vendors, and Products

The database will use a many-to-many relationship between markets and vendors through the MARKET_VENDOR relationship.  This allows a vendor to participate in multiple farmers markets while allowing each market to have multiple vendors.

The MARKET_VENDOR relationship will also store the booth number assigned to a vendor at a particular market.  This allows the same vendor to have different booth locations at different markets.

Vendors will be associated with products through the ‘sells’ relationship.  This allows the database to identify which vendors offer particular products.

Products will also be associated with markets through the ‘pickup_at’ relationship. This allows the application to identify products associated with a particular market and provide customers with information about where products can be picked up.

Pre-Order Process

Customers will be able to create a pre-order by selecting products and specifying the quantities they would like to purchase.  Each pre-order will be associated with a customer and a farmers market, along with a pickup date.

The PREORDER entity will store information about the overall order, while the PO_LINE entity will store the individual products and quantities included in that order.  This structure allows a single pre-order to contain multiple products while maintaining a separate record for each product and quantity.

For example, a customer could create a single pre-order containing


Product
Quantity
Tomatoes
2
Honey
1
Fresh Eggs
2


The PREORDER record would represent the overall order, while three corresponding PO_LINE records would represent the individual products.

Database Transaction

A major requirement of the application is that the process of placing a pre-order will be handled using a database transaction.

When a customer submits an order, the application will create the pre-order and its associated PO_LINE records as part of a single transaction. The transaction will ensure that all records associated with the order are successfully created together.  

If all required database operations are successful, the transaction will be committed. If an operation fails, the transaction will be rolled back so that the database does not contain an incomplete pre-order or only some of its associated order items.

Using a transaction will help maintain the consistency and integrity of the database when customers submit pre-orders.

Sample Data

The database will be populated with realistic sample data for development, testing, and demonstration purposes.

The project will include at least:
10 farmers markets
20 farmers/vendors
50 unique products

Additional customers, pre-orders, and order line items will be included to demonstrate the application’s ordering functionality and provide sufficient data for testing SQL queries.

The sample data will represent realistic relationships between vendors, markets, and products. Vendors may participate in multiple markets, and markets may have multiple vendors and products.

SQL QUERIES

The application will use SQL queries to retrieve and manipulate information stored in the database. The major queries will support the application's primary features including:
Retrieving a list of farmers markets.
Retrieving the details of a specific market.
Finding all vendors participating in a specific market.
Finding products associated with a particular market.
Finding products offered by a particular vendor
Searching for products by name or type.
Finding markets and vendors associated with a particular product.
Retrieving a customer’s pre-orders.
Retrieving the products and quantities included in a pre-order.
Creating and processing new pre-orders.

These queries will demonstrate the use of joins and relationships between multiple database entities.

Application Goals

The primary goal of the project is to demonstrate the complete lifecycle of a relational database application.  The project will progress from designing the database and creating an Entity-Relationship Diagram, to populating the database with realistic sample data, developing SQL queries, and finally creating a graphical user interface that interacts with the database.

The completed application will allow users to browse farmers markets, explore vendors and products, search for products across the database, and place pre-orders for products they wish to pick up at the market.

Through this project, the group will demonstrate how a relational database can be designed to represent a real world system and how that database can support the features of a functional application.  

Summary  

This project will demonstrate the full lifecycle of designing and implementing a relational database application. By combining a structured database, realistic sample data, SQL queries, and a functional .NET user interface, the application will show how relational systems support real‑world workflows such as browsing markets, managing vendors, tracking inventory, and placing customer pre‑orders.
