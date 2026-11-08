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
}
