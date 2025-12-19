/* 
=====================================================
-- Product Report
=====================================================
Purpose:
	- This report consolidates key product metrics and behaviors

Highlights:
	1. Gathers essential fields such as product names,category, subcategory and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculated valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
=====================================================
*/
CREATE VIEW gold.report_products AS
/* --------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
-------------------------------------------------------------- */
WITH base_query AS (
	SELECT
	f.order_number,
	f.customer_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p.category,
	p.subcategory,
	p.cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
),
/* --------------------------------------------------------------
2) Product Aggragate Query: Aggreates metrics
-------------------------------------------------------------- */
agg_query AS(
	SELECT
	product_key,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity_sold,
	COUNT(DISTINCT customer_key) AS total_customers,
	MAX(order_date) AS last_sale_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) AS avg_selling_price
	FROM base_query
	GROUP BY 
		product_key,
		category,
		subcategory,
		cost
)

/* --------------------------------------------------------------
3) Final Query: Aggreates metrics
-------------------------------------------------------------- */
SELECT 
	product_key,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity_sold,
	total_customers,
	avg_selling_price,
	-- Compute average order revenue (AVR)
	CASE	
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(total_sales / total_orders , 2)
	END AS avg_order_revenue,
	-- Compute avearage monthly revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE ROUND(total_sales / lifespan, 2)
	END AS avg_monthly_revenue
FROM agg_query

SELECT * FROM gold.report_products