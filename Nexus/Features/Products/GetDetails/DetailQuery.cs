
namespace Nexus.Features.Products.GetDetails;

public class DetailQuery : IDetailQuery
{
    public Task<Response?> GetProductDetailsAsync(int productId, CancellationToken ct)
    {
        throw new NotImplementedException();
    }
}