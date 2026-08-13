-- CREATE FUNCTION

-- Scalar function (returns single value)
CREATE FUNCTION fn_get_customer_segment (@customer_id INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @total_spent DECIMAL(12,2);
    DECLARE @segment VARCHAR(50);
    
    SELECT @total_spent = ISNULL(SUM(total_amount), 0)
    FROM silver_sales
    WHERE customer_id = @customer_id
    AND order_status = 'Completed';
    
    SET @segment = CASE 
        WHEN @total_spent > 2000 THEN 'Gold'
        WHEN @total_spent > 1000 THEN 'Silver'
        WHEN @total_spent > 500 THEN 'Bronze'
        ELSE 'Standard'
    END;
    
    RETURN @segment;
END;

-- Using scalar function
SELECT 
    customer_id,
    first_name,
    total_spent,
    dbo.fn_get_customer_segment(customer_id) AS segment
FROM gold_customer_metrics;

-- Table-valued function
CREATE FUNCTION fn_top_products (@category VARCHAR(50), @limit INT = 10)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (@limit)
        product_id,
        product_name,
        category,
        total_revenue
    FROM gold_product_metrics
    WHERE category = @category
    ORDER BY total_revenue DESC
);

-- Using table-valued function
SELECT * FROM fn_top_products('Electronics', 5);

Use Case: Reusable calculations and transformations
Production Example: Calculate customer lifetime value on demand









