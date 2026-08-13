-- ============================================================================
-- 11. CREATE SCALAR FUNCTIONS
-- CONCEPT #20: FUNCTIONS - Reusable code
-- ============================================================================

-- Scalar Function: Calculate Customer Lifetime Value
CREATE FUNCTION fn_calculate_clv (@customer_id INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @clv DECIMAL(12,2);
    
    SELECT @clv = ISNULL(SUM(s.total_amount), 0) * 
        (1 + 0.1 * DATEDIFF(YEAR, c.registration_date, GETDATE()))
    FROM silver_customers c
    LEFT JOIN silver_sales s ON c.customer_id = s.customer_id AND s.order_status = 'Completed'
    WHERE c.customer_id = @customer_id
    GROUP BY c.customer_id, c.registration_date;
    
    RETURN ISNULL(@clv, 0);
END;
GO

-- Scalar Function: Get Customer Segment
CREATE FUNCTION fn_get_customer_segment (@customer_id INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @segment VARCHAR(50);
    DECLARE @total_spent DECIMAL(12,2);
    
    SELECT @total_spent = ISNULL(SUM(s.total_amount), 0)
    FROM silver_sales s
    WHERE s.customer_id = @customer_id AND s.order_status = 'Completed';
    
    SET @segment = CASE 
        WHEN @total_spent > 2000 THEN 'Gold'
        WHEN @total_spent > 1000 THEN 'Silver'
        WHEN @total_spent > 500 THEN 'Bronze'
        ELSE 'Standard'
    END;
    
    RETURN @segment;
END;
GO

-- Table-Valued Function: Get Top Products by Category
CREATE FUNCTION fn_top_products_by_category (@category VARCHAR(50), @top_n INT = 5)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (@top_n)
        product_id,
        product_name,
        category,
        unit_price,
        total_revenue,
        times_purchased,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM gold_product_metrics
    WHERE category = @category
    ORDER BY total_revenue DESC
);
GO

