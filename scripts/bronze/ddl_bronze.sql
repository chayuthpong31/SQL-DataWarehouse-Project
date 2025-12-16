/*
======================================
Create tables in bronze layers
======================================
This script create 6 tables in bronze layers.
CRM source:'crm_cust_info', 'crm_prd_info', 'sales_details'
ERP source: 'erp_cust_az12', 'erp_loc_a101', 'erp_px_cat_g1v2'
*/

-- Create customer information table from CRM source
IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status CHAR,
	cst_gender CHAR,
	cst_create_data DATE
);

-- Create product information table from CRM source
IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info
CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost FLOAT,
	prd_line CHAR,
	prd_start_dt DATE,
	prd_end_dt DATE		
);	

-- Create sale detail table from CRM source
IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num NVARCHAR(7),
	sls_prd_key NVARCHAR(10),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales FLOAT,
	sls_quantity INT,
	sls_price FLOAT
);

-- Create customer information table from ERP source
IF OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12
CREATE TABLE bronze.erp_cust_az12(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(10)
);

-- Create customer location table from ERP source
IF OBJECT_ID ('bronze.erp_loc_a101','U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101
CREATE TABLE bronze.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);

-- Create Product information table from ERP source
IF OBJECT_ID ('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2
CREATE TABLE bronze.erp_px_cat_g1v2(
	id NVARCHAR(10),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintaenance NVARCHAR(5)
);