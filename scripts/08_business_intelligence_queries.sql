-- ============================================================================
-- 12. BUSINESS INTELLIGENCE QUERIES
-- CONCEPT #1-14: SELECT, WHERE, ORDER BY, DISTINCT, TOP, Aggregate, GROUP BY
-- CONCEPT #13: CTE, #14: Window Functions, #10: JOIN, #11: Set Operators
-- ============================================================================

-- Query 1: Top 10 Customers by Revenue (with window functions)
-- CONCEPT #14: Window Functions, #1-3: SELECT/WHERE/ORDER BY
SELECT TOP 10
    cm.customer_id,
    CONCAT(cm.first_name, ' ', cm.last_name) AS customer_name,
    cm.country,
    cm.total_spent,
    cm.customer_segment,
    -- CONCEPT #14: Window Functions - Running total
    SUM(cm.total_spent) OVER (ORDER BY cm.total_spent DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_revenue,
    -- Percentage of total
    ROUND((cm.total_spent * 100.0 / SUM(cm.total_spent) OVER ()), 2) AS percent_of_total_revenue
FROM gold_customer_metrics cm
WHERE cm.customer_status = 'Active'
ORDER BY cm.total_spent DESC;

-- Query 2: Country-wise Sales Analysis with CTE
-- CONCEPT #13: CTE (Common Table Expression)
WITH country_sales_cte AS (
    SELECT 
        c.country,
        COUNT(DISTINCT s.customer_id) AS unique_customers,
        COUNT(s.transaction_id) AS total_transactions,
        SUM(s.total_amount) AS total_sales,
        AVG(s.total_amount) AS avg_transaction_value,
        -- CONCEPT #14: Window Functions
        RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS country_rank
    FROM silver_customers c
    LEFT JOIN silver_sales s ON c.customer_id = s.customer_id AND s.order_status = 'Completed'
    WHERE c.status = 'Active'
    GROUP BY c.country
)
SELECT 
    country,
    unique_customers,
    total_transactions,
    total_sales,
    ROUND(avg_transaction_value, 2) AS avg_transaction_value,
    country_rank,
    CASE 
        WHEN country_rank <= 5 THEN 'Top Tier'
        WHEN country_rank <= 15 THEN 'High Priority'
        ELSE 'Growth Potential'
    END AS market_priority
FROM country_sales_cte
ORDER BY country_rank;

-- Query 3: Product Category Performance (CASE, GROUP BY, HAVING)
-- CONCEPT #9: CASE, #6-8: Aggregate/GROUP BY/HAVING
SELECT 
    p.category,
    COUNT(p.product_id) AS total_products,
    SUM(pm.total_units_sold) AS total_units_sold,
    SUM(pm.total_revenue) AS total_category_revenue,
    ROUND(AVG(pm.unit_price), 2) AS avg_price,
    ROUND(AVG(pm.total_revenue), 2) AS avg_product_revenue,
    -- CONCEPT #9: CASE - Stock health assessment
    SUM(CASE WHEN pm.stock_status = 'Out of Stock' THEN 1 ELSE 0 END) AS out_of_stock_products,
    SUM(CASE WHEN pm.stock_status = 'Low Stock' THEN 1 ELSE 0 END) AS low_stock_products,
    CASE 
        WHEN SUM(pm.total_revenue) > 5000 THEN 'High Performer'
        WHEN SUM(pm.total_revenue) > 2000 THEN 'Good Performer'
        ELSE 'Needs Attention'
    END AS category_performance
FROM silver_products p
LEFT JOIN gold_product_metrics pm ON p.product_id = pm.product_id
GROUP BY p.category
HAVING SUM(pm.total_units_sold) > 0
ORDER BY total_category_revenue DESC;

-- Query 4: Customer RFM Analysis (Recency, Frequency, Monetary)
-- CONCEPT #14: Window Functions with NTILE
SELECT 
    cm.customer_id,
    cm.first_name,
    cm.last_name,
    cm.email,
    cm.country,
    DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) AS days_since_purchase,
    cm.total_purchases,
    cm.total_spent,
    -- CONCEPT #14: Window Functions - Quartile ranking
    NTILE(4) OVER (ORDER BY DATEDIFF(DAY, cm.last_purchase_date, GETDATE())) AS recency_quartile,
    NTILE(4) OVER (ORDER BY cm.total_purchases) AS frequency_quartile,
    NTILE(4) OVER (ORDER BY cm.total_spent) AS monetary_quartile,
    -- RFM Score
    CASE 
        WHEN NTILE(4) OVER (ORDER BY DATEDIFF(DAY, cm.last_purchase_date, GETDATE())) = 1 AND
             NTILE(4) OVER (ORDER BY cm.total_purchases) = 4 AND
             NTILE(4) OVER (ORDER BY cm.total_spent) = 4
        THEN 'VIP Customer'
        WHEN NTILE(4) OVER (ORDER BY DATEDIFF(DAY, cm.last_purchase_date, GETDATE())) <= 2 AND
             NTILE(4) OVER (ORDER BY cm.total_purchases) >= 3 AND
             NTILE(4) OVER (ORDER BY cm.total_spent) >= 3
        THEN 'High Value'
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 90
        THEN 'Churn Risk'
        ELSE 'Standard'
    END AS customer_classification
FROM gold_customer_metrics cm
WHERE cm.customer_status = 'Active'
ORDER BY cm.total_spent DESC;

-- Query 5: Time-Series Sales Analysis
-- CONCEPT #14: Window Functions - LAG, LEAD
WITH daily_sales AS (
    SELECT 
        dss.transaction_date,
        dss.total_sales_amount,
        dss.number_of_transactions,
        dss.unique_customers,
        -- CONCEPT #14: Window Functions
        LAG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date) AS prev_day_sales,
        LEAD(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date) AS next_day_sales,
        -- Calculate growth rate
        ROUND((dss.total_sales_amount - LAG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date)) / 
            LAG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date) * 100, 2) AS day_over_day_growth
    FROM gold_daily_sales_summary dss
)
SELECT 
    transaction_date,
    total_sales_amount,
    number_of_transactions,
    unique_customers,
    prev_day_sales,
    next_day_sales,
    day_over_day_growth,
    -- 7-day moving average
    AVG(total_sales_amount) OVER (ORDER BY transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7day
FROM daily_sales
ORDER BY transaction_date;

-- Query 6: UNION Example - Combine customer and product performance
-- CONCEPT #11: SET OPERATORS - UNION
SELECT 
    'Customer' AS entity_type,
    CONCAT(first_name, ' ', last_name) AS entity_name,
    country AS location,
    total_spent AS total_value,
    customer_segment AS segment
FROM gold_customer_metrics
WHERE total_spent > 500

UNION

SELECT 
    'Product' AS entity_type,
    product_name AS entity_name,
    supplier_country AS location,
    total_revenue AS total_value,
    CASE WHEN total_revenue > 1000 THEN 'High' ELSE 'Low' END AS segment
FROM gold_product_metrics
WHERE total_revenue > 500
ORDER BY total_value DESC;

-- Query 7: Subquery Example - Customers who spent more than average
-- CONCEPT #12: SUBQUERIES
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    email,
    country,
    total_spent,
    customer_segment
FROM gold_customer_metrics
WHERE total_spent > (SELECT AVG(total_spent) FROM gold_customer_metrics)
ORDER BY total_spent DESC;

-- Query 8: Execution Plan Analysis Query
-- CONCEPT #35: Execution Plan - Complex query for optimization analysis
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    COUNT(s.transaction_id) AS purchase_count,
    SUM(s.total_amount) AS total_amount,
    MAX(s.transaction_date) AS last_purchase,
    -- CONCEPT #14: Window Functions
    DENSE_RANK() OVER (PARTITION BY c.country ORDER BY SUM(s.total_amount) DESC) AS country_rank
FROM silver_customers c
INNER JOIN silver_sales s ON c.customer_id = s.customer_id
WHERE s.order_status = 'Completed'
    AND s.transaction_date >= DATEADD(MONTH, -3, GETDATE())
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
HAVING COUNT(s.transaction_id) >= 2
ORDER BY c.country, total_amount DESC;

-- ============================================================================
-- 13. DML OPERATIONS
-- CONCEPT #16: DML - INSERT, UPDATE, DELETE
-- ============================================================================

-- Update: Set inactive customers status
-- CONCEPT #16: DML - UPDATE
UPDATE silver_customers
SET status = 'Inactive'
WHERE customer_id IN (
    SELECT customer_id 
    FROM gold_customer_metrics 
    WHERE last_purchase_date < DATEADD(MONTH, -6, GETDATE())
        AND customer_status = 'Active'
);

-- Insert: Add new bulk customers via procedure
-- EXEC sp_insert_customer 'Aarav', 'Mishra', 'aarav.mishra@email.com', 'India', '9876543213', 'Active', @message OUTPUT;

-- Delete: Remove old test data
-- CONCEPT #16: DML - DELETE
DELETE FROM silver_sales
WHERE customer_id IN (
    SELECT customer_id FROM silver_customers WHERE email LIKE '%.test@%'
);

-- ============================================================================
-- 14. ADVANCED QUERY PATTERNS
-- ============================================================================

-- Partitioning Example (logical partitioning simulation)
-- CONCEPT #37: PARTITIONING
SELECT 
    YEAR(transaction_date) AS sales_year,
    MONTH(transaction_date) AS sales_month,
    COUNT(*) AS transaction_count,
    SUM(total_amount) AS monthly_sales,
    AVG(total_amount) AS avg_transaction
FROM silver_sales
WHERE order_status = 'Completed'
GROUP BY YEAR(transaction_date), MONTH(transaction_date)
ORDER BY sales_year DESC, sales_month DESC;

-- ============================================================================
-- 15. PERFORMANCE MONITORING QUERIES
-- ============================================================================

-- Check Index Fragmentation
-- CONCEPT #30-34: Index Analysis
SELECT 
    OBJECT_NAME(ps.object_id) AS table_name,
    i.name AS index_name,
    ps.avg_fragmentation_in_percent,
    ps.page_count,
    CASE 
        WHEN ps.avg_fragmentation_in_percent < 10 THEN 'Healthy'
        WHEN ps.avg_fragmentation_in_percent < 30 THEN 'Reorganize'
        ELSE 'Rebuild'
    END AS action_needed
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ps
INNER JOIN sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
WHERE ps.index_id > 0
ORDER BY ps.avg_fragmentation_in_percent DESC;

-- Get Table Statistics
SELECT 
    OBJECT_NAME(ps.object_id) AS table_name,
    SUM(ps.row_count) AS row_count,
    SUM(ps.reserved_page_count) AS reserved_pages,
    SUM(ps.used_page_count) AS used_pages
FROM sys.dm_db_partition_stats ps
WHERE database_id = DB_ID()
GROUP BY ps.object_id
ORDER BY used_pages DESC;

-- ============================================================================
-- 16. TEST DATA FOR DEMONSTRATIONS
-- ============================================================================

-- Test: Verify data quality in silver layer
-- CONCEPT #5: TOP, #4: DISTINCT
SELECT TOP 20
    c.customer_id,
    c.email,
    c.data_quality_score,
    COUNT(DISTINCT s.transaction_id) AS transaction_count,
    SUM(s.total_amount) AS total_amount
FROM silver_customers c
LEFT JOIN silver_sales s ON c.customer_id = s.customer_id
WHERE c.data_quality_score < 1.0
GROUP BY c.customer_id, c.email, c.data_quality_score
ORDER BY c.data_quality_score ASC;

-- ============================================================================
-- 17. CLEANUP & MAINTENANCE PROCEDURES
-- ============================================================================

-- Archive old transactions (not actually deleting, just marking)
-- ALTER TABLE silver_sales ADD is_archived BIT DEFAULT 0;
-- UPDATE silver_sales SET is_archived = 1 WHERE transaction_date < DATEADD(YEAR, -2, GETDATE());

PRINT '═══════════════════════════════════════════════════════════════════════════════';
PRINT 'Data Warehouse Setup Complete!';
PRINT '═══════════════════════════════════════════════════════════════════════════════';
PRINT 'Bronze Layer: 3 raw tables with 50+ customers, 20 products, 54 transactions';
PRINT 'Silver Layer: 3 cleaned tables with data validation and quality scores';
PRINT 'Gold Layer: 3 analytics tables with aggregated business metrics';
PRINT '═══════════════════════════════════════════════════════════════════════════════';
PRINT 'Tables Created:';
PRINT '  - bronze_customers, bronze_products, bronze_sales';
PRINT '  - silver_customers, silver_products, silver_sales';
PRINT '  - gold_customer_metrics, gold_product_metrics, gold_daily_sales_summary';
PRINT '═══════════════════════════════════════════════════════════════════════════════';
GO
