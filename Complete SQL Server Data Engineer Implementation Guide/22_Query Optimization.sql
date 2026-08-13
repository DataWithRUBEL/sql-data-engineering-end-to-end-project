-- Query Optimization

## Execution Plans

-- View execution plan
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name),
    COUNT(s.transaction_id) AS purchase_count
FROM silver_customers c
LEFT JOIN silver_sales s ON c.customer_id = s.customer_id
WHERE c.status = 'Active'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(s.transaction_id) > 2;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- Check for missing indexes
SELECT 
    d.statement AS table_name,
    d.equality_columns,
    d.inequality_columns,
    d.included_columns,
    s.user_seeks,
    s.user_scans,
    s.avg_total_user_cost,
    s.avg_user_impact
FROM sys.dm_db_missing_index_details d
INNER JOIN sys.dm_db_missing_index_groups_stats s ON d.index_handle = s.index_handle
ORDER BY s.user_seeks * s.avg_user_impact DESC;



## Query Optimization Techniques
-- ❌ BAD: SELECT * and wildcard
SELECT * FROM silver_customers
WHERE email LIKE '%email%';

-- ✅ GOOD: Specific columns and exact match
SELECT customer_id, first_name, email
FROM silver_customers
WHERE email = 'specific@email.com';

-- ❌ BAD: Subquery in SELECT
SELECT 
    c.customer_id,
    (SELECT COUNT(*) FROM silver_sales s WHERE s.customer_id = c.customer_id) AS purchases
FROM silver_customers c;

-- ✅ GOOD: JOIN with GROUP BY
SELECT 
    c.customer_id,
    COUNT(s.transaction_id) AS purchases
FROM silver_customers c
LEFT JOIN silver_sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id;

-- ❌ BAD: Function on column in WHERE
SELECT * FROM silver_customers
WHERE YEAR(registration_date) = 2023;

-- ✅ GOOD: Range comparison
SELECT * FROM silver_customers
WHERE registration_date >= '2023-01-01'
AND registration_date < '2024-01-01';

-- ❌ BAD: OR conditions
SELECT * FROM silver_customers
WHERE status = 'Active' OR country = 'India';

-- ✅ GOOD: IN clause with index
SELECT * FROM silver_customers
WHERE status = 'Active' AND country IN ('India', 'USA');





## SEQUENCE
-- Create sequence
CREATE SEQUENCE SEQ_OrderId
    START WITH 1000
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999
    CYCLE;

-- Use sequence
INSERT INTO silver_sales (transaction_id, customer_id, product_id, ...)
VALUES (NEXT VALUE FOR SEQ_OrderId, 1, 1000, ...);

-- Get current value
SELECT CURRENT_VALUE FROM sys.sequences WHERE name = 'SEQ_OrderId';





## Partitioning (Logical)
-- Summary by month (logical partitioning simulation)
SELECT 
    YEAR(transaction_date) AS sales_year,
    MONTH(transaction_date) AS sales_month,
    COUNT(*) AS transaction_count,
    SUM(total_amount) AS monthly_revenue
FROM silver_sales
WHERE order_status = 'Completed'
GROUP BY YEAR(transaction_date), MONTH(transaction_date)
ORDER BY sales_year DESC, sales_month DESC;

-- Or use DATEPART
SELECT 
    DATEPART(QUARTER, transaction_date) AS quarter,
    SUM(total_amount) AS quarterly_sales
FROM silver_sales
GROUP BY DATEPART(QUARTER, transaction_date);




## Temporal Tables (System-Versioned)
-- Create temporal table
CREATE TABLE gold_customer_metrics
(
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    total_spent DECIMAL(12,2),
    valid_from DATETIME GENERATED ALWAYS AS ROW START HIDDEN,
    valid_to DATETIME GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (valid_from, valid_to)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.gold_customer_metrics_history));

-- Update automatically versions the row
UPDATE gold_customer_metrics
SET total_spent = 2500
WHERE customer_id = 1;

-- Query at specific point in time
SELECT *
FROM gold_customer_metrics
FOR SYSTEM_TIME AS OF '2024-01-15 10:00:00'
WHERE customer_id = 1;

-- View all history
SELECT * FROM gold_customer_metrics_history
WHERE customer_id = 1
ORDER BY valid_from;


