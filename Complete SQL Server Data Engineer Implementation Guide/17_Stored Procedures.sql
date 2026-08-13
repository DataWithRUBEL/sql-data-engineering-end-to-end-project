-- CREATE PROCEDURE

-- Basic procedure
CREATE PROCEDURE sp_get_customers
AS
BEGIN
    SELECT * FROM silver_customers
    WHERE status = 'Active'
    ORDER BY first_name;
END;
EXEC sp_get_customers;

-- Procedure with parameters
CREATE PROCEDURE sp_get_customer_sales
    @customer_id INT
AS
BEGIN
    SELECT 
        s.transaction_id,
        p.product_name,
        s.quantity_sold,
        s.total_amount,
        s.transaction_date
    FROM silver_sales s
    INNER JOIN silver_products p ON s.product_id = p.product_id
    WHERE s.customer_id = @customer_id
    ORDER BY s.transaction_date DESC;
END;
EXEC sp_get_customer_sales @customer_id = 1;

-- Procedure with output parameter
CREATE PROCEDURE sp_get_customer_total_spent
    @customer_id INT,
    @total_spent DECIMAL(12,2) OUTPUT
AS
BEGIN
    SELECT @total_spent = ISNULL(SUM(total_amount), 0)
    FROM silver_sales
    WHERE customer_id = @customer_id
    AND order_status = 'Completed';
END;

DECLARE @spent DECIMAL(12,2);
EXEC sp_get_customer_total_spent @customer_id = 1, @total_spent = @spent OUTPUT;
SELECT @spent AS total_spent;

-- Procedure with table results
CREATE PROCEDURE sp_sales_by_country
    @country VARCHAR(50)
AS
BEGIN
    SELECT 
        c.country,
        COUNT(DISTINCT c.customer_id) AS unique_customers,
        SUM(s.total_amount) AS total_sales,
        AVG(s.total_amount) AS avg_transaction
    FROM silver_customers c
    LEFT JOIN silver_sales s ON c.customer_id = s.customer_id
    WHERE c.country = @country
    GROUP BY c.country;
END;
EXEC sp_sales_by_country @country = 'India';

Use Case: Encapsulate business logic, improve security
Production Example: Regular data warehouse refresh procedures







