# **Nexus API Specification**

## **Endpoints & Behavior**

### **1\. Consumer Endpoints**

#### **GET /api/products/{id}**

* **Description:** Retrieves full product details.  
* **Performance Goal:** \< 50ms (Cache Hit), \< 1000ms (Cache Miss).  
* **Expected Behavior:**  
  * First request triggers DB.  
  * Subsequent requests hit L1 or L2.  
  * If DB is slow (\>200ms) and cache exists, returns stale data immediately.

**Response Schema (200 OK)**  
```json
{  
  "id": 123,  
  "name": "Wireless Noise Cancelling Headphones",  
  "description": "Premium over-ear headphones with 30-hour battery life.",  
  "price": 299.99,  
  "category": "electronics",  
  "specs": {  
    "bluetooth": "5.0",  
    "weight": "250g",  
    "color": "black"  
  }  
}
```

#### **GET /api/products/{id}/stock**

* **Description:** Retrieves integer stock count.  
* **Performance Goal:** High Availability.  
* **Expected Behavior:**  
  * Cache expires every 5 seconds.  
  * **CRITICAL:** If ChaosRepository.IsDown \== true, this MUST return the last known stock level, not a 500 error.

**Response Schema (200 OK)**  
```json
{  
  "productId": 123,  
  "stockLevel": 450,  
  "isLowStock": false,  
  "lastUpdated": "2023-10-27T10:00:00Z",  
  "isStale": false // Optional: Helpful for debugging FusionCache fail-safe  
}
```

### **2\. Management Endpoints (Write/Invalidate)**

#### **PUT /api/products/{id}/price**

* **Description:** Updates DB and explicitly invalidates cache.  
* **Action:**  
  1. Update SQL.  
  2. Call \_cache.RemoveAsync($"product:{id}").  
* **Verification:** This must trigger the Redis Backplane to clear L1 cache on *other* nodes.

**Request Schema**  
```json
{  
  "newPrice": 199.99  
}
```

**Response Schema (200 OK)**  
```json
{  
  "id": 123,  
  "price": 199.99,  
  "message": "Price updated and cache invalidated."  
}
```

#### **POST /api/admin/categories/{category}/reset**

* **Description:** Invalidates all products in a specific category.  
* **Action:** Call \_cache.RemoveByTagAsync($"category:{category}").

**Response Schema (200 OK)**  
```json
{  
  "category": "electronics",  
  "action": "Cache Cleared",  
  "timestamp": "2023-10-27T10:05:00Z"  
}
```

### **3\. Chaos Control Endpoints (For Testing Only)**

#### **POST /api/chaos/config**

* **Description:** Adjusts the static settings in ChaosRepository to simulate production failures.

**Request Schema**  
```json
{  
  "isDatabaseDown": true,  
  "latencyMs": 5000  
}
```

**Response Schema (200 OK)**  
```json
{  
  "status": "Chaos Configured",  
  "currentSettings": {  
    "isDatabaseDown": true,  
    "latencyMs": 5000  
  }  
}
```
