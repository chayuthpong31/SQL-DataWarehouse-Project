-- =======================================================
-- Database Exploration

-- Explore All Objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Explore All Columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
-- =======================================================

-- =======================================================
-- Dimensions Exploration

-- Explore All countries our customers come from.
SELECT DISTINCT country FROM gold.dim_customers;

-- Explore All Categories "The major Divisions"
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products ORDER BY 1,2,3;
-- =======================================================

-- =======================================================
-- Date Exploration

-- Find the date of the first and last order
-- How many years of sales are avaiable
SELECT 
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the youngest and the oldest customer
SELECT
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;
-- =======================================================

-- =======================================================
-- Measures Exploration

-- Find the Total Sales
SELECT SUM(sales_amount) FROM gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM gold.fact_sales;

-- Find the average selling price
SELECT AVG(price) AS avg_price FROM gold.fact_sales;

-- Find the Total number of Orders
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales;

-- Find the total number of products
SELECT COUNT(DISTINCT product_key) AS total_products FROM gold.dim_products;

-- Find the total number of customers
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' as measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' as measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders' as measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products' as measure_name, COUNT(DISTINCT product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers' as measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.dim_customers
-- =======================================================

-- =======================================================
-- Magnitude

-- Find total customers by countries
SELECT 
country, 
COUNT(customer_key) as total_customers
FROM gold.dim_customers
GROUP BY country

-- Find total customers by gender
SELECT 
gender, 
COUNT(customer_key) as total_customers
FROM gold.dim_customers
GROUP BY gender

-- Find total products by category
SELECT 
category, 
COUNT(product_key) as total_products
FROM gold.dim_products
GROUP BY category

-- What is the average costs in each category?
SELECT 
category, 
AVG(cost) as average_costs
FROM gold.dim_products
GROUP BY category

-- What is the total revenue generated for each customer?
SELECT 
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC

-- What is the distribution of sold items across countries?
SELECT
c.country,
COUNT(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC
-- =======================================================

-- =======================================================
-- Ranking Analysis

-- Which are 5 products generate the highest revenue?
SELECT TOP 5
p.product_name,
SUM(f.price) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

SELECT * FROM 
	(SELECT 
	p.product_name,
	SUM(f.price) AS total_revenue,
	RANK() OVER (ORDER BY SUM(f.price) DESC) AS rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
	GROUP BY p.product_name) t
WHERE rank_products <= 5


-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
p.product_name,
SUM(f.quantity) AS sold_quantity
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name 
ORDER BY sold_quantity

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
c.customer_key, 
c.first_name, 
c.last_name,
SUM(f.price) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC

-- Find the 3 customers with the fewest orders placed
SELECT TOP 3
c.customer_key, 
c.first_name, 
c.last_name,
COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders 
-- =======================================================