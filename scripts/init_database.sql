/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This scripts creates a new database name 'DataWarehouse' afterchecking if it already exists.
    If the database exists, it will drop and recreate. Additionally this script set up three schema 
    within the database: 'bronze', 'silver', 'gold'.
WARNING:
    Running this script will drop the database name 'DataWarehouse', all data in the database
    will permanently deleted.Proceed with caution and ensure you have backup before run this script.
*/

USE master;
GO
-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create Database 'DataWarehouse'
CREATE DATABASE DataWarehouse;

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;