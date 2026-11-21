using FarmersMarket.Web.Models;
using Microsoft.Data.SqlClient;

namespace FarmersMarket.Web.Data;

public class ProductRepository
{
    private readonly string _connectionString;

    public ProductRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("FarmersMarket")
            ?? throw new InvalidOperationException("The FarmersMarket connection string was not found.");
    }

    public async Task<List<ProductSearchResult>> GetAvailableProductsAsync(string? searchTerm)
    {
        var products = new List<ProductSearchResult>();
        var trimmedSearch = string.IsNullOrWhiteSpace(searchTerm) ? null : searchTerm.Trim();

        await using var connection = new SqlConnection(_connectionString);

        var sql = @"SELECT
    p.product_id,
    p.product_name,
    p.product_type,
    v.vendor_id,
    v.vendor_name,
    m.market_id,
    m.market_name,
    vp.unit_price,
    mvp.inventory_quantity
FROM product p
INNER JOIN vendor_product vp
    ON p.product_id = vp.product_id
INNER JOIN vendor v
    ON vp.vendor_id = v.vendor_id
INNER JOIN market_vendor_product mvp
    ON vp.vendor_id = mvp.vendor_id
   AND vp.product_id = mvp.product_id
INNER JOIN market m
    ON mvp.market_id = m.market_id";

        if (!string.IsNullOrWhiteSpace(trimmedSearch))
        {
            sql += "\nWHERE p.product_name LIKE @searchTerm";
        }

        sql += "\nORDER BY p.product_name, v.vendor_name, m.market_name;";

        await using var command = new SqlCommand(sql, connection);

        if (!string.IsNullOrWhiteSpace(trimmedSearch))
        {
            command.Parameters.Add("@searchTerm", System.Data.SqlDbType.VarChar, 100).Value = $"%{trimmedSearch}%";
        }

        await connection.OpenAsync();

        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            products.Add(new ProductSearchResult
            {
                ProductId = reader.GetInt32(0),
                ProductName = reader.GetString(1),
                ProductType = reader.IsDBNull(2) ? null : reader.GetString(2),
                VendorId = reader.GetInt32(3),
                VendorName = reader.GetString(4),
                MarketId = reader.GetInt32(5),
                MarketName = reader.GetString(6),
                UnitPrice = reader.GetDecimal(7),
                InventoryQuantity = reader.GetInt32(8)
            });
        }

        return products;
    }
}
