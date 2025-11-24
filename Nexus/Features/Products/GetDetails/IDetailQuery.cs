namespace Nexus.Features.Products.GetDetails;

public interface IDetailQuery
{
    Task<Response?> GetProductDetailsAsync(int productId, CancellationToken ct);
}