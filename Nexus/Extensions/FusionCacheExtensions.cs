using ZiggyCreatures.Caching.Fusion;
using ZiggyCreatures.Caching.Fusion.Serialization.SystemTextJson;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Caching.StackExchangeRedis;
using ZiggyCreatures.Caching.Fusion.Backplane.StackExchangeRedis;

namespace Nexus.Extensions;

public static class FusionCacheExtensions
{
    public static IServiceCollection AddNexusFusionCache(this IServiceCollection services, IConfiguration configuration)
    {
        // Standard FusionCache Setup with Enterprise features: L1+L2, Backplane, and Serialization
        services.AddFusionCache()
            .WithDefaultEntryOptions(options =>
            {
                options.Duration = TimeSpan.FromMinutes(5);
                options.FailSafeMaxDuration = TimeSpan.FromHours(2); // If DB dies, keep data for 2h
                options.FailSafeThrottleDuration = TimeSpan.FromSeconds(30); // Retry DB every 30s
                options.FactorySoftTimeout = TimeSpan.FromMilliseconds(500); // If DB takes >500ms, use stale data
            })
            .WithSerializer(
                new FusionCacheSystemTextJsonSerializer()
            )
            .WithDistributedCache(
                new RedisCache(new RedisCacheOptions 
                { 
                    Configuration = configuration.GetConnectionString("Redis") ?? "localhost:6379" 
                })
            )
            .WithBackplane(
                new RedisBackplane(new RedisBackplaneOptions 
                { 
                    Configuration = configuration.GetConnectionString("Redis") ?? "localhost:6379" 
                })
            );

        return services;
    }
}
