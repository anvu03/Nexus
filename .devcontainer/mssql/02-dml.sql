-- Nexus Inventory System
-- DML: Seed Data for Testing
-- Note: We force IDs to match the API Documentation examples

USE [ApplicationDB];
GO

-- 1. Seed Categories
SET IDENTITY_INSERT dbo.Categories ON;

INSERT INTO dbo.Categories (Id, Name, Description) VALUES 
(1, 'electronics', 'Gadgets, devices, and accessories'),
(2, 'books', 'Physical and digital books'),
(3, 'home', 'Home goods and furniture');

SET IDENTITY_INSERT dbo.Categories OFF;
GO

-- 2. Seed Products
SET IDENTITY_INSERT dbo.Products ON;

INSERT INTO dbo.Products (Id, CategoryId, Name, Description, CurrentPrice, Specs, CreatedAt, UpdatedAt) VALUES 
(1, 1, 'Wireless Noise Cancelling Headphones', 'Premium over-ear headphones with 30-hour battery life and industry-leading noise cancellation.', 299.99, N'{"bluetooth": "5.0", "weight": "250g", "color": "black", "battery": "30h"}', GETUTCDATE(), GETUTCDATE()),
(2, 1, '4K Ultra HD Monitor', '27-inch IPS display with 144Hz refresh rate, perfect for gaming and professional workflows.', 450.00, N'{"resolution": "3840x2160", "refreshRate": "144Hz", "panel": "IPS"}', GETUTCDATE(), GETUTCDATE()),
(3, 2, 'The Pragmatic Programmer', 'A classic programming book that covers best practices and software craftsmanship.', 45.50, N'{"author": "Andrew Hunt", "pages": 352, "cover": "hardcover"}', GETUTCDATE(), GETUTCDATE()),
(4, 3, 'Ergonomic Office Chair', 'Mesh back chair with lumbar support and adjustable armrests.', 120.00, N'{"material": "mesh", "color": "grey", "maxWeight": "150kg"}', GETUTCDATE(), GETUTCDATE());

SET IDENTITY_INSERT dbo.Products OFF;
GO

-- 3. Seed Inventory (Stock Levels)
-- Note: No IDENTITY_INSERT needed here as we rely on FKs, but we map manually based on known Product IDs above.

INSERT INTO dbo.Inventory (ProductId, StockLevel, LastCheckedAt) VALUES 
(1, 450, GETUTCDATE()), -- Headphones: Plenty of stock
(2, 12, GETUTCDATE()),  -- Monitor: Low stock (Test scenario!)
(3, 1000, GETUTCDATE()),-- Book: High stock
(4, 0, GETUTCDATE());    -- Chair: Out of stock

GO

-- 4. Seed Price History (Initial entries)
INSERT INTO dbo.PriceHistory (ProductId, Price, EffectiveDate) VALUES 
(1, 299.99, GETUTCDATE()),
(2, 450.00, GETUTCDATE()),
(3, 45.50, GETUTCDATE()),
(4, 120.00, GETUTCDATE());
GO

-- Verification Query
PRINT 'Seed Data Inserted Successfully.'
PRINT '-------- Products --------'
SELECT Id, Name, CurrentPrice FROM dbo.Products;
PRINT '-------- Inventory --------'
SELECT p.Name, i.StockLevel FROM dbo.Inventory i JOIN dbo.Products p ON i.ProductId = p.Id;1