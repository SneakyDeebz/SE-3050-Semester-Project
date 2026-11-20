using FarmersMarket.Web.Data;
using FarmersMarket.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;

namespace FarmersMarket.Web.Pages.Products;

public class IndexModel : PageModel
{
    private readonly ProductRepository _productRepository;
    private readonly ILogger<IndexModel> _logger;

    public IndexModel(
        ProductRepository productRepository,
        ILogger<IndexModel> logger)
    {
        _productRepository = productRepository;
        _logger = logger;
    }

    [BindProperty(SupportsGet = true)]
    public string? SearchTerm { get; set; }

    public IList<ProductSearchResult> Products { get; private set; } =
        new List<ProductSearchResult>();

    public string? ErrorMessage { get; private set; }

    public async Task OnGetAsync()
    {
        try
        {
            Products =
                await _productRepository.GetAvailableProductsAsync(SearchTerm);
        }
        catch (SqlException ex)
        {
            _logger.LogError(
                ex,
                "An error occurred while loading product search results.");

            ErrorMessage =
                "We could not load product results right now. Please try again later.";
        }
    }

    public async Task<JsonResult> OnGetSuggestionsAsync(string? term)
    {
        if (string.IsNullOrWhiteSpace(term))
        {
            return new JsonResult(Array.Empty<string>());
        }

        try
        {
            var products =
                await _productRepository.GetAvailableProductsAsync(term);

            var suggestions = products
                .Select(product => product.ProductName)
                .Where(name => !string.IsNullOrWhiteSpace(name))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(name => name)
                .Take(10)
                .ToList();

            return new JsonResult(suggestions);
        }
        catch (SqlException ex)
        {
            _logger.LogError(
                ex,
                "An error occurred while loading product suggestions.");

            return new JsonResult(Array.Empty<string>());
        }
    }
}
