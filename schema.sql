-- =====================================================================
-- Farmers Market Database: schema.sql
-- Target DBMS: Microsoft SQL Server
--
-- Run once before this script:  CREATE DATABASE farmers_market;
-- WARNING: This script drops and recreates every table, deleting their
-- data. Run it only against a development database.
-- =====================================================================

USE farmers_market;
GO

-- Drop in reverse dependency order (child tables first).
DROP TABLE IF EXISTS po_line;
DROP TABLE IF EXISTS preorder;
DROP TABLE IF EXISTS market_vendor_product;
DROP TABLE IF EXISTS market_product;   -- table from an earlier version of this schema
DROP TABLE IF EXISTS vendor_product;
DROP TABLE IF EXISTS market_vendor;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS market;
DROP TABLE IF EXISTS vendor;
GO

-- ---------------------------------------------------------------------
-- Core entity tables
-- IDs are generated automatically by IDENTITY.
-- ---------------------------------------------------------------------

-- Farmers and vendors who sell at markets.
CREATE TABLE vendor (
    vendor_id       INT IDENTITY(1,1) NOT NULL,
    vendor_name     VARCHAR(100)  NOT NULL,
    vendor_contact  VARCHAR(100),
    vendor_bio      VARCHAR(2000),
    vendor_location VARCHAR(200),
    CONSTRAINT pk_vendor PRIMARY KEY (vendor_id)
);

-- Individual farmers markets.
CREATE TABLE market (
    market_id       INT IDENTITY(1,1) NOT NULL,
    market_name     VARCHAR(100) NOT NULL,
    market_address  VARCHAR(200) NOT NULL,
    operating_hours VARCHAR(100),
    CONSTRAINT pk_market PRIMARY KEY (market_id)
);

-- Products, described once regardless of who sells them.
CREATE TABLE product (
    product_id          INT IDENTITY(1,1) NOT NULL,
    product_name        VARCHAR(100)  NOT NULL,
    product_type        VARCHAR(50),
    product_description VARCHAR(2000),
    CONSTRAINT pk_product PRIMARY KEY (product_id)
);

-- Customers who place pre-orders.
CREATE TABLE customer (
    customer_id         INT IDENTITY(1,1) NOT NULL,
    customer_first_name VARCHAR(50)  NOT NULL,
    customer_last_name  VARCHAR(50)  NOT NULL,
    customer_email      VARCHAR(254) NOT NULL,
    customer_phone      VARCHAR(25),
    CONSTRAINT pk_customer PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email UNIQUE (customer_email)
);

-- ---------------------------------------------------------------------
-- Relationship (junction) tables
-- ---------------------------------------------------------------------

-- Which vendors attend which markets, and each vendor's booth there.
-- A vendor can attend many markets; a market hosts many vendors.
CREATE TABLE market_vendor (
    market_id           INT NOT NULL,
    vendor_id           INT NOT NULL,
    vendor_booth_number VARCHAR(20),
    CONSTRAINT pk_market_vendor PRIMARY KEY (market_id, vendor_id),
    CONSTRAINT fk_market_vendor_market FOREIGN KEY (market_id)
        REFERENCES market (market_id),
    CONSTRAINT fk_market_vendor_vendor FOREIGN KEY (vendor_id)
        REFERENCES vendor (vendor_id)
);

-- Which products each vendor sells, and that vendor's price.
-- A vendor charges the same price at every market it attends.
CREATE TABLE vendor_product (
    vendor_id  INT NOT NULL,
    product_id INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_vendor_product PRIMARY KEY (vendor_id, product_id),
    CONSTRAINT fk_vendor_product_vendor FOREIGN KEY (vendor_id)
        REFERENCES vendor (vendor_id),
    CONSTRAINT fk_vendor_product_product FOREIGN KEY (product_id)
        REFERENCES product (product_id),
    CONSTRAINT ck_vendor_product_unit_price CHECK (unit_price >= 0)
);

-- Which products a vendor brings to a specific market, and how many
-- units that vendor has in stock there.
-- The two composite foreign keys guarantee the vendor attends the market
-- (market_vendor) and actually sells the product (vendor_product).
CREATE TABLE market_vendor_product (
    market_id          INT NOT NULL,
    vendor_id          INT NOT NULL,
    product_id         INT NOT NULL,
    inventory_quantity INT NOT NULL
        CONSTRAINT df_market_vendor_product_inventory DEFAULT 0,
    CONSTRAINT pk_market_vendor_product
        PRIMARY KEY (market_id, vendor_id, product_id),
    CONSTRAINT fk_market_vendor_product_market_vendor
        FOREIGN KEY (market_id, vendor_id)
        REFERENCES market_vendor (market_id, vendor_id),
    CONSTRAINT fk_market_vendor_product_vendor_product
        FOREIGN KEY (vendor_id, product_id)
        REFERENCES vendor_product (vendor_id, product_id),
    CONSTRAINT ck_market_vendor_product_inventory
        CHECK (inventory_quantity >= 0)
);

-- ---------------------------------------------------------------------
-- Ordering tables
-- ---------------------------------------------------------------------

-- One row per customer pre-order, picked up at a single market.
-- The order total is not stored; it is calculated from po_line as
-- SUM(quantity * unit_price_at_order).
-- status is limited to the four stages of a pre-order, and the pickup
-- date cannot fall before the date the order was placed.
CREATE TABLE preorder (
    preorder_id INT IDENTITY(1,1) NOT NULL,
    customer_id INT NOT NULL,
    market_id   INT NOT NULL,
    pickup_date DATE NOT NULL,
    order_date  DATETIME2 NOT NULL
        CONSTRAINT df_preorder_order_date DEFAULT CURRENT_TIMESTAMP,
    status      VARCHAR(30) NOT NULL
        CONSTRAINT df_preorder_status DEFAULT 'Pending',
    CONSTRAINT pk_preorder PRIMARY KEY (preorder_id),
    CONSTRAINT fk_preorder_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),
    CONSTRAINT fk_preorder_market FOREIGN KEY (market_id)
        REFERENCES market (market_id),
    CONSTRAINT ck_preorder_status
        CHECK (status IN ('Pending', 'Ready', 'Picked Up', 'Cancelled')),
    CONSTRAINT ck_preorder_pickup_date
        CHECK (pickup_date >= CAST(order_date AS DATE))
);

-- One row per vendor's product within a pre-order.
-- unit_price_at_order records the price charged when the order was
-- placed, so past orders keep their price if the vendor changes it later.
-- The pre-order transaction verifies that the vendor brings this product
-- to the pre-order's market (market_vendor_product) and reduces inventory.
CREATE TABLE po_line (
    preorder_id         INT NOT NULL,
    vendor_id           INT NOT NULL,
    product_id          INT NOT NULL,
    quantity            INT NOT NULL,
    unit_price_at_order DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_po_line PRIMARY KEY (preorder_id, vendor_id, product_id),
    CONSTRAINT fk_po_line_preorder FOREIGN KEY (preorder_id)
        REFERENCES preorder (preorder_id) ON DELETE CASCADE,
    CONSTRAINT fk_po_line_vendor_product FOREIGN KEY (vendor_id, product_id)
        REFERENCES vendor_product (vendor_id, product_id),
    CONSTRAINT ck_po_line_quantity CHECK (quantity > 0),
    CONSTRAINT ck_po_line_unit_price_at_order CHECK (unit_price_at_order >= 0)
);
GO
