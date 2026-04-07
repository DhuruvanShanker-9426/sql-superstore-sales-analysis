-- Create a new database for the retail project
CREATE DATABASE retail_data;

-- Select the retail database to work on
USE retail_data;

-- Create the main table to store superstore sales data
CREATE TABLE superstore(
	row_id INT PRIMARY KEY,
    order_id VARCHAR(50),
    order_date VARCHAR(20),
    ship_date VARCHAR(20),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(10),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(30),
    sub_category VARCHAR(30),
    product_name VARCHAR(255),
    sales FLOAT,
    quantity INT,
    discount FLOAT,
    profit FLOAT
);

-- Preview first 10 rows of the dataset
SELECT * 
FROM superstore
LIMIT 10;

-- View entire dataset (for full inspection)
SELECT *
FROM superstore;

-- Check for any negative sales values (data validation)
SELECT *
FROM superstore
WHERE sales<0;

-- Identify transactions with negative profit (loss analysis)
SELECT *
FROM superstore
WHERE profit<0;

-- Add new columns to store cleaned date values
ALTER TABLE superstore
ADD updated_order_date DATE,
ADD updated_ship_date DATE;

-- Convert string dates into proper DATE format
UPDATE superstore
SET updated_order_date=STR_TO_DATE(order_date,"%m/%d/%Y"), 
    updated_ship_date=STR_TO_DATE(ship_date,"%m/%d/%Y");

-- Verify the converted date columns
SELECT updated_order_date,updated_ship_date
FROM superstore
LIMIT 10;

-- Count number of products in each order
SELECT order_id,COUNT(*) as total_products
FROM superstore
GROUP BY order_id;

-- Check for NULL values in important columns
SELECT *
FROM superstore
WHERE sales IS NULL OR order_id IS NULL;

-- 1.Total number of rows in dataset
SELECT COUNT(1) AS total_rows
FROM superstore;

-- 2.Total number of unique orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM superstore;

-- 3.Total sales of the company
SELECT ROUND(SUM(sales),3) AS total_sales
FROM superstore;

-- 4. Total profit of the company
SELECT ROUND(SUM(profit),3) AS total_profit
FROM superstore;

-- 5. Average sales per order
SELECT ROUND(SUM(sales)/COUNT(DISTINCT order_id),2) AS avg_sales
FROM superstore;

-- 6.Total sales by category
SELECT category,ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY category;

-- 7. Total profit by category
SELECT category,ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY category;

-- 8. Sales by region
SELECT region,ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY region;

-- 9. Top 5 products by sales
SELECT product_name,ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 5;

-- 10.Top 5 customers by total purchase
SELECT customer_name,ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 5;

-- 11.Monthly sales trend
SELECT YEAR(updated_order_date) AS sales_year,MONTHNAME(updated_order_date) AS sales_month,ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY sales_year,MONTH(updated_order_date),sales_month
ORDER BY sales_year,MONTH(updated_order_date);

-- 12.Yearly sales trend
SELECT YEAR(updated_order_date) AS sales_year,ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY sales_year
ORDER BY sales_year;

-- 13.Which category gives highest profit?
SELECT category,ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY category
ORDER BY total_profit DESC
LIMIT 1;

-- 14.Which sub-category has highest loss?
SELECT sub_category,ROUND(SUM(profit),2) AS total_loss
FROM superstore
GROUP BY sub_category
ORDER BY total_loss ASC
LIMIT 1;

-- 15.Top 3 cities with highest sales
SELECT city,ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY city
ORDER BY total_sales DESC
LIMIT 3;

-- 16.Rank products based on total sales
SELECT product_name,
RANK() OVER(
    ORDER BY total_sales DESC
) AS sales_rank
FROM (
	SELECT product_name,SUM(sales) AS total_sales
    FROM superstore
    GROUP BY product_name
) t;

-- 17.Find top 3 products in each category
SELECT category,product_name
FROM (
	SELECT category,product_name,
	RANK() OVER(
		PARTITION BY category
		ORDER BY SUM(sales) DESC
	) AS sales_rank
	FROM superstore
	GROUP BY category,product_name
) temp
WHERE sales_rank<=3;

-- 18.Find running total of sales over time
SELECT updated_order_date,
       SUM(sales) AS daily_sales,
       SUM(SUM(sales)) OVER (ORDER BY updated_order_date) AS running_total
FROM superstore
GROUP BY updated_order_date
ORDER BY updated_order_date;

-- 19.Find percentage contribution of each category to total sales
SELECT category,
ROUND(SUM(sales)* 100 / (SELECT SUM(sales) FROM superstore),2) AS percentage_contribution
FROM superstore
GROUP BY category;

-- 20.Customers who made repeat purchases
SELECT customer_name,COUNT(DISTINCT order_id) AS total_purchases
FROM superstore
GROUP BY customer_name
HAVING total_purchases>1
ORDER BY total_purchases DESC;