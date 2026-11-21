
using System.Data;
using Microsoft.Data.SqlClient;

namespace FarmersMarket.Web.Data;

public class PreorderRepository
{
    private readonly string _connectionString;

    public PreorderRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("FarmersMarket")
            ?? throw new InvalidOperationException(
                "The FarmersMarket connection string was not found.");
    }

    public async Task<List<PreorderCustomerOption>> GetCustomersAsync()
    {
        var customers = new List<PreorderCustomerOption>();

        await using var connection = new SqlConnection(_connectionString);

        await using var command = new SqlCommand(
            @"SELECT customer_id,
                     customer_first_name,
                     customer_last_name
              FROM customer
              ORDER BY customer_last_name, customer_first_name;",
            connection);

        await connection.OpenAsync();

        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            customers.Add(new PreorderCustomerOption
            {
                CustomerId = reader.GetInt32(0),
                CustomerName = $"{reader.GetString(1)} {reader.GetString(2)}"
            });
        }

        return customers;
    }

    public async Task<List<PreorderListingOption>> GetAvailableListingsAsync()
    {
        var listings = new List<PreorderListingOption>();

        await using var connection = new SqlConnection(_connectionString);

        await using var command = new SqlCommand(
            @"SELECT
                  m.market_id,
                  m.market_name,
                  v.vendor_id,
                  v.vendor_name,
                  p.product_id,
                  p.product_name,
                  vp.unit_price,
                  mvp.inventory_quantity
              FROM market_vendor_product mvp
              INNER JOIN market m
                  ON mvp.market_id = m.market_id
              INNER JOIN vendor v
                  ON mvp.vendor_id = v.vendor_id
              INNER JOIN product p
                  ON mvp.product_id = p.product_id
              INNER JOIN vendor_product vp
                  ON mvp.vendor_id = vp.vendor_id
                 AND mvp.product_id = vp.product_id
              WHERE mvp.inventory_quantity > 0
              ORDER BY m.market_name, v.vendor_name, p.product_name;",
            connection);

        await connection.OpenAsync();

        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            listings.Add(new PreorderListingOption
            {
                MarketId = reader.GetInt32(0),
                MarketName = reader.GetString(1),
                VendorId = reader.GetInt32(2),
                VendorName = reader.GetString(3),
                ProductId = reader.GetInt32(4),
                ProductName = reader.GetString(5),
                UnitPrice = reader.GetDecimal(6),
                InventoryQuantity = reader.GetInt32(7)
            });
        }

        return listings;
    }

    public async Task<int> PlacePreorderAsync(
        int customerId,
        int marketId,
        int vendorId,
        int productId,
        int quantity,
        DateTime pickupDate)
    {
        if (quantity <= 0)
        {
            throw new ArgumentException(
                "Quantity must be greater than zero.");
        }

        if (pickupDate.Date < DateTime.Today)
        {
            throw new ArgumentException(
                "Pickup date cannot be in the past.");
        }

        await using var connection = new SqlConnection(_connectionString);

        await connection.OpenAsync();

        using var transaction = connection.BeginTransaction();

        try
        {
            // Step 1: Retrieve the current price and lock the
            // inventory row while this transaction is in progress.
            decimal unitPrice;

            await using (var priceCommand = new SqlCommand(
                @"SELECT vp.unit_price
                  FROM market_vendor_product mvp WITH (UPDLOCK, HOLDLOCK)
                  INNER JOIN vendor_product vp
                      ON mvp.vendor_id = vp.vendor_id
                     AND mvp.product_id = vp.product_id
                  WHERE mvp.market_id = @marketId
                    AND mvp.vendor_id = @vendorId
                    AND mvp.product_id = @productId
                    AND mvp.inventory_quantity >= @quantity;",
                connection,
                transaction))
            {
                priceCommand.Parameters.Add(
                    "@marketId", SqlDbType.Int).Value = marketId;

                priceCommand.Parameters.Add(
                    "@vendorId", SqlDbType.Int).Value = vendorId;

                priceCommand.Parameters.Add(
                    "@productId", SqlDbType.Int).Value = productId;

                priceCommand.Parameters.Add(
                    "@quantity", SqlDbType.Int).Value = quantity;

                var result = await priceCommand.ExecuteScalarAsync();

                if (result == null || result == DBNull.Value)
                {
                    throw new InvalidOperationException(
                        "This product is unavailable in the requested quantity.");
                }

                unitPrice = Convert.ToDecimal(result);
            }

            // Step 2: Decrease inventory only if enough stock remains.
            await using (var inventoryCommand = new SqlCommand(
                @"UPDATE market_vendor_product
                  SET inventory_quantity = inventory_quantity - @quantity
                  WHERE market_id = @marketId
                    AND vendor_id = @vendorId
                    AND product_id = @productId
                    AND inventory_quantity >= @quantity;",
                connection,
                transaction))
            {
                inventoryCommand.Parameters.Add(
                    "@quantity", SqlDbType.Int).Value = quantity;

                inventoryCommand.Parameters.Add(
                    "@marketId", SqlDbType.Int).Value = marketId;

                inventoryCommand.Parameters.Add(
                    "@vendorId", SqlDbType.Int).Value = vendorId;

                inventoryCommand.Parameters.Add(
                    "@productId", SqlDbType.Int).Value = productId;

                int rowsAffected =
                    await inventoryCommand.ExecuteNonQueryAsync();

                if (rowsAffected != 1)
                {
                    throw new InvalidOperationException(
                        "There is not enough inventory to complete this preorder.");
                }
            }

            // Step 3: Insert the preorder and retrieve its new ID.
            int preorderId;

            await using (var preorderCommand = new SqlCommand(
                @"INSERT INTO preorder
                      (customer_id, market_id, pickup_date)
                  OUTPUT INSERTED.preorder_id
                  VALUES
                      (@customerId, @marketId, @pickupDate);",
                connection,
                transaction))
            {
                preorderCommand.Parameters.Add(
                    "@customerId", SqlDbType.Int).Value = customerId;

                preorderCommand.Parameters.Add(
                    "@marketId", SqlDbType.Int).Value = marketId;

                preorderCommand.Parameters.Add(
                    "@pickupDate", SqlDbType.Date).Value = pickupDate.Date;

                var result = await preorderCommand.ExecuteScalarAsync();

                preorderId = Convert.ToInt32(result);
            }

            // Step 4: Insert the product into the preorder.
            // Save the database price at the time of the order.
            await using (var lineCommand = new SqlCommand(
                @"INSERT INTO po_line
                      (preorder_id, vendor_id, product_id,
                       quantity, unit_price_at_order)
                  VALUES
                      (@preorderId, @vendorId, @productId,
                       @quantity, @unitPrice);",
                connection,
                transaction))
            {
                lineCommand.Parameters.Add(
                    "@preorderId", SqlDbType.Int).Value = preorderId;

                lineCommand.Parameters.Add(
                    "@vendorId", SqlDbType.Int).Value = vendorId;

                lineCommand.Parameters.Add(
                    "@productId", SqlDbType.Int).Value = productId;

                lineCommand.Parameters.Add(
                    "@quantity", SqlDbType.Int).Value = quantity;

                lineCommand.Parameters.Add(
                    "@unitPrice", SqlDbType.Decimal).Value = unitPrice;

                lineCommand.Parameters["@unitPrice"].Precision = 10;
                lineCommand.Parameters["@unitPrice"].Scale = 2;

                await lineCommand.ExecuteNonQueryAsync();
            }

            // Step 5: Everything succeeded. Save all changes.
            transaction.Commit();

            return preorderId;
        }
        catch
        {
            // If any step fails, undo all changes.
            transaction.Rollback();
            throw;
        }
    }
}

public class PreorderCustomerOption
{
    public int CustomerId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
}

public class PreorderListingOption
{
    public int MarketId { get; set; }
    public string MarketName { get; set; } = string.Empty;

    public int VendorId { get; set; }
    public string VendorName { get; set; } = string.Empty;

    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;

    public decimal UnitPrice { get; set; }
    public int InventoryQuantity { get; set; }
}
