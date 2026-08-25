-- View the original dataset before making any changes.
SELECT *
FROM us_regional_sales_data
;

-- Check the total number of records.
SELECT COUNT(*)
FROM us_regional_sales_data
;

-- Create a backup table before modifying the original dataset.
CREATE TABLE us_regional_sales_backup
LIKE us_regional_sales_data
;

-- Verify that the original and backup tables contain the same number of records.
SELECT COUNT(*)
FROM us_regional_sales_data
;

SELECT COUNT(*)
FROM us_regional_sales_backup
;

-- Rename ID fields for cleaner column names.
ALTER TABLE us_regional_sales_data
CHANGE _SalesTeamID SalesTeamID INT,
CHANGE _CustomerID CustomerID INT,
CHANGE _StoreID StoreID INT,
CHANGE _ProductID ProductID INT
;

-- Identify duplicate Order Numbers.
SELECT OrderNumber, COUNT(OrderNumber)
FROM us_regional_sales_data
GROUP BY OrderNumber
HAVING COUNT(OrderNumber) > 1
;

-- Check for NULL values in the dataset.
SELECT *
FROM us_regional_sales_data
WHERE OrderNumber IS NULL
OR `Sales Channel` IS NULL
OR WarehouseCode IS NULL
OR ProcuredDate IS NULL
OR OrderDate IS NULL
OR ShipDate IS NULL
OR DeliveryDate IS NULL
OR CurrencyCode IS NULL
OR SalesTeamID IS NULL
OR CustomerID IS NULL
OR StoreID IS NULL
OR ProductID IS NULL
OR `Order Quantity` IS NULL
OR `Discount Applied` IS NULL
OR `Unit Cost` IS NULL
OR `Unit Price` IS NULL
;

-- Check for blank values in text columns.
SELECT *
FROM us_regional_sales_data
WHERE `Sales Channel` = ''
OR WarehouseCode = ''
OR ProcuredDate = ''
OR OrderDate = ''
OR ShipDate = ''
OR DeliveryDate = ''
OR CurrencyCode = ''
OR `Unit Cost` = ''
OR `Unit Price` = ''
;

-- Review the different Sales Channel values.
SELECT DISTINCT `Sales Channel`
FROM us_regional_sales_data
;

-- Review the different Warehouse Codes.
SELECT DISTINCT WarehouseCode
FROM us_regional_sales_data
;

-- Review the different Currency Codes.
SELECT DISTINCT CurrencyCode
FROM us_regional_sales_data
;

-- Add new columns to convert the date fields from text to DATE.
ALTER TABLE us_regional_sales_data
ADD COLUMN ProcuredDate_New DATE,
ADD COLUMN OrderDate_New DATE,
ADD COLUMN ShipDate_New DATE,
ADD COLUMN DeliveryDate_New DATE
;

-- Convert dates with two-digit or four-digit years into proper DATE values.
UPDATE us_regional_sales_data
SET ProcuredDate_New =
	CASE
		WHEN LENGTH(SUBSTRING_INDEX(ProcuredDate, '/', -1)) = 2
			THEN STR_TO_DATE(ProcuredDate, '%d/%m/%y')
		ELSE STR_TO_DATE(ProcuredDate, '%d/%m/%Y')
	END,

	OrderDate_New =
	CASE
		WHEN LENGTH(SUBSTRING_INDEX(OrderDate, '/', -1)) = 2
			THEN STR_TO_DATE(OrderDate, '%d/%m/%y')
		ELSE STR_TO_DATE(OrderDate, '%d/%m/%Y')
	END,

	ShipDate_New =
	CASE
		WHEN LENGTH(SUBSTRING_INDEX(ShipDate, '/', -1)) = 2
			THEN STR_TO_DATE(ShipDate, '%d/%m/%y')
		ELSE STR_TO_DATE(ShipDate, '%d/%m/%Y')
	END,

	DeliveryDate_New =
	CASE
		WHEN LENGTH(SUBSTRING_INDEX(DeliveryDate, '/', -1)) = 2
			THEN STR_TO_DATE(DeliveryDate, '%d/%m/%y')
		ELSE STR_TO_DATE(DeliveryDate, '%d/%m/%Y')
	END
;

-- Verify that the date fields were converted correctly.
SELECT
	ProcuredDate,
	ProcuredDate_New,
	OrderDate,
	OrderDate_New,
	ShipDate,
	ShipDate_New,
	DeliveryDate,
	DeliveryDate_New
FROM us_regional_sales_data
LIMIT 20
;

-- Check that the date conversion did not create NULL values.
SELECT *
FROM us_regional_sales_data
WHERE ProcuredDate_New IS NULL
OR OrderDate_New IS NULL
OR ShipDate_New IS NULL
OR DeliveryDate_New IS NULL
;

-- Replace the original text date columns with the converted DATE columns.
ALTER TABLE us_regional_sales_data
DROP COLUMN ProcuredDate,
DROP COLUMN OrderDate,
DROP COLUMN ShipDate,
DROP COLUMN DeliveryDate
;

-- Rename the new DATE columns to the original column names.
ALTER TABLE us_regional_sales_data
CHANGE ProcuredDate_New ProcuredDate DATE,
CHANGE OrderDate_New OrderDate DATE,
CHANGE ShipDate_New ShipDate DATE,
CHANGE DeliveryDate_New DeliveryDate DATE
;

-- Check for Ship Dates that occur before Order Dates.
SELECT *
FROM us_regional_sales_data
WHERE ShipDate < OrderDate
;

-- Check for Delivery Dates that occur before Ship Dates.
SELECT *
FROM us_regional_sales_data
WHERE DeliveryDate < ShipDate
;

-- Add new numeric columns for Unit Cost and Unit Price.
ALTER TABLE us_regional_sales_data
ADD COLUMN UnitCost_New DECIMAL(10,2),
ADD COLUMN UnitPrice_New DECIMAL(10,2)
;

-- Remove dollar signs and commas and convert Unit Cost and Unit Price to numeric values.
UPDATE us_regional_sales_data
SET UnitCost_New =
	CAST(
		REPLACE(REPLACE(`Unit Cost`, '$', ''), ',', '')
		AS DECIMAL(10,2)
	),

	UnitPrice_New =
	CAST(
		REPLACE(REPLACE(`Unit Price`, '$', ''), ',', '')
		AS DECIMAL(10,2)
	)
;

-- Verify that Unit Cost and Unit Price were converted correctly.
SELECT
	`Unit Cost`,
	UnitCost_New,
	`Unit Price`,
	UnitPrice_New
FROM us_regional_sales_data
LIMIT 20
;

-- Check that the numeric conversion did not create NULL values.
SELECT *
FROM us_regional_sales_data
WHERE UnitCost_New IS NULL
OR UnitPrice_New IS NULL
;

-- Replace the original text Unit Cost and Unit Price columns.
ALTER TABLE us_regional_sales_data
DROP COLUMN `Unit Cost`,
DROP COLUMN `Unit Price`
;

-- Rename the new numeric columns to the original column names.
ALTER TABLE us_regional_sales_data
CHANGE UnitCost_New `Unit Cost` DECIMAL(10,2),
CHANGE UnitPrice_New `Unit Price` DECIMAL(10,2)
;

-- Check for invalid Order Quantity values.
SELECT *
FROM us_regional_sales_data
WHERE `Order Quantity` <= 0
;

-- Check for invalid Unit Cost or Unit Price values.
SELECT *
FROM us_regional_sales_data
WHERE `Unit Cost` <= 0
OR `Unit Price` <= 0
;

-- Check for Discount Applied values outside the expected range.
SELECT *
FROM us_regional_sales_data
WHERE `Discount Applied` < 0
OR `Discount Applied` > 1
;

-- Review the final data types after cleaning.
DESCRIBE us_regional_sales_data
;

-- Check the final number of records.
SELECT COUNT(*)
FROM us_regional_sales_data
;

-- Review the final cleaned dataset.
SELECT *
FROM us_regional_sales_data
;
