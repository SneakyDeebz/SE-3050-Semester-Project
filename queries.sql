-- SE-3050 Farmers Market Database
-- queries.sql
-- Database: Microsoft SQL Server
--
-- Run schema.sql first, then data.sql, then this file.
-- The SELECT queries below do not change database data.
-- Each query notes the application feature it supports and the
-- result it should return with the sample data in data.sql.
USE farmers_market;


GO
-- =========================================================
-- 1. MARKET QUERIES
-- =========================================================
-- Query 1: List all markets.
-- Used for: Browse a list of farmers markets (required feature).
-- Test: Should return 10 markets.
SELECT   market_id,
         market_name,
         market_address,
         operating_hours
FROM     market
ORDER BY market_name;

-- Query 2: Get details for one market.
-- Used for: View details for a specific market (required feature).
-- Test: Market 8 should return the Crookston Indoor Winter Market.
DECLARE @market_id_2 AS INT = 8;

SELECT market_id,
       market_name,
       market_address,
       operating_hours
FROM   market
WHERE  market_id = @market_id_2;

-- Query 3: List vendors at a market.
-- Used for: View details for a specific market, including its
-- list of vendors and their booth numbers (required feature).
-- Test: Market 8 should have 7 vendors.
DECLARE @market_id_3 AS INT = 8;

SELECT   v.vendor_id,
         v.vendor_name,
         v.vendor_contact,
         v.vendor_location,
         mv.vendor_booth_number
FROM     market_vendor AS mv
         INNER JOIN
         vendor AS v
         ON mv.vendor_id = v.vendor_id
WHERE    mv.market_id = @market_id_3
ORDER BY v.vendor_name;

-- Query 4: List products sold at a market, with vendor,
-- price, and inventory information.
-- Used for: The market details page, showing what customers can
-- pre-order at that market and how much is in stock.
-- Test: Market 8 should have 18 product listings.
DECLARE @market_id_4 AS INT = 8;

SELECT   p.product_id,
         p.product_name,
         p.product_type,
         v.vendor_id,
         v.vendor_name,
         vp.unit_price,
         mvp.inventory_quantity
FROM     market_vendor_product AS mvp
         INNER JOIN
         product AS p
         ON mvp.product_id = p.product_id
         INNER JOIN
         vendor AS v
         ON mvp.vendor_id = v.vendor_id
         INNER JOIN
         vendor_product AS vp
         ON mvp.vendor_id = vp.vendor_id
            AND mvp.product_id = vp.product_id
WHERE    mvp.market_id = @market_id_4
ORDER BY p.product_name, v.vendor_name;

-- =========================================================
-- 2. PRODUCT QUERIES
-- =========================================================
-- Query 5: List the products offered by a vendor.
-- Used for: Viewing a vendor's products and prices.
-- Test: Vendor 20 should have 7 products.
DECLARE @vendor_id_5 AS INT = 20;

SELECT   v.vendor_id,
         v.vendor_name,
         p.product_id,
         p.product_name,
         p.product_type,
         vp.unit_price
FROM     vendor_product AS vp
         INNER JOIN
         vendor AS v
         ON vp.vendor_id = v.vendor_id
         INNER JOIN
         product AS p
         ON vp.product_id = p.product_id
WHERE    vp.vendor_id = @vendor_id_5
ORDER BY p.product_name;

-- Query 6A: Search products by name.
-- Used for: Search for products (required feature). The app wraps
-- the customer's search text in % wildcards before running it.
-- Test: Search for "potato"; expect 4 products.
DECLARE @product_search_name AS VARCHAR (100) = '%potato%';

SELECT   product_id,
         product_name,
         product_type,
         product_description
FROM     product
WHERE    product_name LIKE @product_search_name
ORDER BY product_name;

-- Query 6B: Search products by type.
-- Used for: Filtering product search results by type.
-- Test: Meat should return 6 products.
DECLARE @product_search_type AS VARCHAR (50) = 'Meat';

SELECT   product_id,
         product_name,
         product_type,
         product_description
FROM     product
WHERE    product_type = @product_search_type
ORDER BY product_name;

-- Query 6C: Search products across all markets.
-- Used for: Search for products across all markets (required
-- feature). Returns every market and vendor that offers a matching
-- product, with the vendor's price and the current stock, so the
-- customer can see where to pre-order it.
-- Test: Search for "potato"; expect 11 listings covering 4 products.
DECLARE @product_search_6c AS VARCHAR (100) = '%potato%';

SELECT   p.product_id,
         p.product_name,
         p.product_type,
         m.market_id,
         m.market_name,
         v.vendor_id,
         v.vendor_name,
         vp.unit_price,
         mvp.inventory_quantity
FROM     market_vendor_product AS mvp
         INNER JOIN
         product AS p
         ON mvp.product_id = p.product_id
         INNER JOIN
         market AS m
         ON mvp.market_id = m.market_id
         INNER JOIN
         vendor AS v
         ON mvp.vendor_id = v.vendor_id
         INNER JOIN
         vendor_product AS vp
         ON mvp.vendor_id = vp.vendor_id
            AND mvp.product_id = vp.product_id
WHERE    p.product_name LIKE @product_search_6c
ORDER BY p.product_name, m.market_name, v.vendor_name;

-- Query 7: Find markets and vendors that offer a product.
-- Used for: After a customer picks a product from the search
-- results, comparing where it is sold, at what price, and the stock.
-- Test: Product 25 (Free-Range Eggs) should return 6 listings.
DECLARE @product_id_7 AS INT = 25;

SELECT   p.product_id,
         p.product_name,
         m.market_id,
         m.market_name,
         v.vendor_id,
         v.vendor_name,
         vp.unit_price,
         mvp.inventory_quantity
FROM     market_vendor_product AS mvp
         INNER JOIN
         market AS m
         ON mvp.market_id = m.market_id
         INNER JOIN
         vendor AS v
         ON mvp.vendor_id = v.vendor_id
         INNER JOIN
         product AS p
         ON mvp.product_id = p.product_id
         INNER JOIN
         vendor_product AS vp
         ON mvp.vendor_id = vp.vendor_id
            AND mvp.product_id = vp.product_id
WHERE    mvp.product_id = @product_id_7
ORDER BY m.market_name, v.vendor_name;

-- =========================================================
-- 3. PREORDER QUERIES
-- =========================================================
-- Query 8: Show a customer's order history and total cost.
-- Used for: Viewing a customer's pre-orders and their current status.
-- Test: Customer 1 should have 3 preorders.
DECLARE @customer_id_8 AS INT = 1;

SELECT   pr.preorder_id,
         c.customer_first_name,
         c.customer_last_name,
         m.market_name,
         pr.order_date,
         pr.pickup_date,
         pr.status,
         CAST (COALESCE (SUM(pl.quantity * pl.unit_price_at_order), 0) AS DECIMAL (10, 2)) AS preorder_total
FROM     preorder AS pr
         INNER JOIN
         customer AS c
         ON pr.customer_id = c.customer_id
         INNER JOIN
         market AS m
         ON pr.market_id = m.market_id
         LEFT OUTER JOIN
         po_line AS pl
         ON pr.preorder_id = pl.preorder_id
WHERE    pr.customer_id = @customer_id_8
GROUP BY pr.preorder_id, c.customer_first_name, c.customer_last_name, m.market_name, pr.order_date, pr.pickup_date, pr.status
ORDER BY pr.order_date DESC;

-- Query 9: Show the items, quantities, prices, and totals
-- for a preorder.
-- Used for: Viewing the details of one pre-order, including the
-- price charged for each item when the order was placed.
-- Test: Preorder 13 should total $33.00.
DECLARE @preorder_id_9 AS INT = 13;

SELECT   pr.preorder_id,
         p.product_name,
         v.vendor_name,
         pl.quantity,
         pl.unit_price_at_order,
         CAST (pl.quantity * pl.unit_price_at_order AS DECIMAL (10, 2)) AS line_total,
         CAST (SUM(pl.quantity * pl.unit_price_at_order) OVER (PARTITION BY pr.preorder_id) AS DECIMAL (10, 2)) AS preorder_total
FROM     preorder AS pr
         INNER JOIN
         po_line AS pl
         ON pr.preorder_id = pl.preorder_id
         INNER JOIN
         product AS p
         ON pl.product_id = p.product_id
         INNER JOIN
         vendor AS v
         ON pl.vendor_id = v.vendor_id
WHERE    pr.preorder_id = @preorder_id_9
ORDER BY p.product_name, v.vendor_name;

-- =========================================================
-- 4. INVENTORY QUERIES
-- =========================================================
-- Query 10: Find products with no positive inventory
-- at any market.
-- Used for: Showing which products are currently sold out
-- everywhere, so customers are not offered items they cannot order.
-- Test: The sample data should return 9 products.
SELECT   p.product_id,
         p.product_name,
         p.product_type
FROM     product AS p
WHERE    NOT EXISTS (SELECT 1
                     FROM   market_vendor_product AS mvp
                     WHERE  mvp.product_id = p.product_id
                            AND mvp.inventory_quantity > 0)
ORDER BY p.product_name;

-- Query 11: Check the stock and price of one listing.
-- Used for: Place a pre-order (required feature). Inside the
-- pre-order transaction, the app runs this check before inserting
-- each order line. It confirms the vendor brings the product to the
-- pre-order's market, that the quantity requested does not exceed
-- inventory_quantity, and returns the unit_price the app copies into
-- po_line.unit_price_at_order.
-- Test: Market 10, Vendor 6, Product 43.
-- Expected: 28 units at $14.00.
DECLARE @market_id_11 AS INT = 10;

DECLARE @vendor_id_11 AS INT = 6;

DECLARE @product_id_11 AS INT = 43;

SELECT m.market_name,
       v.vendor_name,
       p.product_name,
       mvp.inventory_quantity,
       vp.unit_price
FROM   market_vendor_product AS mvp
       INNER JOIN
       market AS m
       ON mvp.market_id = m.market_id
       INNER JOIN
       vendor AS v
       ON mvp.vendor_id = v.vendor_id
       INNER JOIN
       product AS p
       ON mvp.product_id = p.product_id
       INNER JOIN
       vendor_product AS vp
       ON mvp.vendor_id = vp.vendor_id
          AND mvp.product_id = vp.product_id
WHERE  mvp.market_id = @market_id_11
       AND mvp.vendor_id = @vendor_id_11
       AND mvp.product_id = @product_id_11;

-- Query 12: Check whether a market/vendor/product listing exists.
-- Used for: Place a pre-order (required feature). This is the same
-- check as Query 11, tested with a listing that does not exist.
-- When this check returns no rows, the app rolls back the pre-order
-- transaction so no partial order is saved.
-- Test: Market 8, Vendor 20, Product 13.
-- Expected: 0 rows because Vendor 20 does not attend Market 8.
DECLARE @market_id_12 AS INT = 8;

DECLARE @vendor_id_12 AS INT = 20;

DECLARE @product_id_12 AS INT = 13;

SELECT m.market_name,
       v.vendor_name,
       p.product_name,
       mvp.inventory_quantity,
       vp.unit_price
FROM   market_vendor_product AS mvp
       INNER JOIN
       market AS m
       ON mvp.market_id = m.market_id
       INNER JOIN
       vendor AS v
       ON mvp.vendor_id = v.vendor_id
       INNER JOIN
       product AS p
       ON mvp.product_id = p.product_id
       INNER JOIN
       vendor_product AS vp
       ON mvp.vendor_id = vp.vendor_id
          AND mvp.product_id = vp.product_id
WHERE  mvp.market_id = @market_id_12
       AND mvp.vendor_id = @vendor_id_12
       AND mvp.product_id = @product_id_12;


-- =========================================================
-- END OF REPORTING QUERIES
-- =========================================================