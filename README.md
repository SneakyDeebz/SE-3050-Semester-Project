# Farmers Market Pre-Order Application

This repository contains the SE 3050 semester project for the University of Minnesota Crookston.

## Team

- Gavin Sullivan
- Travis Gurske
- Max Netteberg
- Benjamin Monahan

Project board: https://github.com/users/SneakyDeebz/projects/1/views/1

## Project Overview

The Farmers Market application is a customer-facing website for discovering local farmers markets and the products available there. Customers can browse markets, view market details and attending vendors, search products across markets, and place preorders for pickup at a selected market.

The application uses a relational SQL Server database to represent markets, vendors, products, customers, product availability, and preorders. It does not provide vendor-management or administrative functionality.

## Technology Stack

| Area | Technology |
| --- | --- |
| Web application | ASP.NET Core Razor Pages |
| Target framework | .NET 10 (`net10.0`) |
| Database | Microsoft SQL Server |
| Database access | ADO.NET with `Microsoft.Data.SqlClient` 7.1.1 |
| User interface | HTML, CSS, Razor, and locally bundled Bootstrap 5.3.3 |

The application uses ADO.NET rather than Entity Framework Core. SQL queries and the preorder transaction remain visible in repository code, making the database operations and relationships clear for this course project.

## Application Features

1. **Browse farmers markets** — view each market's name, address, and operating hours.
2. **View a market and its vendors** — see a selected market's information and attending vendors, including booth numbers when available.
3. **Search products across markets** — search product names and see each matching product/vendor/market listing, its vendor price, and market inventory. Zero-inventory listings are shown as out of stock.
4. **Place a preorder** — choose a customer and available product listing, quantity, and pickup date. Preorder creation updates inventory and writes the order and its line item in a SQL transaction.

## Database Design

The authoritative database definition is [schema.sql](schema.sql). It defines nine tables:

| Table | Purpose |
| --- | --- |
| `market` | Market name, address, and operating hours |
| `vendor` | Vendor name and contact/business details |
| `product` | Product name, type, and description |
| `customer` | Customer name and contact information |
| `market_vendor` | Vendors attending markets and their booth numbers |
| `vendor_product` | Products sold by vendors and their unit prices |
| `market_vendor_product` | Vendor products brought to each market and their inventory |
| `preorder` | Customer preorder, pickup market/date, order date, and status |
| `po_line` | Product, vendor, quantity, and price snapshot for each preorder line |

The ERD uses Chen notation and is available as [ERD Image.png](ERD%20Image.png). [Normalization.md](Normalization.md) documents the functional dependencies and normalization analysis.

The database uses foreign keys, composite keys, and check constraints to enforce valid relationships and values. The order total is calculated from preorder lines (`quantity * unit_price_at_order`) and is not stored separately.

## Database Interaction

The ADO.NET repository classes in `FarmersMarket.Web/Data` contain the SQL used by the application:

- `MarketRepository` reads markets, a selected market, and its vendors.
- `ProductRepository` joins `product`, `vendor_product`, `vendor`, `market_vendor_product`, and `market` to show actual product/vendor/market listings. The `market_vendor_product` relationship ensures the vendor brings that product to that market.
- `PreorderRepository` loads customer and available-listing choices and creates preorders.

Request-supplied values used in SQL are passed as parameters rather than concatenated into SQL statements. Product-name searches use a parameterized `LIKE` pattern for partial matching. Search collation behavior follows the SQL Server database collation.

Preorder creation reads the current price from `vendor_product.unit_price`, then saves that price in `po_line.unit_price_at_order`. It checks and reduces inventory in `market_vendor_product` as part of the same transaction that inserts the `preorder` and its `po_line`.

## Project Structure

```text
FarmersMarket.Web/
├── Data/                       # ADO.NET repositories and SQL
├── Models/                     # Data models used by the pages
├── Pages/
│   ├── Markets/                # Market list and details
│   ├── Products/               # Product search
│   ├── Preorders/              # Preorder creation
│   └── Shared/                 # Shared layout and validation partial
├── wwwroot/                    # CSS and bundled static assets
├── appsettings*.json           # Application configuration
└── FarmersMarket.Web.csproj    # Target framework and package references
```

## Prerequisites

- .NET 10 SDK
- Microsoft SQL Server, running locally or otherwise accessible to your machine
- A SQL Server client/tool capable of creating a database and executing the provided SQL scripts

The project can be restored, built, and run using the .NET CLI; no specific IDE is required.

## Database Setup

Use a development database. The schema script drops and recreates its tables, deleting existing table data.

1. Create the database:

   ```sql
   CREATE DATABASE farmers_market;
   ```

2. Execute [schema.sql](schema.sql) against the server. It selects `farmers_market` with `USE farmers_market` and creates the tables and constraints.
3. To load the repository's sample data, execute [data.sql](data.sql) after `schema.sql`. It populates the tables with fictional sample markets, vendors, products, customers, inventory, and preorders. The sample-data script runs its inserts in a transaction.

The sample data is useful for demonstrating and testing the application. Do not run `schema.sql` against a database whose data must be retained.

## Connection String

The development connection string is configured as `ConnectionStrings:FarmersMarket` in `FarmersMarket.Web/appsettings.Development.json`:

```text
Server=localhost;Database=farmers_market;Trusted_Connection=True;TrustServerCertificate=True;
```

The connection uses Windows trusted authentication and contains no username or password. If your SQL Server uses a named instance or a different server, adjust the `Server` portion in your local development configuration.

## Restore, Build, and Run

From the repository root, run:

```bash
dotnet restore
dotnet build
dotnet run --project FarmersMarket.Web
```

The launch profiles configure the Development environment. After starting, `dotnet run` prints the local application URL in the terminal; use that URL rather than assuming a particular port.

## Using the Application

The shared navigation provides:

- **Home** — landing page with links to the main tasks.
- **Markets** — browse markets and open a market's details to view its vendors and booth numbers.
- **Products** — browse available vendor/product/market combinations or search by product name.
- **Preorder** — choose a customer and available listing, then submit quantity and pickup date.

The preorder page lists customers from the database. The application does not currently provide customer accounts or authentication.

## Preorder Transaction

`PreorderRepository.PlacePreorderAsync` validates that quantity is greater than zero and the pickup date is not in the past. It then opens a SQL connection and starts a transaction.

Within the transaction, the repository:

1. Selects the requested market/vendor/product listing from `market_vendor_product`, joins `vendor_product`, reads the current `unit_price`, and checks that inventory is at least the requested quantity. The inventory row is locked during this operation.
2. Decreases `inventory_quantity` by the requested amount with a conditional update that also requires sufficient stock.
3. Inserts the `preorder` row and retrieves its generated ID with `OUTPUT INSERTED.preorder_id`.
4. Inserts the related `po_line` using that preorder ID, vendor ID, product ID, requested quantity, and the retrieved price as `unit_price_at_order`.
5. Commits after all operations succeed.

If a requested listing is unavailable or has insufficient stock, the operation fails before the inventory update. If an operation throws before commit, the repository rolls the transaction back and rethrows the failure. The inventory update and both inserts use the same connection and transaction, preventing a failed operation from leaving its partial changes committed.

## SQL Query Examples

[queries.sql](queries.sql) contains commented SQL examples for exploring the schema and its relationships. It is a standalone query reference; the application's actual queries are in the repository classes.

## Testing and Verification

- [ ] Markets load successfully.
- [ ] Market details display the correct vendors.
- [ ] Product search returns matching products across markets.
- [ ] A valid preorder can be created successfully.
- [ ] Inventory decreases correctly after a successful preorder.
- [ ] A preorder requesting more inventory than is available is rejected.
- [ ] A rejected preorder does not leave partial preorder or `po_line` records.

### Final Demo Video

**Final Demo Video:** [Link will be added before submission]
