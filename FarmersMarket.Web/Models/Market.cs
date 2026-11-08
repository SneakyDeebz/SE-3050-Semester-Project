namespace FarmersMarket.Web.Models;

public class Market
{
    public int MarketId { get; set; }
    public string MarketName { get; set; } = string.Empty;
    public string MarketAddress { get; set; } = string.Empty;
    public string? OperatingHours { get; set; }
}
