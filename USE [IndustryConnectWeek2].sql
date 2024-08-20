USE [IndustryConnectWeek2]
GO

/****** Object:  UserDefinedFunction [dbo].[GetCustomerAmount]    Script Date: 03/06/2024 16:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetCustomerAmount] (@CustomerId INT)
RETURNS MONEY
AS
BEGIN
    RETURN (SELECT SUM(price) FROM CustomerSales WHERE [Customer Id] = @CustomerId);
END
GO

/****** Object:  UserDefinedFunction [dbo].[CalculateAge]    Script Date: 03/06/2024 16:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CalculateAge] (@DateOfBirth DATETIME)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;

    SET @Age = DATEDIFF(YEAR, @DateOfBirth, GETDATE()) - 
               CASE 
                   WHEN MONTH(@DateOfBirth) > MONTH(GETDATE()) 
                        OR (MONTH(@DateOfBirth) = MONTH(GETDATE()) AND DAY(@DateOfBirth) > DAY(GETDATE())) 
                   THEN 1 
                   ELSE 0 
               END;

    RETURN @Age;
END
GO

/****** Object:  Table [dbo].[Customer]    Script Date: 03/06/2024 16:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Customer](
    [Id] [int] IDENTITY(1,1) NOT NULL,
      NULL,
      NULL,
    [DateOfBirth] [datetime] NULL,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([Id] ASC)
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Product]    Script Date: 03/06/2024 16:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Product](
    [Id] [int] IDENTITY(1,1) NOT NULL,
      NULL,
    [Description] [nvarchar](max) NULL,
    [Active] [bit] NULL,
    [Price] [money] NULL,
    CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED ([Id] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Sale]    Script Date: 03/06/2024 16:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Sale](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [CustomerId] [int] NULL,
    [ProductId] [int] NULL,
    [StoreId] [int] NULL, -- Added StoreId to link sales to stores
    [DateSold] [datetime] NULL,
    CONSTRAINT [PK_Sale] PRIMARY KEY CLUSTERED ([Id] ASC)
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Store] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Store](
    [Id] [int] IDENTITY(1,1) NOT NULL,
      NOT NULL,
      NOT NULL,
    CONSTRAINT [PK_Store] PRIMARY KEY CLUSTERED ([Id] ASC)
) ON [PRIMARY];
GO

-- Adding the foreign key constraint to link the StoreId in Sale table to the Store table
ALTER TABLE [dbo].[Sale]
ADD CONSTRAINT [FK_Sale_Store] FOREIGN KEY ([StoreId])
REFERENCES [dbo].[Store]([Id]);
GO

/****** Object:  View [dbo].[CustomerSales]    Script Date: 03/06/2024 16:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[CustomerSales]
AS
SELECT 
    c.Id AS 'Customer Id', 
    c.FirstName, 
    c.LastName, 
    (c.FirstName + ' ' + c.LastName) AS 'Full Name', -- Concatenating FirstName and LastName
    s.DateSold, 
    p.[Name], 
    p.Price,
    [dbo].[GetCustomerAmount](c.Id) AS 'Total Purchases'
FROM Customer c
LEFT JOIN Sale s ON c.Id = s.CustomerId
LEFT JOIN Product p ON s.ProductId = p.Id;
GO

SET IDENTITY_INSERT [dbo].[Customer] ON 
GO

INSERT [dbo].[Customer] ([Id], [FirstName], [LastName], [DateOfBirth]) VALUES (1, N'Andy', N'Mckelvey', CAST(N'2000-12-12T00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Customer] ([Id], [FirstName], [LastName], [DateOfBirth]) VALUES (2, N'Callum', N'Jones', CAST(N'2000-12-12T00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Customer] ([Id], [FirstName], [LastName], [DateOfBirth]) VALUES (3, N'Abigail', N'Smith', CAST(N'1978-12-01T00:00:00.000' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[Customer] OFF
GO

SET IDENTITY_INSERT [dbo].[Product] ON 
GO

INSERT [dbo].[Product] ([Id], [Name], [Description], [Active], [Price]) VALUES (1, N'Washing Machine', N'Washing Machine', 1, 200.0000)
GO
INSERT [dbo].[Product] ([Id], [Name], [Description], [Active], [Price]) VALUES (2, N'Television', N'Television', 1, 450.0000)
GO
INSERT [dbo].[Product] ([Id], [Name], [Description], [Active], [Price]) VALUES (3, N'Toaster', N'Toaster', 1, 45.5000)
GO
INSERT [dbo].[Product] ([Id], [Name], [Description], [Active], [Price]) VALUES (4, N'Kettle', NULL, 1, 15.0000)
GO

SET IDENTITY_INSERT [dbo].[Product] OFF
GO

SET IDENTITY_INSERT [dbo].[Sale] ON 
GO

INSERT [dbo].[Sale] ([Id], [CustomerId], [ProductId], [StoreId], [DateSold]) VALUES (1, 1, 2, NULL, CAST(N'2024-06-03T00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Sale] ([Id], [CustomerId], [ProductId], [StoreId], [DateSold]) VALUES (2, 2, 1, NULL, CAST(N'2024-06-03T00:00:00.000' AS DateTime))
GO
INSERT [dbo].[Sale] ([Id], [CustomerId], [ProductId], [StoreId], [DateSold]) VALUES (3, 1, 3, NULL, CAST(N'2024-06-03T00:00:00.000' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[Sale] OFF
GO

ALTER TABLE [dbo].[Sale]  WITH CHECK ADD  CONSTRAINT [FK_Sale_Customer] FOREIGN KEY([CustomerId])
REFERENCES [dbo].[Customer] ([Id])
GO
ALTER TABLE [dbo].[Sale] CHECK CONSTRAINT [FK_Sale_Customer]
GO
ALTER TABLE [dbo].[Sale]  WITH CHECK ADD  CONSTRAINT [FK_Sale_Product] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Product] ([Id])
GO
ALTER TABLE [dbo].[Sale] CHECK CONSTRAINT [FK_Sale_Product]
GO

/****** Object:  StoredProcedure [dbo].[InsertProduct]    Script Date: 03/06/2024 16:21:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertProduct] @Name NVARCHAR(100), @Price MONEY
AS
BEGIN
    INSERT INTO [dbo].[Product]([Name], Price, Active)
    VALUES (@Name, @Price, 1)
END
GO
