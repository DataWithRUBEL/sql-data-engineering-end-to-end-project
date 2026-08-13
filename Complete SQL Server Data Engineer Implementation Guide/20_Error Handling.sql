-- Error Handling

-- Basic TRY-CATCH
BEGIN TRY
    INSERT INTO silver_customers 
    VALUES (1, 'Duplicate', 'ID', 'test@email.com', 'India', NULL, '2024-01-01', 'Active', 1.0);
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
END CATCH;

-- TRY-CATCH with THROW
BEGIN TRY
    DECLARE @customer_id INT = NULL;
    
    IF @customer_id IS NULL
        THROW 50001, 'Customer ID cannot be null', 1;
    
    SELECT * FROM silver_customers WHERE customer_id = @customer_id;
END TRY
BEGIN CATCH
    PRINT 'Caught Error: ' + ERROR_MESSAGE();
    -- Rethrow with additional context
    THROW;
END CATCH;

-- TRY-CATCH in procedure with transaction
CREATE PROCEDURE sp_transfer_customer
    @old_id INT,
    @new_id INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        
        IF NOT EXISTS (SELECT 1 FROM silver_customers WHERE customer_id = @old_id)
            THROW 50002, 'Source customer not found', 1;
        
        IF EXISTS (SELECT 1 FROM silver_customers WHERE customer_id = @new_id)
            THROW 50003, 'Destination customer already exists', 1;
        
        UPDATE silver_sales
        SET customer_id = @new_id
        WHERE customer_id = @old_id;
        
        DELETE FROM silver_customers WHERE customer_id = @old_id;
        
        COMMIT TRANSACTION;
        PRINT 'Transfer successful';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
        THROW;
    END CATCH;
END;

Use Case: Handle errors gracefully
Production Example: Validate data before processing in procedures


