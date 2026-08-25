-- 1. Overall Business Performance
-- Establishes the company's overall sales and profitability baseline.
SELECT
    COUNT(DISTINCT OrderNumber) AS Total_Orders,
    SUM(`Order Quantity`) AS Total_Units_Sold,
    ROUND(SUM(`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)), 2) AS Total_Revenue,
    ROUND(SUM((`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)) -
        (`Order Quantity` * `Unit Cost`)), 2) AS Total_Profit,
    ROUND(
        SUM((`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) -
            (`Order Quantity` * `Unit Cost`))
        /
        SUM(`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) * 100,
        2
    ) AS Overall_Profit_Margin,
    ROUND(
        SUM(`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`))
        / COUNT(DISTINCT OrderNumber),
        2
    ) AS Avg_Order_Value
FROM us_regional_sales_data
;

-- 2. Product Performance and Profitability
-- Compares product sales volume, revenue, profit, and profit margins to identify both strong performers and less profitable products.
SELECT
    ProductID,
    SUM(`Order Quantity`) AS Units_Sold,
    ROUND(SUM(`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)), 2) AS Revenue,
    ROUND(SUM((`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)) -
        (`Order Quantity` * `Unit Cost`)), 2) AS Profit,
    ROUND(
        SUM((`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) -
            (`Order Quantity` * `Unit Cost`))
        /
        SUM(`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM us_regional_sales_data
GROUP BY ProductID
ORDER BY Profit DESC
;

-- 3. Sales Channel Performance
-- Compares channels by volume, revenue, profitability, and average order value to determine how each channel contributes to performance.
SELECT
    `Sales Channel`,
    COUNT(DISTINCT OrderNumber) AS Total_Orders,
    SUM(`Order Quantity`) AS Units_Sold,
    ROUND(SUM(`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)), 2) AS Revenue,
    ROUND(SUM((`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)) -
        (`Order Quantity` * `Unit Cost`)), 2) AS Profit,
    ROUND(
        SUM((`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) -
            (`Order Quantity` * `Unit Cost`))
        /
        SUM(`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) * 100,
        2
    ) AS Profit_Margin_Percent,
    ROUND(
        SUM(`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`))
        / COUNT(DISTINCT OrderNumber),
        2
    ) AS Avg_Order_Value
FROM us_regional_sales_data
GROUP BY `Sales Channel`
ORDER BY Revenue DESC
;

-- 4. Warehouse Performance
-- Compares warehouses by workload, revenue, profit, and margin to identify operational locations with stronger or weaker performance.
SELECT
    WarehouseCode,
    COUNT(DISTINCT OrderNumber) AS Total_Orders,
    SUM(`Order Quantity`) AS Units_Sold,
    ROUND(SUM(`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)), 2) AS Revenue,
    ROUND(SUM((`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)) -
        (`Order Quantity` * `Unit Cost`)), 2) AS Profit,
    ROUND(
        SUM((`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) -
            (`Order Quantity` * `Unit Cost`))
        /
        SUM(`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM us_regional_sales_data
GROUP BY WarehouseCode
ORDER BY Profit DESC
;

-- 5. Warehouse Fulfillment Performance
-- Compares average order-to-delivery time with warehouse order volume to identify possible fulfillment bottlenecks.
SELECT
    WarehouseCode,
    COUNT(DISTINCT OrderNumber) AS Total_Orders,
    SUM(`Order Quantity`) AS Units_Sold,
    ROUND(AVG(DATEDIFF(DeliveryDate, OrderDate)), 2)
        AS Avg_Days_To_Deliver,
    MIN(DATEDIFF(DeliveryDate, OrderDate))
        AS Fastest_Delivery_Days,
    MAX(DATEDIFF(DeliveryDate, OrderDate))
        AS Slowest_Delivery_Days
FROM us_regional_sales_data
GROUP BY WarehouseCode
ORDER BY Avg_Days_To_Deliver
;

-- 6. Customer Revenue Concentration
-- Identifies the highest-value customers and compares their revenue, profit, and order activity to reveal customer concentration.
SELECT
    CustomerID,
    COUNT(DISTINCT OrderNumber) AS Total_Orders,
    SUM(`Order Quantity`) AS Units_Sold,
    ROUND(SUM(`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)), 2) AS Revenue,
    ROUND(SUM((`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)) -
        (`Order Quantity` * `Unit Cost`)), 2) AS Profit,
    ROUND(
        SUM(`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`))
        / COUNT(DISTINCT OrderNumber),
        2
    ) AS Avg_Order_Value
FROM us_regional_sales_data
GROUP BY CustomerID
ORDER BY Revenue DESC
LIMIT 10
;

-- 7. Monthly Sales and Profit Trends
-- Tracks monthly performance over time to identify growth, declines, and possible seasonal patterns.
SELECT
    YEAR(OrderDate) AS Order_Year,
    MONTH(OrderDate) AS Month_Number,
    MONTHNAME(OrderDate) AS Month_Name,
    COUNT(DISTINCT OrderNumber) AS Total_Orders,
    ROUND(SUM(`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)), 2) AS Revenue,
    ROUND(SUM((`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)) -
        (`Order Quantity` * `Unit Cost`)), 2) AS Profit,
    ROUND(
        SUM((`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) -
            (`Order Quantity` * `Unit Cost`))
        /
        SUM(`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM us_regional_sales_data
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate),
    MONTHNAME(OrderDate)
ORDER BY Order_Year, Month_Number
;

-- 8. Discount Impact on Profitability
-- Examines whether higher discount levels are associated with changes in order volume, revenue, profit, and profit margins.
SELECT
    ROUND(`Discount Applied` * 100, 0) AS Discount_Percent,
    COUNT(DISTINCT OrderNumber) AS Total_Orders,
    SUM(`Order Quantity`) AS Units_Sold,
    ROUND(SUM(`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)), 2) AS Revenue,
    ROUND(SUM((`Order Quantity` * `Unit Price` *
        (1 - `Discount Applied`)) -
        (`Order Quantity` * `Unit Cost`)), 2) AS Profit,
    ROUND(
        SUM((`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) -
            (`Order Quantity` * `Unit Cost`))
        /
        SUM(`Order Quantity` * `Unit Price` *
            (1 - `Discount Applied`)) * 100,
        2
    ) AS Profit_Margin_Percent
FROM us_regional_sales_data
GROUP BY ROUND(`Discount Applied` * 100, 0)
ORDER BY Discount_Percent
;
