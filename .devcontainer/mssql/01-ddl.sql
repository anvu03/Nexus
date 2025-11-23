-- Nexus Inventory System
-- DDL: Schema Definition for MS SQL Server

-- Ensure we are in the correct database context
USE [ApplicationDB];
GO

-- 1. Clean up existing tables if they exist (Drop Order respects FKs)
IF OBJECT_ID('dbo.PriceHistory', 'U') IS NOT NULL DROP TABLE dbo.PriceHistory;
IF OBJECT_ID('dbo.Inventory', 'U') IS NOT NULL DROP TABLE dbo.Inventory;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
GO

-- 2. Create Categories Table
CREATE TABLE dbo.Categories (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE, -- Unique for Tagging purposes
    Description NVARCHAR(255) NULL
);
GO

-- 3. Create Products Table (The "Heavy" Data)
CREATE TABLE dbo.Products (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CategoryId INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL, -- Heavy text
    CurrentPrice DECIMAL(18, 2) NOT NULL,
    Specs NVARCHAR(MAX) NULL, -- JSON blob for technical specs
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) 
        REFERENCES dbo.Categories (Id) ON DELETE CASCADE,
        
    -- Optional: Ensure Specs is valid JSON
    CONSTRAINT CK_Products_Specs_IsJSON CHECK (ISJSON(Specs) = 1)
);
GO

-- 4. Create Inventory Table (The "Volatile" Data)
CREATE TABLE dbo.Inventory (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductId INT NOT NULL UNIQUE, -- One inventory record per product
    StockLevel INT NOT NULL DEFAULT 0,
    LastCheckedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsReserved BIT NOT NULL DEFAULT 0,
    
    CONSTRAINT FK_Inventory_Products FOREIGN KEY (ProductId) 
        REFERENCES dbo.Products (Id) ON DELETE CASCADE
);
GO

-- 5. Create Price History Table (For Auditing)
CREATE TABLE dbo.PriceHistory (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ProductId INT NOT NULL,
    Price DECIMAL(18, 2) NOT NULL,
    EffectiveDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT FK_PriceHistory_Products FOREIGN KEY (ProductId) 
        REFERENCES dbo.Products (Id) ON DELETE CASCADE
);
GO

-- 6. Indexes for Performance
-- Index for Category Tagging lookups
CREATE INDEX IX_Products_CategoryId ON dbo.Products(CategoryId);