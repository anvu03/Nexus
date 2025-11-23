# **Nexus Implementation Guidelines**

## **FusionCache Configuration & Patterns**

### **1\. Dependency Injection Setup (Program.cs)**

This configuration enables the "Enterprise" features: L1+L2, Backplane, and Serialization.  
// Standard FusionCache Setup  
builder.Services.AddFusionCache()  
    .WithDefaultEntryOptions(options \=\> {  
        options.Duration \= TimeSpan.FromMinutes(5);  
        options.FailSafeMaxDuration \= TimeSpan.FromHours(2); // If DB dies, keep data for 2h  
        options.FailSafeThrottleDuration \= TimeSpan.FromSeconds(30); // Retry DB every 30s  
        options.FactorySoftTimeout \= TimeSpan.FromMilliseconds(500); // If DB takes \>500ms, use stale data  
    })  
    .WithSerializer(  
        new FusionCacheSystemTextJsonSerializer() // or Newtonsoft  
    )  
    .WithDistributedCache(  
        new RedisCache(new RedisCacheOptions { Configuration \= "localhost:6379" })  
    )  
    .WithBackplane(  
        new RedisBackplane(new RedisBackplaneOptions { Configuration \= "localhost:6379" })  
    );

### **2\. The "Chaos Repository" Pattern**

To effectively test FusionCache, we cannot use a standard Entity Framework repo. We must wrap it in a chaos simulator.  
Interface: IProductRepository  
Implementation: ChaosProductRepository  
**Features required:**

* bool IsDown: If true, GetByIdAsync throws a SqlException.  
* int LatencyMs: If \> 0, GetByIdAsync awaits Task.Delay.

### **3\. Caching Patterns per Data Type**

#### **Pattern A: "The Heavy Read" (Product Details)**

Use for: Product Descriptions, Specs, JSON Blobs.

* **Strategy:** Aggressive Caching \+ Soft Timeouts.  
* **Code Pattern:**  
  var product \= await \_cache.GetOrSetAsync(  
      $"product:{id}",  
      async (ctx) \=\> {  
          // If we are here, we are fetching from DB.  
          // If this takes too long, FusionCache will return the STALE value if available.  
          return await \_repo.GetByIdAsync(id);  
      },  
      options \=\> options.SetFactorySoftTimeout(TimeSpan.FromMilliseconds(200))  
  );

#### **Pattern B: "The Volatile Read" (Stock)**

Use for: Inventory Counts.

* **Strategy:** Short Duration \+ Fail-Safe.  
* **Code Pattern:**  
  var stock \= await \_cache.GetOrSetAsync(  
      $"stock:{id}",  
      async (ctx) \=\> await \_repo.GetStockAsync(id),  
      options \=\> options  
          .SetDuration(TimeSpan.FromSeconds(5)) // Expire fast  
          .SetFailSafeMaxDuration(TimeSpan.FromMinutes(30)) // But survive outages  
  );

#### **Pattern C: "The Categorical Purge" (Tagging)**

Use for: Clearing entire categories when an admin changes settings.

* **Code Pattern (Setting):**  
  // Inside GetOrSetAsync factory or setup  
  ctx.AddTag($"category:{product.CategoryId}");

* **Code Pattern (Evicting):**  
  await \_cache.RemoveByTagAsync($"category:{categoryId}");  
