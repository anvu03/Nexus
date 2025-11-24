using FastEndpoints;

namespace Nexus.Features.Products.GetDetails;

public class GetProductEndpoint : EndpointWithoutRequest<Response>
{
    public override void Configure()
    {
        Get("/products/{id:int}");
        Description(b => b
            .WithTags("Products")
            .Produces<Response>(200)
            .Produces(404));
    }

    public override async Task HandleAsync(CancellationToken ct)
    {
        var productId = Route<int>("id");
    }
}