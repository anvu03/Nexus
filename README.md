# **Nexus: High-Volume Inventory System**

## **A FusionCache Reference Architecture**

### **1\. Project Overview**

**Nexus** is a .NET 8 REST API designed to simulate a high-traffic e-commerce inventory system (e.g., "Flash Sales").  
It is built specifically to demonstrate and master **Enterprise Caching Patterns** using [FusionCache](https://github.com/ZiggyCreatures/FusionCache). It handles common distributed system failures—such as database outages, slow queries, and cache stampedes—without downtime.

### **2\. Learning Goals**

This project forces engineers to solve the following problems:

* **The Thundering Herd:** Preventing thousands of concurrent requests from crashing the DB.  
* **The Slow Database:** Hiding DB latency using Soft Timeouts.  
* **The Outage:** Serving stale data (Fail-Safe) when the DB is offline.  
* **Distributed Inconsistency:** Syncing memory caches across servers using Redis Pub/Sub.

### **3\. Documentation Index**

The project documentation is split into specific domains:

| File | Description |
| :---- | :---- |
| **[01 Architecture Overview](https://www.google.com/search?q=01_Architecture_Overview.md)** | High-level topology, stack choices (L1+L2), and design principles. |
| [**02 Implementation Guide**](https://www.google.com/search?q=02_Implementation_Guidelines.md) | C\# code patterns for Factory Locking, Fail-Safe, and Tagging. |
| [**03 API Contract**](https://www.google.com/search?q=03_API_Contract.md) | JSON schemas for consumer and chaos-control endpoints. |
| [**04 Chaos Test Plan**](https://www.google.com/search?q=04_Chaos_Test_Plan.md) | Step-by-step scenarios to verify resilience (e.g., shutting down DB). |
| [**05 Data Model**](https://www.google.com/search?q=05_Data_Model.md) | ER Diagram separating "Heavy" Product data from "Volatile" Stock data. |
| [**06 DDL Schema**](https://www.google.com/search?q=06_DDL_Schema.sql) | SQL Server scripts to create the database structure. |
| [**07 DML Seed Data**](https://www.google.com/search?q=07_DML_SeedData.sql) | Seed data matching the API documentation examples. |

### **4\. Quick Start**

#### **Prerequisites**

* .NET 8 SDK  
* Docker (for Redis)  
* SQL Server (LocalDB or Docker)

#### **Step 1: Infrastructure Setup**

Start a local Redis instance:  
docker run \--name nexus-redis \-p 6379:6379 \-d redis

Run the SQL scripts (06\_DDL\_Schema.sql and 07\_DML\_SeedData.sql) against your local SQL Server instance to create the NexusDb.

#### **Step 2: Application Configuration**

Update your appsettings.json (or Program.cs) to point to your local infrastructure:  
"ConnectionStrings": {  
  "Redis": "localhost:6379",  
  "SqlDb": "Server=(localdb)\\\\mssqllocaldb;Database=NexusDb;Trusted\_Connection=True;"  
}

#### **Step 3: Running the "Cluster"**

To test the Backplane, you must run **two** instances of the API simultaneously on different ports.  
**Terminal 1 (Instance A):**  
dotnet run \--urls="http://localhost:5000"

**Terminal 2 (Instance B):**  
dotnet run \--urls="http://localhost:5001"

### **5\. How to Run Chaos Tests**

You can control the stability of the application at runtime using the Chaos API.  
**To Simulate a Slow Database (Test Soft Timeouts):**  
curl \-X POST http://localhost:5000/api/chaos/config \\  
   \-H "Content-Type: application/json" \\  
   \-d '{"latencyMs": 2000, "isDatabaseDown": false}'

**To Simulate a Total Outage (Test Fail-Safe):**  
curl \-X POST http://localhost:5000/api/chaos/config \\  
   \-H "Content-Type: application/json" \\  
   \-d '{"isDatabaseDown": true}'  
