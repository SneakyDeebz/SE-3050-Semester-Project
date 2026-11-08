using FarmersMarket.Web.Models;
using Microsoft.Data.SqlClient;

namespace FarmersMarket.Web.Data;

public class MarketRepository
{
    private readonly string _connectionString;

    public MarketRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("FarmersMarket")
            ?? throw new InvalidOperationException("The FarmersMarket connection string was not found.");
    }

    public async Task<List<Market>> GetMarketsAsync()
    {
        var markets = new List<Market>();

        await using var connection = new SqlConnection(_connectionString);
        await using var command = new SqlCommand(
            @"SELECT market_id, market_name, market_address, operating_hours
              FROM market
              ORDER BY market_name;",
            connection);

        await connection.OpenAsync();

        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            markets.Add(new Market
            {
                MarketId = reader.GetInt32(0),
                MarketName = reader.GetString(1),
                MarketAddress = reader.GetString(2),
                OperatingHours = reader.IsDBNull(3) ? null : reader.GetString(3)
            });
        }

        return markets;
    }

    public async Task<Market?> GetMarketByIdAsync(int marketId)
    {
        await using var connection = new SqlConnection(_connectionString);
        await using var command = new SqlCommand(
            @"SELECT market_id, market_name, market_address, operating_hours
              FROM market
              WHERE market_id = @marketId;",
            connection);

        command.Parameters.Add("@marketId", System.Data.SqlDbType.Int).Value = marketId;

        await connection.OpenAsync();

        await using var reader = await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        return new Market
        {
            MarketId = reader.GetInt32(0),
            MarketName = reader.GetString(1),
            MarketAddress = reader.GetString(2),
            OperatingHours = reader.IsDBNull(3) ? null : reader.GetString(3)
        };
    }

    public async Task<List<Vendor>> GetMarketVendorsByMarketIdAsync(int marketId)
    {
        var vendors = new List<Vendor>();

        await using var connection = new SqlConnection(_connectionString);
        await using var command = new SqlCommand(
            @"SELECT v.vendor_id, v.vendor_name, mv.vendor_booth_number
              FROM market_vendor mv
              INNER JOIN vendor v ON mv.vendor_id = v.vendor_id
              WHERE mv.market_id = @marketId
              ORDER BY v.vendor_name;",
            connection);

        command.Parameters.Add("@marketId", System.Data.SqlDbType.Int).Value = marketId;

        await connection.OpenAsync();

        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            vendors.Add(new Vendor
            {
                VendorId = reader.GetInt32(0),
                VendorName = reader.GetString(1),
                VendorBoothNumber = reader.IsDBNull(2) ? null : reader.GetString(2)
            });
        }

        return vendors;
    }
}
