-- Farmers Market Database
-- Run this line first: CREATE DATABASE farmers_market; 
use farmers_market;
GO

-- WARNING: Running this script drops and recreates these tables, deleting their data.
-- IDs are supplied explicitly when inserting rows.

DROP TABLE IF EXISTS po_line;
DROP TABLE IF EXISTS preorder;
DROP TABLE IF EXISTS market_product;
DROP TABLE IF EXISTS vendor_product;
DROP TABLE IF EXISTS market_vendor;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS market;
DROP TABLE IF EXISTS vendor;

CREATE TABLE vendor (
    vendor_id INTEGER PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    vendor_contact VARCHAR(100),
    vendor_bio VARCHAR(2000),
    vendor_location VARCHAR(200)
);

CREATE TABLE market (
    market_id INTEGER PRIMARY KEY,
    market_name VARCHAR(100) NOT NULL,
    market_address VARCHAR(200) NOT NULL,
    operating_hours VARCHAR(100)
);

CREATE TABLE product (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    product_type VARCHAR(50),
    product_description VARCHAR(2000)
);

CREATE TABLE customer (
    customer_id INTEGER PRIMARY KEY,
    customer_first_name VARCHAR(50) NOT NULL,
    customer_last_name VARCHAR(50) NOT NULL,
    customer_email VARCHAR(254) NOT NULL,
    customer_phone VARCHAR(25),
    CONSTRAINT uq_customer_email UNIQUE (customer_email)
);

-- A vendor can participate in multiple markets, and a market can host multiple vendors.
CREATE TABLE market_vendor (
    market_id INTEGER NOT NULL,
    vendor_id INTEGER NOT NULL,
    vendor_booth_number VARCHAR(20),
    CONSTRAINT pk_market_vendor PRIMARY KEY (market_id, vendor_id),
    CONSTRAINT fk_market_vendor_market FOREIGN KEY (market_id)
        REFERENCES market (market_id),
    CONSTRAINT fk_market_vendor_vendor FOREIGN KEY (vendor_id)
        REFERENCES vendor (vendor_id)
);

-- A vendor can sell multiple products, and a product can be sold by multiple vendors.
CREATE TABLE vendor_product (
    vendor_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_vendor_product PRIMARY KEY (vendor_id, product_id),
    CONSTRAINT fk_vendor_product_vendor FOREIGN KEY (vendor_id)
        REFERENCES vendor (vendor_id),
    CONSTRAINT fk_vendor_product_product FOREIGN KEY (product_id)
        REFERENCES product (product_id),
    CONSTRAINT ck_vendor_product_unit_price_nonnegative CHECK (unit_price >= 0)
);

-- Products can be available at multiple markets.
CREATE TABLE market_product (
    market_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    inventory_quantity INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT pk_market_product PRIMARY KEY (market_id, product_id),
    CONSTRAINT fk_market_product_market FOREIGN KEY (market_id)
        REFERENCES market (market_id),
    CONSTRAINT fk_market_product_product FOREIGN KEY (product_id)
        REFERENCES product (product_id),
    CONSTRAINT ck_market_product_inventory_nonnegative CHECK (inventory_quantity >= 0)
);

CREATE TABLE preorder (
    preorder_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    market_id INTEGER NOT NULL,
    pickup_date DATE NOT NULL,
    order_date DATETIME2 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_preorder_customer FOREIGN KEY (customer_id)
        REFERENCES customer (customer_id),
    CONSTRAINT fk_preorder_market FOREIGN KEY (market_id)
        REFERENCES market (market_id),
    CONSTRAINT uq_preorder_market UNIQUE (preorder_id, market_id),
    CONSTRAINT ck_preorder_total_amount_nonnegative CHECK (total_amount >= 0)
);

CREATE TABLE po_line (
    preorder_id INTEGER NOT NULL,
    market_id INTEGER NOT NULL,
    vendor_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    CONSTRAINT pk_po_line PRIMARY KEY (preorder_id, vendor_id, product_id),
    CONSTRAINT fk_po_line_preorder_market FOREIGN KEY (preorder_id, market_id)
        REFERENCES preorder (preorder_id, market_id) ON DELETE CASCADE,
    CONSTRAINT fk_po_line_market_product FOREIGN KEY (market_id, product_id)
        REFERENCES market_product (market_id, product_id),
    CONSTRAINT fk_po_line_market_vendor FOREIGN KEY (market_id, vendor_id)
        REFERENCES market_vendor (market_id, vendor_id),
    CONSTRAINT fk_po_line_vendor_product FOREIGN KEY (vendor_id, product_id)
        REFERENCES vendor_product (vendor_id, product_id),
    CONSTRAINT ck_po_line_quantity_positive CHECK (quantity > 0)
);
