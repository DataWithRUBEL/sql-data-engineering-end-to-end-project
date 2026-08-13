-- ============================================================================
-- PHASE 3: GOLD LAYER (Analytics Ready)
-- Aggregate data for business intelligence
-- ============================================================================

-- ============================================================================
-- 6. CREATE GOLD TABLES (Analytics Layer)
-- ============================================================================

-- CONCEPT #35: TEMPORAL TABLES (System-versioned tables for historical tracking)
CREATE TABLE gold_customer_metrics
(
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50),
    total_purchases INT,
    total_spent DECIMAL(12,2),
    average_order_value DECIMAL(10,2),
    last_purchase_date DATE,
    customer_status VARCHAR(20),
    customer_segment VARCHAR(50),
    registration_month INT,
    registration_year INT,
    created_at DATETIME DEFAULT GETDATE(),
    -- CONCEPT #36: TEMPORAL TABLES - For version history
    valid_from DATETIME GENERATED ALWAYS AS ROW START HIDDEN,
    valid_to DATETIME GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (valid_from, valid_to),
    INDEX idx_gold_segment (customer_segment),
    INDEX idx_gold_country (country)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.gold_customer_metrics_history));

CREATE TABLE gold_product_metrics (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    total_units_sold INT,
    total_revenue DECIMAL(12,2),
    average_units_per_order DECIMAL(8,2),
    stock_status VARCHAR(50),
    times_purchased INT,
    last_sale_date DATE,
    supplier_country VARCHAR(50),
    INDEX idx_gold_category (category),
    INDEX idx_gold_price (unit_price)
);

CREATE TABLE gold_daily_sales_summary (
    transaction_date DATE PRIMARY KEY,
    total_sales_amount DECIMAL(12,2),
    number_of_transactions INT,
    unique_customers INT,
    average_transaction_value DECIMAL(10,2),
    completed_orders INT,
    pending_orders INT,
    cancelled_orders INT,
    refunded_orders INT,
    top_category VARCHAR(50),
    created_at DATETIME DEFAULT GETDATE(),
    INDEX idx_gold_date (transaction_date)
);

-- ============================================================================
-- 7. POPULATE GOLD LAYER - BUSINESS INTELLIGENCE QUERIES
-- CONCEPT #10: JOIN, #6: AGGREGATE FUNCTIONS, #7: GROUP BY, #8: HAVING
-- CONCEPT #14: WINDOW FUNCTIONS, #11: SET OPERATORS
-- ============================================================================

-- CONCEPT #6, #7, #8, #10: Aggregate Functions with JOINs and GROUP BY/HAVING
-- Explicitly mapping the 14 valid target columns
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

-- CONCEPT #10: JOIN with aggregate functions
-- Explicitly mapping the 11 valid target columns
INSERT INTO gold_product_metrics (
    product_id,
    product_name,
    category,
    unit_price,
    total_units_sold,
    total_revenue,
    average_units_per_order,
    stock_status,
    times_purchased,
    last_sale_date,
    supplier_country
)
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    ISNULL(SUM(s.quantity_sold), 0) AS total_units_sold,
    ISNULL(SUM(s.total_amount), 0) AS total_revenue,
    CASE 
        WHEN COUNT(s.transaction_id) > 0 
        THEN ROUND(CAST(SUM(s.quantity_sold) AS DECIMAL(10, 2)) / COUNT(s.transaction_id), 2)
        ELSE 0
    END AS average_units_per_order,
    CASE 
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity < 20 THEN 'Low Stock'
        WHEN p.stock_quantity < 50 THEN 'Medium Stock'
        ELSE 'In Stock'
    END AS stock_status,
    COUNT(s.transaction_id) AS times_purchased,
    MAX(s.transaction_date) AS last_sale_date,
    p.supplier_country
FROM silver_products p
LEFT JOIN silver_sales s 
    ON p.product_id = s.product_id 
   AND s.order_status = 'Completed'
GROUP BY 
    p.product_id, 
    p.product_name, 
    p.category, 
    p.unit_price, 
    p.stock_quantity, 
    p.supplier_country;

-- CONCEPT #6, #7, #8, #10: Daily Sales Summary
INSERT INTO gold_daily_sales_summary
SELECT 
    s.transaction_date,
    -- CONCEPT #6: Aggregate Functions
    SUM(s.total_amount) AS total_sales_amount,
    COUNT(s.transaction_id) AS number_of_transactions,
    COUNT(DISTINCT s.customer_id) AS unique_customers,
    ROUND(AVG(s.total_amount), 2) AS average_transaction_value,
    -- CONCEPT #9: CASE - Count by status
    SUM(CASE WHEN s.order_status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN s.order_status = 'Pending' THEN 1 ELSE 0 END) AS pending_orders,
    SUM(CASE WHEN s.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN s.order_status = 'Refunded' THEN 1 ELSE 0 END) AS refunded_orders,
    -- CONCEPT #14: Window Functions - Top category
    (SELECT TOP 1 p.category
     FROM silver_sales ss
     INNER JOIN silver_products p ON ss.product_id = p.product_id
     WHERE ss.transaction_date = s.transaction_date AND ss.order_status = 'Completed'
     GROUP BY p.category
     ORDER BY SUM(ss.total_amount) DESC) AS top_category,
    GETDATE()
FROM silver_sales s
WHERE s.order_status IN ('Completed', 'Pending', 'Cancelled', 'Refunded')
GROUP BY s.transaction_date;

