SELECT *
FROM pricedata;

-- 1.	How many sales occurred during this time period? 
SELECT COUNT(*)
FROM pricedata;

-- 2.	Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date.
SELECT name, eth_price, usd_price 
FROM pricedata
ORDER BY usd_price DESC
LIMIT 5;

-- 3.	Return a table with a row for each transaction with an event column, a USD price column, and a moving average of USD price that averages the last 50 transactions.


-- 4.	Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.
SELECT name, AVG(usd_price) AS avg_price
FROM pricedata
GROUP BY name;

-- 5. Return each day of the week and the number of sales that occurred on that day of the week, as well as the average price in ETH. Order by the count of transactions in ascending order.
SELECT 
    DAYNAME(event_date) AS day_of_week,
    COUNT(*) AS number_of_sales,
    AVG(eth_price) AS average_price_in_eth
FROM 
    pricedata
GROUP BY 
    day_of_week
ORDER BY 
    number_of_sales ASC;
    
-- 6. Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, who bought the NFT, who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
SELECT 
    CONCAT(name,
            ' was sold for $ ',
            usd_price,
            ' to ',
            buyer_address,
            ' from ',
            seller_address,
            ' on ',
            event_date) AS summary
FROM
    pricedata;
    
-- 7.	Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.
CREATE VIEW 1919_purchases AS
SELECT * FROM pricedata WHERE buyer_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";

SELECT * FROM 1919_purchases;

-- 8.	Create a histogram of ETH price ranges. Round to the nearest hundred value. 


-- 9.	Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. The table should have a name column, a price column called price, and a status column. Order the result set by the name of the NFT, and the status, in ascending order.
SELECT 
    name, MAX(usd_price) AS high_price, 'highest' AS status
FROM
    pricedata
GROUP BY name 
UNION SELECT 
    name, MIN(usd_price) AS low_price, 'lowest' AS status
FROM
    pricedata
GROUP BY name
ORDER BY name ASC , status ASC; 

-- 10.	What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format. 
SELECT 
    name,
    SUM(usd_price) AS tot_usd_price,
    COUNT(name) AS sold_count,
    DATE_FORMAT(event_date, '%m / %y') AS month_year
FROM
    pricedata
GROUP BY name , month_year
ORDER BY sold_count DESC , month_year DESC;

-- 11.	Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).
SELECT 
    ROUND(SUM(usd_price), 2) AS tot_usd_price,
    DATE_FORMAT(event_date, '%M / %Y') AS month_year
FROM
    pricedata
GROUP BY month_year
ORDER BY MONTH(month_year) DESC , YEAR(month_year) DESC;

-- 12. Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.
SELECT COUNT(*) FROM 1919_purchases;

-- 13.	Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
-- Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
-- Take the daily average of remaining transactions
-- a) First create a query that will be used as a subquery. Select the event date, the USD price, and the average USD price for each day using a window function. Save it as a temporary table.
-- b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and return a new estimated value which is just the daily average of the filtered data.


CREATE TEMPORARY TABLE Avg_price_per_day
SELECT 
    AVG(usd_price) AS avg_usd_price,
    COUNT(name) AS sold_count,
    DATE_FORMAT(event_date, '%d/%m/%Y') AS date_month_year
FROM
    pricedata
GROUP BY date_month_year
ORDER BY date_month_year ;

SELECT * FROM Avg_price_per_day;

SELECT name, usd_price, Avg_price_per_day.avg_usd_price, event_date FROM pricedata
LEFT JOIN Avg_price_per_day
ON DATE_FORMAT(event_date, '%d/%m/%Y') = Avg_price_per_day.date_month_year ; 

-- Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
SELECT name, usd_price, Avg_price_per_day.avg_usd_price, event_date FROM pricedata
LEFT JOIN Avg_price_per_day
ON DATE_FORMAT(event_date, '%d/%m/%Y') = Avg_price_per_day.date_month_year 
WHERE usd_price > avg_usd_price * 0.1 ; 

-- Take the daily average of remaining transactions
SELECT name, usd_price, Avg_price_per_day.avg_usd_price, event_date FROM pricedata
LEFT JOIN Avg_price_per_day
ON DATE_FORMAT(event_date, '%d/%m/%Y') = Avg_price_per_day.date_month_year 
WHERE usd_price < avg_usd_price * 0.1 ;