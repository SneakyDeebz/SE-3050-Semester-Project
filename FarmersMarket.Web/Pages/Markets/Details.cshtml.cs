using FarmersMarket.Web.Data;
using FarmersMarket.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;

namespace FarmersMarket.Web.Pages.Markets;

public class DetailsModel : PageModel
{
    private readonly MarketRepository _marketRepository;
    private readonly ILogger<DetailsModel> _logger;

    public DetailsModel(MarketRepository marketRepository, ILogger<DetailsModel> logger)
    {
        _marketRepository = marketRepository;
        _logger = logger;
    }

    public Market? Market { get; private set; }
    public IList<Vendor> Vendors { get; private set; } = new List<Vendor>();
    public string? ErrorMessage { get; private set; }

    public async Task<IActionResult> OnGetAsync(int? id)
    {
        if (id is null || id <= 0)
        {
            ErrorMessage = "A valid market ID was not provided.";
            return Page();
        }

        try
        {
            Market = await _marketRepository.GetMarketByIdAsync(id.Value);

            if (Market is null)
            {
                ErrorMessage = "The requested market could not be found.";
                return Page();
            }

            Vendors = await _marketRepository.GetMarketVendorsByMarketIdAsync(id.Value);
            return Page();
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "An error occurred while loading details for market ID {MarketId}.", id);
            ErrorMessage = "We could not load this market right now. Please try again later.";
            return Page();
        }
    }
}
