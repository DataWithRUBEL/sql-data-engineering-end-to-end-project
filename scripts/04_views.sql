-- ============================================================================
-- 8. CREATE VIEWS
-- CONCEPT #15: VIEWS - Encapsulate complex logic
-- ============================================================================

-- Customer Lifetime Value View
CREATE VIEW vw_customer_lifetime_value AS
SELECT 
    cm.customer_id,
    cm.first_name,
    cm.last_name,
    cm.email,
    cm.country,
    cm.total_purchases,
    cm.total_spent,
    cm.average_order_value,
    cm.customer_segment,
    -- CONCEPT #14: Window Functions
    ROW_NUMBER() OVER (ORDER BY cm.total_spent DESC) AS customer_rank,
    ROUND((cm.total_spent * 100.0 / SUM(cm.total_spent) OVER ()), 2) AS revenue_contribution_percent
FROM gold_customer_metrics cm;
GO

-- Product Performance View
CREATE VIEW vw_product_performance AS
SELECT 
    pm.product_id,
    pm.product_name,
    pm.category,
    pm.unit_price,
    pm.total_units_sold,
    pm.total_revenue,
    pm.times_purchased,
    pm.stock_status,
    -- CONCEPT #14: Window Functions - Rank products by revenue
    RANK() OVER (PARTITION BY pm.category ORDER BY pm.total_revenue DESC) AS category_rank,
    PERCENT_RANK() OVER (ORDER BY pm.total_revenue) AS revenue_percentile
FROM gold_product_metrics pm;
GO

-- Daily Performance View
CREATE VIEW vw_daily_sales_performance AS
SELECT 
    dss.transaction_date,
    dss.total_sales_amount,
    dss.number_of_transactions,
    dss.unique_customers,
    dss.average_transaction_value,
    -- CONCEPT #14: Window Functions - Moving average
    AVG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7day,
    -- Growth calculation
    ROUND((dss.total_sales_amount - LAG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date)) / 
        LAG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date) * 100, 2) AS day_over_day_growth
FROM gold_daily_sales_summary dss;
GO

