-- =====================================================================
-- Farmers Market Database: data.sql
-- Target DBMS: Microsoft SQL Server
--
-- Run schema.sql first, then this script. schema.sql recreates empty
-- tables, so running both again resets the database to this sample data.
--
-- Setting: farmers markets in Crookston and nearby towns in northwest
-- Minnesota. All market, vendor, and customer names, addresses, phone
-- numbers, and email addresses are fictional. Phone numbers use the
-- 555-01xx range, and email addresses use the reserved example.com domain.
--
-- Timeline: the data reflects October 26, 2026.
--   * Seven outdoor markets run in summer and fall. Three indoor winter
--     markets run November through April.
--   * Past pre-orders (pickups in August-October 2026) are Picked Up or
--     Cancelled. Upcoming pre-orders (pickups in late November and
--     December 2026) are Ready or Pending.
--   * Summer-only produce is out of season, so its inventory is 0. It
--     still appears in searches so customers can see who sells it.
--   * The Ada and Red Lake Falls markets run July-September, so their
--     season has ended and all of their inventory is 0.
--
-- IDs are inserted explicitly with SET IDENTITY_INSERT so the relationship
-- rows can reference them. SQL Server continues numbering after the
-- highest inserted ID, so new rows created by the application do not
-- collide with this data.
--
-- The whole script runs as one transaction. If any statement fails,
-- nothing is inserted.
-- =====================================================================

USE farmers_market;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;


-- ---------------------------------------------------------------------
-- Markets (10): seven outdoor seasonal markets and three indoor winter markets
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT market ON;
INSERT INTO market (market_id, market_name, market_address, operating_hours) VALUES
    (1, 'Crookston Riverside Farmers Market', '215 River Park Dr, Crookston, MN 56716', 'Saturdays 8 AM-12 PM, June-October'),
    (2, 'East Grand Forks Greenway Farmers Market', '140 Greenway Blvd, East Grand Forks, MN 56721', 'Thursdays 3 PM-7 PM, June-October'),
    (3, 'Thief River Falls Riverbend Market', '402 Riverbend Ave, Thief River Falls, MN 56701', 'Wednesdays 3 PM-6 PM, June-October'),
    (4, 'Red Lake Falls Clearwater Market', '118 Clearwater Ave, Red Lake Falls, MN 56750', 'Fridays 3 PM-6 PM, July-September'),
    (5, 'Fosston Prairie Market', '310 Prairie St, Fosston, MN 56542', 'Saturdays 9 AM-12 PM, June-October'),
    (6, 'Ada Main Street Market', '205 Main St, Ada, MN 56510', 'Tuesdays 4 PM-7 PM, July-September'),
    (7, 'Fertile Sand Hill Market', '112 Sand Hill Rd, Fertile, MN 56540', 'Saturdays 8 AM-11 AM, June-October'),
    (8, 'Crookston Indoor Winter Market', '520 Fairfax Ave, Crookston, MN 56716', 'Saturdays 10 AM-1 PM, November-April, indoors'),
    (9, 'East Grand Forks Winter Market', '330 Riverwalk Dr, East Grand Forks, MN 56721', 'Saturdays 9 AM-12 PM, November-April, indoors'),
    (10, 'Thief River Falls Winter Market', '715 Pennington Ave, Thief River Falls, MN 56701', 'Sundays 11 AM-2 PM, November-April, indoors');
SET IDENTITY_INSERT market OFF;

-- ---------------------------------------------------------------------
-- Vendors (20): fictional farms and food producers in the Crookston area
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT vendor ON;
INSERT INTO vendor (vendor_id, vendor_name, vendor_contact, vendor_bio, vendor_location) VALUES
    (1, 'Red River Valley Gardens', '(218) 555-0101', 'Family vegetable farm growing carrots, beets, cabbage, kale, sweet corn, and green beans in the Red River Valley soil east of Crookston.', 'Rural Crookston, MN'),
    (2, 'Prairie Wind Farm', '(218) 555-0102', 'Third-generation potato and onion growers. Storage crops are kept in a root cellar so they are available all winter.', 'Rural Crookston, MN'),
    (3, 'Sand Hill Orchard', '(218) 555-0103', 'Small orchard growing cold-hardy Minnesota apple varieties and baking pies from the fruit.', 'Fertile, MN'),
    (4, 'Northern Lights Apiary', '(218) 555-0104', 'Beekeepers with hives in clover and wildflower fields across Pennington County. Honey is raw and unfiltered.', 'Thief River Falls, MN'),
    (5, 'Pine Lake Maple Co.', '(218) 555-0105', 'Taps sugar maples each spring and boils the sap into pure maple syrup.', 'Rural Fosston, MN'),
    (6, 'Clearwater Wild Rice', '(218) 555-0106', 'Hand-harvests and parches wild rice from lakes in northern Minnesota.', 'Red Lake Falls, MN'),
    (7, 'Hillside Hen House', '(218) 555-0107', 'Free-range laying hens raised on pasture with no antibiotics.', 'Ada, MN'),
    (8, 'Two Rivers Creamery', '(218) 555-0108', 'Small creamery making fresh cheese curds and aged cheddar from local milk.', 'East Grand Forks, MN'),
    (9, 'Lund Family Beef', '(218) 555-0109', 'Grass-fed and grain-finished Angus beef raised on the family ranch.', 'Rural Fertile, MN'),
    (10, 'Olson Heritage Pork', '(218) 555-0110', 'Heritage-breed hogs raised outdoors. Sausage and bacon are smoked in small batches.', 'Rural Fosston, MN'),
    (11, 'Bergstrom Bakery', '(218) 555-0111', 'Home bakery making sourdough and whole wheat bread with Minnesota-grown flour.', 'Crookston, MN'),
    (12, 'Grandma Ingrid''s Kitchen', '(218) 555-0112', 'Scandinavian baked goods and preserves made from family recipes, including potato lefse and krumkake.', 'East Grand Forks, MN'),
    (13, 'Marsh Creek Berry Farm', '(218) 555-0113', 'Berry farm growing strawberries, raspberries, and rhubarb, plus jam made from the harvest.', 'Rural Ada, MN'),
    (14, 'Thief River Greens', '(218) 555-0114', 'Market garden specializing in summer vegetables and leafy greens.', 'Thief River Falls, MN'),
    (15, 'Polk County Pastures', '(218) 555-0115', 'Pasture-raised chickens and ducks, sold as whole birds and fresh eggs.', 'Rural Crookston, MN'),
    (16, 'Wild Prairie Bison Ranch', '(218) 555-0116', 'Bison raised on native prairie grass with no added hormones.', 'Rural Fosston, MN'),
    (17, 'Ada Grain Mill', '(218) 555-0117', 'Stone-grinds locally grown wheat into flour and sells popcorn grown on the farm.', 'Ada, MN'),
    (18, 'Sunny Acres Sunflowers', '(218) 555-0118', 'Grows confection sunflowers and roasts the seeds on the farm.', 'Rural Thief River Falls, MN'),
    (19, 'Pickle Barrel Preserves', '(218) 555-0119', 'Small-batch dill pickles and garden salsa made from vegetables grown nearby.', 'Rural Thief River Falls, MN'),
    (20, 'Riverbend Market Garden', '(218) 555-0120', 'Grows garlic, winter squash, pumpkins, and root vegetables for fall and winter storage.', 'Red Lake Falls, MN');
SET IDENTITY_INSERT vendor OFF;

-- ---------------------------------------------------------------------
-- Products (50): each product is described once, regardless of who sells it
-- Prices are set per vendor in vendor_product.
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT product ON;
INSERT INTO product (product_id, product_name, product_type, product_description) VALUES
    (1, 'Carrots', 'Vegetables', '2 lb bag of fresh-dug orange carrots.'),
    (2, 'Red Beets', 'Vegetables', '2 lb bag of red beets with tops removed.'),
    (3, 'Green Cabbage', 'Vegetables', 'One medium head of green cabbage.'),
    (4, 'Kale', 'Vegetables', 'One bunch of curly green kale.'),
    (5, 'Sweet Corn', 'Vegetables', 'One dozen ears of bicolor sweet corn, picked the morning of the market.'),
    (6, 'Green Beans', 'Vegetables', '1 lb of fresh-picked green beans.'),
    (7, 'Russet Potatoes', 'Vegetables', '5 lb bag of russet potatoes, good for baking and mashing.'),
    (8, 'Red Potatoes', 'Vegetables', '3 lb bag of red-skinned potatoes.'),
    (9, 'Yukon Gold Potatoes', 'Vegetables', '3 lb bag of yellow-fleshed Yukon Gold potatoes.'),
    (10, 'Yellow Onions', 'Vegetables', '2 lb bag of yellow storage onions.'),
    (11, 'Zucchini', 'Vegetables', 'One medium zucchini.'),
    (12, 'Cucumbers', 'Vegetables', 'One slicing cucumber.'),
    (13, 'Garlic', 'Vegetables', 'One head of hardneck garlic.'),
    (14, 'Butternut Squash', 'Vegetables', 'One butternut squash, about 2 to 3 lb.'),
    (15, 'Acorn Squash', 'Vegetables', 'One acorn squash, about 1.5 lb.'),
    (16, 'Pie Pumpkin', 'Vegetables', 'One small sugar pie pumpkin for baking.'),
    (17, 'Parsnips', 'Vegetables', '1 lb of parsnips.'),
    (18, 'Rutabaga', 'Vegetables', 'One large rutabaga.'),
    (19, 'Heirloom Tomatoes', 'Vegetables', '1 lb of mixed heirloom tomatoes.'),
    (20, 'Rhubarb', 'Vegetables', '1 lb of red rhubarb stalks.'),
    (21, 'Honeycrisp Apples', 'Fruit', '3 lb bag of Honeycrisp apples.'),
    (22, 'Haralson Apples', 'Fruit', '3 lb bag of tart Haralson apples, good for pies.'),
    (23, 'Strawberries', 'Fruit', 'One quart of June-bearing strawberries.'),
    (24, 'Raspberries', 'Fruit', 'One half pint of red raspberries.'),
    (25, 'Free-Range Eggs', 'Eggs and Dairy', 'One dozen large brown eggs from free-range hens.'),
    (26, 'Duck Eggs', 'Eggs and Dairy', 'Half dozen fresh duck eggs.'),
    (27, 'Fresh Cheese Curds', 'Eggs and Dairy', '1 lb bag of fresh white cheddar cheese curds.'),
    (28, 'Aged White Cheddar', 'Eggs and Dairy', '8 oz block of white cheddar aged one year.'),
    (29, 'Ground Beef', 'Meat', '1 lb package of frozen ground beef, 85 percent lean.'),
    (30, 'Ribeye Steak', 'Meat', 'One frozen ribeye steak, about 12 oz.'),
    (31, 'Pork Breakfast Sausage', 'Meat', '1 lb package of frozen breakfast sausage.'),
    (32, 'Smoked Bacon', 'Meat', '12 oz package of thick-cut hickory-smoked bacon.'),
    (33, 'Whole Pasture-Raised Chicken', 'Meat', 'One frozen whole chicken, about 4 lb.'),
    (34, 'Ground Bison', 'Meat', '1 lb package of frozen ground bison.'),
    (35, 'Raw Wildflower Honey', 'Honey and Syrup', '1 lb jar of raw, unfiltered wildflower honey.'),
    (36, 'Pure Maple Syrup', 'Honey and Syrup', 'One pint of grade A amber maple syrup.'),
    (37, 'Sourdough Bread', 'Baked Goods', 'One round loaf of naturally leavened sourdough.'),
    (38, 'Honey Whole Wheat Bread', 'Baked Goods', 'One sandwich loaf of whole wheat bread sweetened with honey.'),
    (39, 'Cinnamon Rolls', 'Baked Goods', 'Four large cinnamon rolls with cream cheese frosting.'),
    (40, 'Apple Pie', 'Baked Goods', 'One 9-inch double-crust apple pie.'),
    (41, 'Potato Lefse', 'Baked Goods', 'Package of six rounds of traditional potato lefse.'),
    (42, 'Krumkake', 'Baked Goods', 'One dozen thin Norwegian waffle cookies.'),
    (43, 'Hand-Harvested Wild Rice', 'Grains and Pantry', '1 lb bag of hand-harvested, wood-parched wild rice.'),
    (44, 'Stone-Ground Whole Wheat Flour', 'Grains and Pantry', '5 lb bag of stone-ground whole wheat flour.'),
    (45, 'Popcorn Kernels', 'Grains and Pantry', '2 lb bag of yellow popcorn kernels.'),
    (46, 'Roasted Sunflower Seeds', 'Grains and Pantry', '12 oz bag of roasted, salted in-shell sunflower seeds.'),
    (47, 'Strawberry Rhubarb Jam', 'Preserves', '8 oz jar of strawberry rhubarb jam.'),
    (48, 'Raspberry Jam', 'Preserves', '8 oz jar of seedless raspberry jam.'),
    (49, 'Dill Pickles', 'Preserves', 'One quart jar of garlic dill pickles.'),
    (50, 'Garden Salsa', 'Preserves', '16 oz jar of medium garden salsa.');
SET IDENTITY_INSERT product OFF;

-- ---------------------------------------------------------------------
-- Customers (10)
-- customer_phone is optional, so one customer has none.
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT customer ON;
INSERT INTO customer (customer_id, customer_first_name, customer_last_name, customer_email, customer_phone) VALUES
    (1, 'Emma', 'Halvorson', 'emma.halvorson@example.com', '(218) 555-0151'),
    (2, 'Jacob', 'Lindqvist', 'jacob.lindqvist@example.com', '(218) 555-0152'),
    (3, 'Olivia', 'Martinez', 'olivia.martinez@example.com', '(218) 555-0153'),
    (4, 'Noah', 'Pederson', 'noah.pederson@example.com', '(218) 555-0154'),
    (5, 'Ava', 'Brekke', 'ava.brekke@example.com', '(218) 555-0155'),
    (6, 'Liam', 'Thompson', 'liam.thompson@example.com', '(218) 555-0156'),
    (7, 'Sophia', 'Nguyen', 'sophia.nguyen@example.com', '(218) 555-0157'),
    (8, 'Mason', 'Gunderson', 'mason.gunderson@example.com', '(218) 555-0158'),
    (9, 'Isabella', 'Johnson', 'isabella.johnson@example.com', '(218) 555-0159'),
    (10, 'Ethan', 'Swenson', 'ethan.swenson@example.com', NULL);
SET IDENTITY_INSERT customer OFF;

-- ---------------------------------------------------------------------
-- ATTENDS: which vendors attend which markets, with booth numbers
-- Booths starting with A are outdoor stalls; booths starting with W are indoor winter tables.
-- ---------------------------------------------------------------------
INSERT INTO market_vendor (market_id, vendor_id, vendor_booth_number) VALUES
    (1, 1, 'A1'),
    (1, 2, 'A2'),
    (1, 3, 'A3'),
    (1, 11, 'A4'),
    (1, 15, 'A5'),
    (2, 1, 'A1'),
    (2, 7, 'A2'),
    (2, 8, 'A3'),
    (2, 12, 'A4'),
    (2, 15, 'A5'),
    (3, 4, 'A1'),
    (3, 14, 'A2'),
    (3, 18, 'A3'),
    (3, 19, 'A4'),
    (3, 20, 'A5'),
    (4, 6, 'A1'),
    (4, 13, 'A2'),
    (4, 20, 'A3'),
    (5, 5, 'A1'),
    (5, 10, 'A2'),
    (5, 16, 'A3'),
    (5, 19, 'A4'),
    (6, 7, 'A1'),
    (6, 13, 'A2'),
    (6, 17, 'A3'),
    (7, 2, 'A1'),
    (7, 3, 'A2'),
    (7, 9, 'A3'),
    (8, 2, 'W1'),
    (8, 3, 'W2'),
    (8, 5, 'W3'),
    (8, 9, 'W4'),
    (8, 10, 'W5'),
    (8, 11, 'W6'),
    (8, 15, 'W7'),
    (9, 4, 'W1'),
    (9, 7, 'W2'),
    (9, 8, 'W3'),
    (9, 12, 'W4'),
    (9, 17, 'W5'),
    (10, 4, 'W1'),
    (10, 6, 'W2'),
    (10, 10, 'W3'),
    (10, 16, 'W4'),
    (10, 18, 'W5'),
    (10, 19, 'W6'),
    (10, 20, 'W7');

-- ---------------------------------------------------------------------
-- SELLS: which products each vendor sells, and that vendor's unit price
-- Kale, green beans, and eggs are each sold by two vendors at different prices.
-- ---------------------------------------------------------------------
INSERT INTO vendor_product (vendor_id, product_id, unit_price) VALUES
    (1, 1, 4.00),
    (1, 2, 4.00),
    (1, 3, 3.50),
    (1, 4, 3.00),
    (1, 5, 7.00),
    (1, 6, 4.50),
    (2, 7, 5.00),
    (2, 8, 4.50),
    (2, 9, 5.00),
    (2, 10, 3.00),
    (3, 21, 9.00),
    (3, 22, 7.50),
    (3, 40, 20.00),
    (4, 35, 12.00),
    (5, 36, 16.00),
    (6, 43, 14.00),
    (7, 25, 5.00),
    (8, 27, 8.00),
    (8, 28, 7.00),
    (9, 29, 8.00),
    (9, 30, 18.00),
    (10, 31, 7.50),
    (10, 32, 9.00),
    (11, 37, 8.00),
    (11, 38, 7.00),
    (11, 39, 10.00),
    (12, 41, 9.00),
    (12, 42, 12.00),
    (12, 47, 8.00),
    (13, 20, 3.00),
    (13, 23, 7.00),
    (13, 24, 5.50),
    (13, 48, 8.50),
    (14, 4, 3.25),
    (14, 6, 4.00),
    (14, 11, 1.50),
    (14, 12, 1.25),
    (15, 25, 5.50),
    (15, 26, 6.00),
    (15, 33, 22.00),
    (16, 34, 13.00),
    (17, 44, 9.00),
    (17, 45, 6.00),
    (18, 46, 5.00),
    (19, 49, 9.00),
    (19, 50, 7.00),
    (20, 13, 2.00),
    (20, 14, 3.50),
    (20, 15, 2.50),
    (20, 16, 4.00),
    (20, 17, 3.50),
    (20, 18, 2.50),
    (20, 19, 5.00);

-- ---------------------------------------------------------------------
-- STOCKS: which products each vendor brings to each market, and current stock
-- A vendor stocks only products it sells, only at markets it attends.
-- Winter markets carry no summer-only produce. Summer-only produce has
-- 0 stock at the outdoor markets because it is out of season, and the
-- Ada and Red Lake Falls markets have 0 stock because their season ended.
-- ---------------------------------------------------------------------
INSERT INTO market_vendor_product (market_id, vendor_id, product_id, inventory_quantity) VALUES
    (1, 1, 1, 26),
    (1, 1, 2, 17),
    (1, 1, 3, 34),
    (1, 1, 4, 25),
    (1, 1, 5, 0),
    (1, 1, 6, 0),
    (1, 2, 7, 37),
    (1, 2, 8, 28),
    (1, 2, 9, 19),
    (1, 2, 10, 36),
    (1, 3, 21, 14),
    (1, 3, 22, 10),
    (1, 3, 40, 17),
    (1, 11, 37, 18),
    (1, 11, 38, 9),
    (1, 11, 39, 13),
    (1, 15, 25, 14),
    (1, 15, 26, 31),
    (1, 15, 33, 23),
    (2, 1, 1, 33),
    (2, 1, 2, 24),
    (2, 1, 3, 15),
    (2, 1, 4, 32),
    (2, 1, 5, 0),
    (2, 1, 6, 0),
    (2, 7, 25, 17),
    (2, 8, 27, 14),
    (2, 8, 28, 31),
    (2, 12, 41, 15),
    (2, 12, 42, 6),
    (2, 12, 47, 8),
    (2, 15, 25, 21),
    (2, 15, 26, 13),
    (2, 15, 33, 13),
    (3, 4, 35, 27),
    (3, 14, 4, 26),
    (3, 14, 6, 0),
    (3, 14, 11, 0),
    (3, 14, 12, 0),
    (3, 18, 46, 18),
    (3, 19, 49, 21),
    (3, 19, 50, 21),
    (3, 20, 13, 23),
    (3, 20, 14, 40),
    (3, 20, 15, 31),
    (3, 20, 16, 22),
    (3, 20, 17, 39),
    (3, 20, 18, 30),
    (3, 20, 19, 0),
    (4, 6, 43, 0),
    (4, 13, 20, 0),
    (4, 13, 23, 0),
    (4, 13, 24, 0),
    (4, 13, 48, 0),
    (4, 20, 13, 0),
    (4, 20, 14, 0),
    (4, 20, 15, 0),
    (4, 20, 16, 0),
    (4, 20, 17, 0),
    (4, 20, 18, 0),
    (4, 20, 19, 0),
    (5, 5, 36, 29),
    (5, 10, 31, 20),
    (5, 10, 32, 20),
    (5, 16, 34, 13),
    (5, 19, 49, 18),
    (5, 19, 50, 18),
    (6, 7, 25, 0),
    (6, 13, 20, 0),
    (6, 13, 23, 0),
    (6, 13, 24, 0),
    (6, 13, 48, 0),
    (6, 17, 44, 0),
    (6, 17, 45, 0),
    (7, 2, 7, 27),
    (7, 2, 8, 18),
    (7, 2, 9, 35),
    (7, 2, 10, 26),
    (7, 3, 21, 14),
    (7, 3, 22, 10),
    (7, 3, 40, 7),
    (7, 9, 29, 21),
    (7, 9, 30, 21),
    (8, 2, 7, 34),
    (8, 2, 8, 25),
    (8, 2, 9, 16),
    (8, 2, 10, 33),
    (8, 3, 21, 21),
    (8, 3, 22, 17),
    (8, 3, 40, 14),
    (8, 5, 36, 29),
    (8, 9, 29, 11),
    (8, 9, 30, 11),
    (8, 10, 31, 24),
    (8, 10, 32, 24),
    (8, 11, 37, 15),
    (8, 11, 38, 6),
    (8, 11, 39, 10),
    (8, 15, 25, 13),
    (8, 15, 26, 30),
    (8, 15, 33, 21),
    (9, 4, 35, 27),
    (9, 7, 25, 16),
    (9, 8, 27, 13),
    (9, 8, 28, 30),
    (9, 12, 41, 12),
    (9, 12, 42, 16),
    (9, 12, 47, 23),
    (9, 17, 44, 13),
    (9, 17, 45, 30),
    (10, 4, 35, 13),
    (10, 6, 43, 28),
    (10, 10, 31, 21),
    (10, 10, 32, 21),
    (10, 16, 34, 14),
    (10, 18, 46, 25),
    (10, 19, 49, 19),
    (10, 19, 50, 19),
    (10, 20, 13, 20),
    (10, 20, 14, 37),
    (10, 20, 15, 28),
    (10, 20, 16, 19),
    (10, 20, 17, 36),
    (10, 20, 18, 27);

-- ---------------------------------------------------------------------
-- Pre-orders (15): 10 past pickups and 5 upcoming pickups
-- Each pickup date falls on that market's market day and within its season.
-- Statuses match the dates: past pickups are Picked Up or Cancelled,
-- and upcoming pickups are Ready or Pending.
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT preorder ON;
INSERT INTO preorder (preorder_id, customer_id, market_id, pickup_date, order_date, status) VALUES
    (1, 1, 1, '2026-08-08', '2026-08-05 19:12:00', 'Picked Up'),
    (2, 2, 2, '2026-08-13', '2026-08-10 08:45:00', 'Picked Up'),
    (3, 3, 3, '2026-08-19', '2026-08-17 21:03:00', 'Picked Up'),
    (4, 6, 6, '2026-08-25', '2026-08-22 10:05:00', 'Picked Up'),
    (5, 4, 4, '2026-09-04', '2026-09-01 12:30:00', 'Picked Up'),
    (6, 1, 1, '2026-09-12', '2026-09-09 18:20:00', 'Picked Up'),
    (7, 5, 5, '2026-09-19', '2026-09-14 16:40:00', 'Cancelled'),
    (8, 7, 7, '2026-10-03', '2026-09-29 20:15:00', 'Picked Up'),
    (9, 2, 2, '2026-10-08', '2026-10-05 07:55:00', 'Cancelled'),
    (10, 8, 3, '2026-10-14', '2026-10-11 14:25:00', 'Picked Up'),
    (11, 9, 10, '2026-11-29', '2026-10-19 09:10:00', 'Ready'),
    (12, 3, 8, '2026-11-28', '2026-10-20 17:35:00', 'Ready'),
    (13, 10, 8, '2026-12-05', '2026-10-22 11:50:00', 'Pending'),
    (14, 1, 9, '2026-12-12', '2026-10-24 19:05:00', 'Pending'),
    (15, 5, 10, '2026-12-20', '2026-10-25 13:30:00', 'Pending');
SET IDENTITY_INSERT preorder OFF;

-- ---------------------------------------------------------------------
-- INCLUDES: the items in each pre-order
-- Every line is a product that vendor brings to the pre-order's market.
-- unit_price_at_order is the vendor's price when the order was placed.
-- ---------------------------------------------------------------------
INSERT INTO po_line (preorder_id, vendor_id, product_id, quantity, unit_price_at_order) VALUES
    (1, 1, 5, 1, 7.00),
    (1, 11, 37, 1, 8.00),
    (1, 15, 25, 1, 5.50),
    (2, 8, 27, 2, 8.00),
    (2, 12, 41, 1, 9.00),
    (2, 1, 6, 1, 4.50),
    (3, 14, 11, 3, 1.50),
    (3, 14, 12, 2, 1.25),
    (3, 4, 35, 1, 12.00),
    (4, 7, 25, 2, 5.00),
    (4, 17, 44, 1, 9.00),
    (5, 13, 24, 2, 5.50),
    (5, 6, 43, 1, 14.00),
    (5, 20, 19, 2, 5.00),
    (6, 3, 21, 2, 9.00),
    (6, 2, 7, 1, 5.00),
    (7, 10, 32, 1, 9.00),
    (7, 16, 34, 2, 13.00),
    (8, 9, 29, 3, 8.00),
    (8, 9, 30, 2, 18.00),
    (8, 3, 40, 1, 20.00),
    (9, 15, 33, 1, 22.00),
    (10, 20, 14, 2, 3.50),
    (10, 20, 13, 4, 2.00),
    (10, 19, 49, 1, 9.00),
    (10, 18, 46, 1, 5.00),
    (11, 6, 43, 2, 14.00),
    (11, 4, 35, 1, 12.00),
    (11, 18, 46, 2, 5.00),
    (12, 5, 36, 2, 16.00),
    (12, 2, 7, 1, 5.00),
    (13, 9, 29, 2, 8.00),
    (13, 10, 32, 1, 9.00),
    (13, 11, 37, 1, 8.00),
    (14, 12, 41, 2, 9.00),
    (14, 12, 42, 1, 12.00),
    (14, 7, 25, 1, 5.00),
    (15, 20, 14, 1, 3.50),
    (15, 16, 34, 2, 13.00),
    (15, 19, 49, 1, 9.00);

COMMIT TRANSACTION;
GO
