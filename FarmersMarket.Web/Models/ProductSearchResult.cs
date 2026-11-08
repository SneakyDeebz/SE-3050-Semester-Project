namespace FarmersMarket.Web.Models;

public class ProductSearchResult
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string? ProductType { get; set; }
    public int VendorId { get; set; }
    public string VendorName { get; set; } = string.Empty;
    public int MarketId { get; set; }
    public string MarketName { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public int InventoryQuantity { get; set; }
}
