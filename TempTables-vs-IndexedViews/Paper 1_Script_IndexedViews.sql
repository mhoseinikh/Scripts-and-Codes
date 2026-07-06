--Base query
SELECT  o.OrderDate,
        d.ProductID,
        SUM(d.OrderQty * d.UnitPrice) AS Revenue,
        COUNT_BIG(*) AS LineCount
    FROM Sales.SalesOrderHeader AS o
        INNER JOIN Sales.SalesOrderDetail AS d
            ON d.SalesOrderID = d.SalesOrderID
    GROUP BY o.OrderDate, d.ProductID;
GO

--An indexed-view implementation could be:
SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE VIEW Sales.vDailyProductRevenue
WITH SCHEMABINDING
AS
    SELECT  o.OrderDate,
            d.ProductID,
            SUM(CONVERT(decimal(19, 4), d.OrderQty * d.UnitPrice)) AS Revenue,
            COUNT_BIG(*) AS LineCount
        FROM Sales.SalesOrderHeader AS o
            INNER JOIN Sales.SalesOrderDetail AS d
                ON d.SalesOrderID = d.SalesOrderID
        GROUP BY o.OrderDate, d.ProductID;
GO

CREATE UNIQUE CLUSTERED INDEX CX_vDailyProductRevenue
    ON Sales.vDailyProductRevenue(OrderDate, ProductID);
GO

CREATE NONCLUSTERED INDEX IX_vDailyProductRevenue_Product
    ON Sales.vDailyProductRevenue(ProductID, OrderDate)
    INCLUDE (Revenue, LineCount);
GO

--Application query
SELECT  OrderDate,
        ProductID,
        Revenue,
        LineCount
    FROM Sales.vDailyProductRevenue
    WHERE ProductID = @ProductID
        AND OrderDate >= @FromDate
        AND OrderDate < @ToDate;

--On Standard or Express editions
SELECT  OrderDate,
        ProductID,
        Revenue,
        LineCount
    FROM Sales.vDailyProductRevenue WITH (NOEXPAND)
    WHERE ProductID = @ProductID
        AND OrderDate >= @FromDate
        AND OrderDate < @ToDate;
