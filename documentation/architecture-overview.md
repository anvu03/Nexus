# **Nexus: High-Volume Inventory System**

## **Architecture Overview & Design Document**

### **1\. Executive Summary**

Nexus is a high-performance inventory REST API designed to serve flash-sale traffic loads. It prioritizes availability and low latency over strict real-time consistency for product descriptions, while maintaining high availability for stock levels even during database outages.

### **2\. Infrastructure Topology**

The system operates on a **Multi-Layer Caching Architecture** designed for horizontal scaling (Kubernetes/App Service).

#### **The Layers**

* **Layer 0: The Client** (Http Client / Browser) \- Respects Cache-Control headers.  
* **Layer 1: Local Memory (L1)** \- In-process RAM. Nanosecond access. Stores "hot" items.  
  * *Constraint:* Data here is isolated to the specific server instance.  
* **Layer 2: Distributed Cache (L2)** \- Redis. Millisecond access. Shared state across all instances.  
  * *Constraint:* Network latency and serialization overhead.  
* **The Backplane:** Redis Pub/Sub.  
  * *Function:* When Instance A updates an item, it publishes a message. Instance B receives it and evicts that item from its L1 memory.

### **3\. Technology Stack**

* **Runtime:** .NET 8 / 9  
* **Primary Database:** PostgreSQL or SQL Server (Simulated Latency capable)  
* **Distributed Cache:** Redis (StackExchange.Redis)  
* **Caching Library:** FusionCache (ZiggyCreatures.FusionCache)  
* **Backplane:** FusionCache.Backplane.StackExchangeRedis

### **4\. Critical Design Principles**

1. **Database Protection:** The database should never be hit by thousands of concurrent requests for the same key (Cache Stampede).  
2. **Fail-Safe Default:** If the database is down, serve old data. A stale response is better than a 500 Error.  
3. **Background Updates:** Do not make the user wait for a cache refresh if slightly stale data is acceptable (Soft Timeouts).