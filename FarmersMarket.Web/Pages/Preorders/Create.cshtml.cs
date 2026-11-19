
using FarmersMarket.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Data.SqlClient;

namespace FarmersMarket.Web.Pages.Preorders;

public class CreateModel : PageModel
{
    private readonly PreorderRepository _preorderRepository;
    private readonly ILogger<CreateModel> _logger;

    public CreateModel(
        PreorderRepository preorderRepository,
        ILogger<CreateModel> logger)
    {
        _preorderRepository = preorderRepository;
        _logger = logger;
    }

    [BindProperty]
    public int CustomerId { get; set; }

    [BindProperty]
    public string ListingSelection { get; set; } = string.Empty;

    [BindProperty]
    public int Quantity { get; set; } = 1;

    [BindProperty]
    public DateTime PickupDate { get; set; } =
        DateTime.Today.AddDays(1);

    public List<SelectListItem> Customers { get; set; } = new();

    public List<SelectListItem> Listings { get; set; } = new();

    public string MinimumPickupDate =>
        DateTime.Today.ToString("yyyy-MM-dd");

    [TempData]
    public string? SuccessMessage { get; set; }

    public string? ErrorMessage { get; set; }

    public async Task OnGetAsync()
    {
        await LoadFormOptionsAsync();
    }

    public async Task<IActionResult> OnPostAsync()
    {
        if (Quantity <= 0)
        {
            ModelState.AddModelError(
                nameof(Quantity),
                "Quantity must be greater than zero.");
        }

        if (PickupDate.Date < DateTime.Today)
        {
            ModelState.AddModelError(
                nameof(PickupDate),
                "Pickup date cannot be in the past.");
        }

        // The listing selection contains market, vendor, and product IDs.
        int marketId = 0;
        int vendorId = 0;
        int productId = 0;
        var ids = ListingSelection.Split('|');

        if (ids.Length != 3 ||
            !int.TryParse(ids[0], out marketId) ||
            !int.TryParse(ids[1], out vendorId) ||
            !int.TryParse(ids[2], out productId))
        {
            ModelState.AddModelError(
                nameof(ListingSelection),
                "Please select a valid product listing.");
        }

        if (!ModelState.IsValid)
        {
            await LoadFormOptionsAsync();
            return Page();
        }

        try
        {
            int preorderId = await _preorderRepository.PlacePreorderAsync(
                CustomerId,
                marketId,
                vendorId,
                productId,
                Quantity,
                PickupDate);

            SuccessMessage =
                $"Preorder #{preorderId} was placed successfully.";

            return RedirectToPage();
        }
        catch (InvalidOperationException ex)
        {
            ErrorMessage = ex.Message;
            await LoadFormOptionsAsync();
            return Page();
        }
        catch (ArgumentException ex)
        {
            ErrorMessage = ex.Message;
            await LoadFormOptionsAsync();
            return Page();
        }
        catch (SqlException ex)
        {
            _logger.LogError(
                ex,
                "An error occurred while placing a preorder.");

            ErrorMessage =
                "The preorder could not be completed. Please check your selections and try again.";

            await LoadFormOptionsAsync();
            return Page();
        }
    }

    private async Task LoadFormOptionsAsync()
    {
        var customers = await _preorderRepository.GetCustomersAsync();

        Customers = customers.Select(customer => new SelectListItem
        {
            Value = customer.CustomerId.ToString(),
            Text = customer.CustomerName
        }).ToList();

        var listings =
            await _preorderRepository.GetAvailableListingsAsync();

        Listings = listings.Select(listing => new SelectListItem
        {
            Value = $"{listing.MarketId}|{listing.VendorId}|{listing.ProductId}",
            Text = $"{listing.ProductName} - {listing.VendorName} - " +
                   $"{listing.MarketName} " +
                   $"(${listing.UnitPrice:F2}, " +
                   $"{listing.InventoryQuantity} available)"
        }).ToList();
    }
}
