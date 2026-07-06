CREATE OR ALTER PROCEDURE Sales.usp_GetOrderDashboard
    @CustomerID  int,
    @FromDate    date,
    @ToDate      date
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  o.SalesOrderID,
            o.CustomerID,
            o.OrderDate,
            o.Status,
            o.ShipMethodID,
            o.ShipDate,
            o.ShipToAddressID
    INTO #CandidateOrders
    FROM Sales.SalesOrderHeader AS o
    WHERE o.CustomerID = @CustomerID
        AND o.OrderDate >= @FromDate
        AND o.OrderDate < DATEADD(day, 1, @ToDate);

    CREATE UNIQUE CLUSTERED INDEX CX_CandidateOrders
        ON #CandidateOrders(SalesOrderID);

    CREATE INDEX IX_CandidateOrders_Status
        ON #CandidateOrders(Status, OrderDate);

    -- Order summary
    SELECT  c.Status,
            COUNT_BIG(*) AS OrderCount
        FROM #CandidateOrders AS c
        GROUP BY c.Status;

    -- Payment details
    SELECT  c.SalesOrderID,
            p.TransactionType,
            p.ActualCost
        FROM #CandidateOrders AS c
            INNER JOIN [Production].[TransactionHistory] AS p
                ON p.ReferenceOrderID = c.SalesOrderID;

    -- Shipment details
    SELECT  c.SalesOrderID,
            c.ShipDate,
            c.ShipToAddressID,
            s.Name,
            s.ShipRate
        FROM #CandidateOrders AS c
            LEFT JOIN [Purchasing].[ShipMethod] AS s
                ON s.ShipMethodID = c.ShipMethodID;
END;
