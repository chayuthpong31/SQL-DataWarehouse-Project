-- ================================================
-- Change_Over_Time (Trends)

-- How many total sales, total customers and total item sold trend by Year
SELECT
DATETRUNC(YEAR, order_date) as order_year,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
ORDER BY DATETRUNC(YEAR, order_date)

-- How many total sales, total customers and total item sold trend by Month
SELECT
FORMAT(order_date,'yyyy-MMM') as order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date,'yyyy-MMM')
ORDER BY FORMAT(order_date,'yyyy-MMM')
-- ================================================

-- ================================================
-- Cumulative Analysis

-- Caltulate the total sales per month
-- and the running total of sales over time
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS moving_average_price
FROM
(
	SELECT
	DATETRUNC(MONTH,order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH,order_date)
) t
-- ================================================

-- ================================================
-- Performace Analysis

/* Analyse the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
	SELECT
	YEAR(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(f.order_date), p.product_name
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE 
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	ELSE 'Avg'
END AS avg_change,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_prev_year,
CASE 
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	ELSE 'No Change'
END AS prev_change
FROM yearly_product_sales
ORDER BY product_name, order_year
-- ================================================

-- ================================================
-- Part_to_Whole

-- Which categories contribute the most to overall sales?
WITH category_sales AS(
	SELECT
	category,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
	GROUP BY category
)
SELECT
category,
total_sales,
SUM(total_sales) OVER () AS overall_sales,
CONCAT(ROUND((total_sales / SUM(total_sales) OVER ()) * 100, 2), '%') AS sales_percent
FROM category_sales
ORDER BY sales_percent DESC
-- ================================================

-- ================================================
-- Data Segmentation

/* Segment products into cost ranges and
count how many products fall into each segment*/
WITH segment_products AS(
	SELECT
	*,
	CASE	
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost >= 100 AND cost < 500 THEN '100-500'
		WHEN cost >= 500 AND cost < 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END AS segment
	FROM gold.dim_products
)

SELECT
segment,
COUNT(*) AS total_product
FROM segment_products
GROUP BY segment

/*
	Group customers into 3 segments based on their spending begavior:
		- VIP: Customers with at least 12 months of history and spending more than 5,000.
		- Regular: Customers with at least 12 months of history but spending 5,000 or less.
		- New: Customers with a lifespan less than 12 months.
	And find the total number of customers by each group.
*/
WITH customer_segments AS (
	SELECT
	c.customer_key,
	c.first_name,
	c.last_name,
	MIN(f.order_date) AS first_order,
	MAX(f.order_date) AS latest_order,
	DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespand,
	SUM(sales_amount) AS spending,
	CASE 
		WHEN DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) >= 12 AND SUM(sales_amount) > 5000 THEN 'VIP'
		WHEN DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) >= 12 AND SUM(sales_amount) <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS segment
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
	GROUP BY c.customer_key, c.first_name, c.last_name
)

SELECT
segment,
COUNT(*) AS total_customers
FROM customer_segments
GROUP BY segment
-- ================================================

