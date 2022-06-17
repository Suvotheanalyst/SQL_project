select * from shipping_dimen;
select * from market_fact;
select * from orders_dimen;
select * from prod_dimen;
select *from cust_dimen;

#  1. Join all the tables and create a new table combined_table.
CREATE TABLE combined_table AS
SELECT market.Ord_id, market.Prod_id, market.Ship_id, market.Cust_id, Sales, Discount, Order_Quantity, Profit, Shipping_Cost, 
Product_Base_Margin, cust.Customer_Name, cust.Province, cust.Region, cust.Customer_Segment, orders.Order_Date, orders.Order_Priority, 
prod.Product_Category, prod.Product_Sub_Category, orders.Order_ID, ship.Ship_Mode, ship.Ship_Date
FROM market_fact AS market
INNER JOIN cust_dimen AS cust ON market.Cust_id = cust.Cust_id
INNER JOIN orders_dimen AS orders ON orders.Ord_id = market.Ord_id
INNER JOIN prod_dimen AS prod ON prod.Prod_id = market.Prod_id
INNER JOIN shipping_dimen AS ship ON ship.Ship_id = market.Ship_id;

select * from combined_table;

# 2. Find the top 3 customers who have the maximum number of orders

SELECT Customer_Name, SUM(Order_Quantity) AS Total_Order FROM combined_table GROUP BY Customer_Name ORDER BY total_order DESC LIMIT 3;

 # 3. Create a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE combined_table
ADD COLUMN DaysTakenForDelivery INTEGER AFTER Ship_Date;
UPDATE combined_table SET DaysTakenForDelivery = DATEDIFF(Ship_Date, Order_date);

# 4. Find the customer whose order took the maximum time to get delivered.

SELECT Customer_Name, DaysTakenForDelivery from combined_table WHERE DaysTakenForDelivery = (SELECT MAX(DaysTakenForDelivery) FROM combined_table);

#5. Retrieve total sales made by each product from the data (use Windows function)

SELECT DISTINCT prod_id, sum(sales) OVER (PARTITION BY prod_id) AS total_sales FROM combined_table;

#  6. Retrieve total profit made from each product from the data (use windows function)

SELECT DISTINCT prod_id, sum(profit) OVER (PARTITION BY prod_id) AS total_profit_made FROM combined_table;

# 7. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

SELECT distinct Year(order_date), Month(order_date), count(cust_id) OVER (PARTITION BY month(order_date) order by month(order_date)) 
AS Total_Unique_Customers FROM combined_table
WHERE year(order_date)=2011 AND cust_id
IN (SELECT DISTINCT cust_id
FROM combined_table
WHERE month(order_date)=1
AND year(order_date)=2011);