-- Here we are refreashing the customer info,
-- Without it we would have duplicate records everytime we refresh.

-- ===============================
-- Customer Info
-- ===============================

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
	    SET @batch_start_time = GETDATE();
		PRINT '================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================';


		PRINT '--------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '--------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Michael Le\Desktop\My_SQL_Queries_Baraa\25. SQL Data Warehouse Project\source_crm\cust_info.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',', 
			TABLOCK
		);
		SET @end_time = GETDATE();

		-- Calculate the Duration of Loading Customer Table
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------';

		-- Do the same for the other files
		-- ===============================
		-- Product Info
		-- ===============================
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info'; 
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Michael Le\Desktop\My_SQL_Queries_Baraa\25. SQL Data Warehouse Project\source_crm\prd_info.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();

		-- Calculate the Duration of Loading Product Table
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------';

		-- ===============================
		-- Sale Details
		-- ===============================
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details'; 
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Michael Le\Desktop\My_SQL_Queries_Baraa\25. SQL Data Warehouse Project\source_crm\sales_details.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		-- Calculate the Duration of Loading Sales Details
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------';


		PRINT '--------------------------------';
		PRINT 'Loading ERP Tables'
		PRINT '--------------------------------';
		-- ===============================
		-- CUST AZ12
		-- ===============================
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12'; 
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting Data Into: bronze.erp_cust_az12'; 
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Michael Le\Desktop\My_SQL_Queries_Baraa\25. SQL Data Warehouse Project\source_erp\CUST_AZ12.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		-- Calculate the Duration of Loading CUST AZ12
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------';

		-- ===============================
		-- LOC A101
		-- ===============================
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101'; 
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Data Into: bronze.erp_loc_a101'; 
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Michael Le\Desktop\My_SQL_Queries_Baraa\25. SQL Data Warehouse Project\source_erp\LOC_A101.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		-- Calculate the Duration of Loading LOC A101
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------';

		-- ===============================
		-- PX CAT G1V2
		-- ===============================
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'; 
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Michael Le\Desktop\My_SQL_Queries_Baraa\25. SQL Data Warehouse Project\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		-- Calculate the Duration of Loading PX CAT G1V2
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------';

		SET @batch_end_time = GETDATE();
		PRINT '====================================================='
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '            - Total Load Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '====================================================='

	END TRY
	BEGIN CATCH
		PRINT '================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'ERROR Message' + ERROR_MESSAGE();
		PRINT 'ERROR Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '================================================='
	END CATCH

END

-- Data Quality Checks
SELECT COUNT(*) FROM bronze.crm_cust_info;
SELECT COUNT(*) FROM bronze.crm_prd_info;
SELECT COUNT(*) FROM bronze.crm_sales_details;
SELECT COUNT(*) FROM bronze.erp_cust_az12;
SELECT COUNT(*) FROM bronze.erp_loc_a101;
SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;

-- Run this stored procedure seperately to check if it's working.
EXEC bronze.load_bronze


