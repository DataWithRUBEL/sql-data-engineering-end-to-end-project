-- ============================================================================
-- 10. CREATE STORED PROCEDURES
-- CONCEPT #19: STORED PROCEDURES, #21: TRANSACTIONS, #22: ERROR HANDLING
-- ============================================================================

-- Stored Procedure: Insert New Customer (with error handling)
CREATE PROCEDURE sp_insert_customer
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @email VARCHAR(100),
    @country VARCHAR(50),
    @phone VARCHAR(20) = NULL,
    @status VARCHAR(20) = 'Active',
    @message NVARCHAR(255) OUTPUT
AS
BEGIN
    -- CONCEPT #21: TRANSACTIONS
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- CONCEPT #22: ERROR HANDLING
        IF @email IS NULL OR @email = ''
            THROW 50001, 'Email cannot be empty', 1;
        
        IF EXISTS (SELECT 1 FROM silver_customers WHERE email = @email)
            THROW 50002, 'Email already exists', 1;
        
        INSERT INTO silver_customers (
            customer_id,
            first_name,
            last_name,
            email,
            country,
            phone,
            registration_date,
            status,
            data_quality_score
        ) VALUES (
            NEXT VALUE FOR SEQ_CustomerId,
            TRIM(@first_name),
            TRIM(@last_name),
            LOWER(TRIM(@email)),
            @country,
            @phone,
            CONVERT(DATE, GETDATE()),
            @status,
            1.0
        );
        
        COMMIT TRANSACTION;
        SET @message = 'Customer inserted successfully';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @message = 'Error: ' + ERROR_MESSAGE();
        -- CONCEPT #22: Error handling with THROW
        THROW;
    END CATCH
END;
GO

-- Stored Procedure: Create Sales Transaction (with validation)
CREATE PROCEDURE sp_create_sales_transaction
    @customer_id INT,
    @product_id INT,
    @quantity INT,
    @payment_method VARCHAR(50),
    @message NVARCHAR(255) OUTPUT
AS
BEGIN
    DECLARE @unit_price DECIMAL(10,2);
    DECLARE @total_amount DECIMAL(10,2);
    DECLARE @transaction_date DATE;
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Validate customer
        IF NOT EXISTS (SELECT 1 FROM silver_customers WHERE customer_id = @customer_id)
            THROW 50003, 'Customer does not exist', 1;
        
        -- Get product price and validate
        SELECT @unit_price = unit_price 
        FROM silver_products 
        WHERE product_id = @product_id;
        
        IF @unit_price IS NULL
            THROW 50004, 'Product does not exist', 1;
        
        -- Validate quantity
        IF @quantity <= 0
            THROW 50005, 'Quantity must be greater than 0', 1;
        
        SET @total_amount = @unit_price * @quantity;
        SET @transaction_date = CONVERT(DATE, GETDATE());
        
        -- Insert transaction
        INSERT INTO silver_sales (
            transaction_id,
            customer_id,
            product_id,
            transaction_date,
            quantity_sold,
            unit_price,
            total_amount,
            payment_method,
            order_status
        ) VALUES (
            NEXT VALUE FOR SEQ_TransactionId,
            @customer_id,
            @product_id,
            @transaction_date,
            @quantity,
            @unit_price,
            @total_amount,
            @payment_method,
            'Completed'
        );
        
        COMMIT TRANSACTION;
        SET @message = 'Transaction created successfully. Amount: ' + CAST(@total_amount AS VARCHAR);
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @message = 'Error: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- Stored Procedure: Update Customer Metrics (Refresh Gold Layer)
-- Stored Procedure: Update Customer Metrics (Refresh Gold Layer)
CREATE OR ALTER PROCEDURE sp_refresh_customer_metrics
    @customer_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- If specific customer ID provided, update only that customer
        IF @customer_id IS NOT NULL
        BEGIN
            DELETE FROM gold_customer_metrics 
            WHERE customer_id = @customer_id;
            
            INSERT INTO gold_customer_metrics (
                customer_id,
                first_name,
                last_name,
                email,
                country,
                total_purchases,
                total_spent,
                average_order_value,
                last_purchase_date,
                customer_status,
                customer_segment,
                registration_month,
                registration_year,
                created_at
            )
            SELECT 
                c.customer_id,
                c.first_name,
                c.last_name,
                c.email,
                c.country,
                COUNT(s.transaction_id) AS total_purchases,
                ISNULL(SUM(s.total_amount), 0) AS total_spent,
                ROUND(ISNULL(AVG(s.total_amount), 0), 2) AS average_order_value,
                MAX(s.transaction_date) AS last_purchase_date,
                c.status AS customer_status,
                CASE 
                    WHEN ISNULL(SUM(s.total_amount), 0) > 2000 THEN 'Gold'
                    WHEN ISNULL(SUM(s.total_amount), 0) > 1000 THEN 'Silver'
                    WHEN ISNULL(SUM(s.total_amount), 0) > 500 THEN 'Bronze'
                    ELSE 'Standard'
                END AS customer_segment,
                MONTH(c.registration_date) AS registration_month,
                YEAR(c.registration_date) AS registration_year,
                GETDATE() AS created_at
            FROM silver_customers c
            LEFT JOIN silver_sales s 
                ON c.customer_id = s.customer_id 
               AND s.order_status = 'Completed'
            WHERE c.customer_id = @customer_id
            GROUP BY 
                c.customer_id, 
                c.first_name, 
                c.last_name, 
                c.email, 
                c.country, 
                c.status, 
                c.registration_date;
        END
        ELSE
        BEGIN
            -- Refresh all customers
            TRUNCATE TABLE gold_customer_metrics;
            
            INSERT INTO gold_customer_metrics (
                customer_id,
                first_name,
                last_name,
                email,
                country,
                total_purchases,
                total_spent,
                average_order_value,
                last_purchase_date,
                customer_status,
                customer_segment,
                registration_month,
                registration_year,
                created_at
            )
            SELECT 
                c.customer_id,
                c.first_name,
                c.last_name,
                c.email,
                c.country,
                COUNT(s.transaction_id) AS total_purchases,
                ISNULL(SUM(s.total_amount), 0) AS total_spent,
                ROUND(ISNULL(AVG(s.total_amount), 0), 2) AS average_order_value,
                MAX(s.transaction_date) AS last_purchase_date,
                c.status AS customer_status,
                CASE 
                    WHEN ISNULL(SUM(s.total_amount), 0) > 2000 THEN 'Gold'
                    WHEN ISNULL(SUM(s.total_amount), 0) > 1000 THEN 'Silver'
                    WHEN ISNULL(SUM(s.total_amount), 0) > 500 THEN 'Bronze'
                    ELSE 'Standard'
                END AS customer_segment,
                MONTH(c.registration_date) AS registration_month,
                YEAR(c.registration_date) AS registration_year,
                GETDATE() AS created_at
            FROM silver_customers c
            LEFT JOIN silver_sales s 
                ON c.customer_id = s.customer_id 
               AND s.order_status = 'Completed'
            GROUP BY 
                c.customer_id, 
                c.first_name, 
                c.last_name, 
                c.email, 
                c.country, 
                c.status, 
                c.registration_date;
        END
        
        COMMIT TRANSACTION;
        PRINT 'Customer metrics refreshed successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;

