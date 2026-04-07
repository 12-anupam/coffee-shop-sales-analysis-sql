-- CREATE DATABASE Coffee_shop_sales;
USE Coffee_shop_sales;

-- DESCRIBE coffee;

-- Changing the data type of the columns
-- transaction_date
-- UPDATE coffee
-- SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');


-- ALTER TABLE coffee
-- MODIFY COLUMN transaction_time TIME;


-- SET SQL_SAFE_UPDATES = 0;
SELECT * FROM coffee;

ALTER TABLE coffee
CHANGE COLUMN ï»¿transaction_id transaction_id INT;




-- BUISNESS REQUIREMENTS
-- KPI REQUIREMENTS


-- TOTAL SALES FOR EACH RESPECTIVE MONTH
SELECT
MONTHNAME(transaction_date) AS Months,
ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffee
GROUP BY Months
ORDER BY Total_Sales DESC
LIMIT 2,1;



-- DETERMINE THE MONTH ON MONTH INCREASE OR DECREASE IN SALES.
SELECT
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM coffee
WHERE MONTH(transaction_date) IN (4, 5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);




-- Total number of Orders for each respective months
SELECT
MONTHNAME(transaction_date) AS Months,
COUNT(DISTINCT(transaction_id)) AS Total_Number_of_Orders
FROM coffee
GROUP BY MONTHNAME(transaction_date),  MONTH(transaction_date)
ORDER BY MONTH(transaction_date) ASC;





-- DETERMINE THE MONTH ON MONTH INCREASE OR DECREASE IN ORDERS.
SELECT
    MONTH(transaction_date) AS month,
    MONTHNAME(transaction_date) AS Month_Name,
    ROUND(COUNT(transaction_id)) AS total_orders,
    COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) OVER (ORDER BY MONTH(transaction_date)) AS diff_in_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) OVER (ORDER BY MONTH(transaction_date))) 
    / LAG(COUNT(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM coffee
WHERE MONTH(transaction_date) IN (4, 5)
GROUP BY MONTH(transaction_date), MONTHNAME(transaction_date)
ORDER BY MONTH(transaction_date);





-- Total Quantity sold analysis

SELECT 
MONTHNAME(transaction_date) AS Month,
SUM(transaction_qty) AS Total_qty_sold
FROM coffee
GROUP BY MONTH(transaction_date),Month
ORDER BY MONTH(transaction_date);



-- DETERMINE THE MONTH ON MONTH INCREASE OR DECREASE IN TOTAL QUANTITY SOLD.
SELECT
    MONTH(transaction_date) AS month,
    MONTHNAME(transaction_date) AS Month_Name,
    ROUND(SUM(transaction_qty)) AS total_qty_sold,
    SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date)) AS diff_in_qty,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) OVER (ORDER BY MONTH(transaction_date))) 
    / LAG(SUM(transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM coffee
WHERE MONTH(transaction_date) IN (4, 5)
GROUP BY MONTH(transaction_date), MONTHNAME(transaction_date)
ORDER BY MONTH(transaction_date);



-- CALENDAR HEAT MAP
SELECT
CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'k') AS Total_Sales,
CONCAT(ROUND(SUM(transaction_qty) / 1000,1),'K') AS Total_Quantity_Sold,
CONCAT(ROUND(COUNT(transaction_id) / 1000,1), 'K') AS Total_Orders
FROM coffee
WHERE transaction_date = '2023-05-18';


-- SALES ANALYSIS BY WEEKDAYS AND WEEKENDS    1= Sunday, 2 = Monday......
SELECT
	CASE WHEN DAYOFWEEK(transaction_Date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'k') AS Total_Sales
FROM coffee
WHERE MONTH(transaction_date) = 2 -- FEB MONTH
GROUP BY 
	day_type;

SELECT * FROM coffee;

-- Sales analysis by store location
SELECT 
	store_location AS Location,
	MONTHNAME(transaction_date) AS Month,
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'k') AS Total_Sales
FROM coffee
WHERE MONTH(transaction_date) = 2 -- feb
GROUP BY store_location, Month
ORDER BY Total_Sales DESC;



-- DAILY SALES ANALYSIS WITH AVERAGE LINE
SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS Avg_Sales
FROM
	(
		SELECT SUM(transaction_qty * unit_price) AS total_sales
        FROM coffee 
		WHERE MONTH(transaction_date) = 5 -- may;
		GROUP BY transaction_Date
    ) AS Inner_Query;
    

-- DAILY SALES FOR MONTH SELECTED 
SELECT 
	DAY(transaction_date) AS day_of_month,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'k') AS Total_Sales
FROM coffee
WHERE MONTH(transaction_date) = 5 -- may;
GROUP BY day_of_month
ORDER BY day_of_month;

-- COMPARING DAILY SALES WITH AVERAGE SALES- IF GREATER THAN "ABOVE AVERAGE" AND LESSER THAN "BELOW AVERAGE".
SELECT
    day_of_month,
    CASE
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM coffee
    WHERE MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY DAY(transaction_date)
) AS sales_data
ORDER BY day_of_month;


SELECT * FROM coffee;


-- SALES ANALYSIS BY PRODUCT CATEGORY
SELECT 
    product_category AS Category,
    MONTHNAME(transaction_date) AS Month,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'k') AS Total_Sales
FROM coffee
WHERE MONTH(transaction_date) = 5 -- May
GROUP BY Month, Category
ORDER BY SUM(unit_price * transaction_qty) DESC;


-- TOP 10 PRODUCTS BY SALES
SELECT 
	product_type AS PRODUCTS,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'k') AS Total_Sales
FROM coffee
WHERE MONTH(transaction_date) = 5 -- may
GROUP BY PRODUCTS
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;


-- SALES ANALYSIS BY DAYS AND HOURS
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'k') AS Total_Sales,
    SUM(transaction_qty) AS total_qty_sold,
    COUNT(*) AS Total_Orders
FROM coffee
WHERE MONTH(transaction_date) = 5 -- MAY
AND DAYOFWEEK(transaction_date) = 2 -- MONDAY
AND HOUR(transaction_time) = 8 -- HOUR 8;