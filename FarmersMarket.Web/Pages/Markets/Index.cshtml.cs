using FarmersMarket.Web.Data;
using FarmersMarket.Web.Models;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace FarmersMarket.Web.Pages.Markets;

public class IndexModel : PageModel
{
    private readonly MarketRepository _marketRepository;
    private readonly ILogger<IndexModel> _logger;

    public IndexModel(MarketRepository marketRepository, ILogger<IndexModel> logger)
    {
        _marketRepository = marketRepository;
        _logger = logger;
    }

    public IList<Market> Markets { get; private set; } = new List<Market>();
    public string? ErrorMessage { get; private set; }

    public async Task OnGetAsync()
    {
        try
        {
            Markets = await _marketRepository.GetMarketsAsync();
        }
        catch (Microsoft.Data.SqlClient.SqlException ex)
        {
            _logger.LogError(ex, "An error occurred while loading the list of markets.");
            ErrorMessage = "We could not load the available markets right now. Please try again later.";
        }
    }
}
