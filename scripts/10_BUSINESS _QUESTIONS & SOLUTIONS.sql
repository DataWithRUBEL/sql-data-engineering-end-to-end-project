/*
═══════════════════════════════════════════════════════════════════════════════
    BUSINESS QUESTIONS & SOLUTIONS
    Real-World Data Engineer Scenarios for International E-Commerce
═══════════════════════════════════════════════════════════════════════════════
*/

USE GlobalShopDW;
GO

/*
═══════════════════════════════════════════════════════════════════════════════
QUESTION 1: CUSTOMER ANALYSIS
"Who are our top 5 spending customers and what's their value trend?"
═══════════════════════════════════════════════════════════════════════════════
*/

-- SOLUTION 1: Top Customers with Trend Analysis
-- CONCEPTS: JOIN, Window Functions, CTE, Aggregate Functions, ORDER BY
SELECT TOP 5
    cm.customer_id,
    CONCAT(cm.first_name, ' ', cm.last_name) AS customer_name,
    cm.country,
    cm.total_spent,
    cm.total_purchases,
    cm.average_order_value,
    -- Window function: Customer rank by spending
    RANK() OVER (ORDER BY cm.total_spent DESC) AS spending_rank,
    -- Growth calculation
    CASE 
        WHEN cm.average_order_value > (SELECT AVG(average_order_value) FROM gold_customer_metrics) 
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS performance_vs_avg,
    -- Calculate projected LTV using registration_year and registration_month
    ROUND(
        cm.total_spent * (
            1 + 0.05 * DATEDIFF(
                YEAR, 
                DATEFROMPARTS(cm.registration_year, cm.registration_month, 1), 
                GETDATE()
            )
        ), 
        2
    ) AS projected_ltv
FROM gold_customer_metrics cm
WHERE cm.customer_status = 'Active'
ORDER BY cm.total_spent DESC;

/*
═══════════════════════════════════════════════════════════════════════════════
QUESTION 2: GEOGRAPHICAL ANALYSIS
"Which countries are our best performers and what's the market potential?"
═══════════════════════════════════════════════════════════════════════════════
*/

-- SOLUTION 2: Country-wise Performance with Market Segmentation
-- CONCEPTS: GROUP BY, HAVING, CASE, Window Functions, CTE
WITH country_metrics AS (
    SELECT 
        c.country,
        COUNT(DISTINCT c.customer_id) AS active_customers,
        COUNT(DISTINCT s.transaction_id) AS total_transactions,
        SUM(s.total_amount) AS total_revenue,
        AVG(s.total_amount) AS avg_transaction_value,
        MAX(s.transaction_date) AS last_activity_date,
        DATEDIFF(DAY, MAX(s.transaction_date), GETDATE()) AS days_since_activity
    FROM silver_customers c
    LEFT JOIN silver_sales s ON c.customer_id = s.customer_id AND s.order_status = 'Completed'
    WHERE c.status = 'Active'
    GROUP BY c.country
)
SELECT 
    country,
    active_customers,
    total_transactions,
    total_revenue,
    ROUND(avg_transaction_value, 2) AS avg_transaction_value,
    last_activity_date,
    days_since_activity,
    -- Market segmentation
    CASE 
        WHEN total_revenue > 5000 AND active_customers > 5 THEN 'Tier 1 - Core Market'
        WHEN total_revenue > 2000 AND active_customers > 2 THEN 'Tier 2 - Growing Market'
        WHEN active_customers >= 1 THEN 'Tier 3 - Emerging Market'
        ELSE 'Tier 4 - Prospect'
    END AS market_tier,
    -- Engagement score
    CASE 
        WHEN days_since_activity <= 30 THEN 'Highly Active'
        WHEN days_since_activity <= 90 THEN 'Active'
        WHEN days_since_activity <= 180 THEN 'At Risk'
        ELSE 'Dormant'
    END AS engagement_status,
    -- Window function: Market share percentage
    ROUND((total_revenue * 100.0 / SUM(total_revenue) OVER ()), 2) AS market_share_percent
FROM country_metrics
WHERE total_revenue > 0
ORDER BY total_revenue DESC;

/*
═══════════════════════════════════════════════════════════════════════════════
QUESTION 3: PRODUCT PERFORMANCE
"Which products should we focus on and which need attention?"
═══════════════════════════════════════════════════════════════════════════════
*/

-- SOLUTION 3: Product Performance Dashboard with ROI Analysis
-- CONCEPTS: Multiple JOINs, GROUP BY, HAVING, CASE, Subqueries
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    pm.total_units_sold,
    pm.total_revenue,
    pm.times_purchased,
    pm.average_units_per_order,
    pm.stock_status,
    -- Profitability analysis
    ROUND(pm.total_revenue / NULLIF(pm.times_purchased, 0), 2) AS revenue_per_transaction,
    -- Performance classification
    CASE 
        WHEN pm.total_revenue > (SELECT AVG(total_revenue) FROM gold_product_metrics WHERE total_revenue > 0) 
             AND pm.times_purchased >= 3
        THEN 'Star Product'
        WHEN pm.total_revenue > 500 AND pm.times_purchased >= 2
        THEN 'Good Performer'
        WHEN pm.times_purchased >= 1
        THEN 'Potential'
        ELSE 'Monitor'
    END AS product_status,
    -- Stock health
    CASE 
        WHEN p.stock_quantity = 0 THEN 'URGENT: Reorder'
        WHEN p.stock_quantity < 10 THEN 'LOW: Reorder Soon'
        WHEN p.stock_quantity < 20 THEN 'MEDIUM: Plan Reorder'
        ELSE 'Healthy Stock'
    END AS stock_action,
    -- Rank within category
    RANK() OVER (PARTITION BY p.category ORDER BY pm.total_revenue DESC) AS category_rank
FROM silver_products p
LEFT JOIN gold_product_metrics pm ON p.product_id = pm.product_id
WHERE p.unit_price > 0
ORDER BY pm.total_revenue DESC;

/*
═══════════════════════════════════════════════════════════════════════════════
QUESTION 4: SALES TRENDS & SEASONALITY
"What are our sales trends and is there seasonality in purchasing patterns?"
═══════════════════════════════════════════════════════════════════════════════
*/

-- SOLUTION 4: Sales Trend Analysis with Moving Averages
-- CONCEPTS: Window Functions (Moving Avg), LAG/LEAD, Date Functions
SELECT 
    dss.transaction_date,
    dss.total_sales_amount,
    dss.number_of_transactions,
    dss.unique_customers,
    -- Previous day comparison
    LAG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date) AS prev_day_sales,
    -- Day-over-day growth
    ROUND((dss.total_sales_amount - LAG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date)) / 
        LAG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date) * 100, 2) AS day_over_day_growth,
    -- 7-day moving average
    ROUND(AVG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS avg_7day,
    -- 14-day moving average
    ROUND(AVG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date ROWS BETWEEN 13 PRECEDING AND CURRENT ROW), 2) AS avg_14day,
    -- Trend identification
    CASE 
        WHEN dss.total_sales_amount > AVG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
        THEN 'Uptrend'
        WHEN dss.total_sales_amount < AVG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
        THEN 'Downtrend'
        ELSE 'Stable'
    END AS trend_direction
FROM gold_daily_sales_summary dss
ORDER BY dss.transaction_date DESC;

/*
═══════════════════════════════════════════════════════════════════════════════
QUESTION 5: CUSTOMER SEGMENTATION
"Can we segment customers for targeted marketing campaigns?"
═══════════════════════════════════════════════════════════════════════════════
*/

-- SOLUTION 5: Advanced Customer Segmentation (RFM + Value)
-- CONCEPTS: Window Functions (NTILE, ROW_NUMBER), CASE, Multiple CTEs
WITH customer_rfm AS (
    SELECT 
        cm.customer_id,
        CONCAT(cm.first_name, ' ', cm.last_name) AS customer_name,
        cm.email,
        cm.country,
        DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) AS recency_days,
        cm.total_purchases AS frequency,
        cm.total_spent AS monetary_value,
        -- Recency score (more recent = higher score)
        5 - NTILE(5) OVER (ORDER BY DATEDIFF(DAY, cm.last_purchase_date, GETDATE())) AS recency_score,
        -- Frequency score
        NTILE(5) OVER (ORDER BY cm.total_purchases DESC) AS frequency_score,
        -- Monetary score
        NTILE(5) OVER (ORDER BY cm.total_spent DESC) AS monetary_score
    FROM gold_customer_metrics cm
    WHERE cm.customer_status = 'Active'
)
SELECT 
    customer_id,
    customer_name,
    email,
    country,
    recency_days,
    frequency,
    monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) / 3 AS rfm_score,
    -- Segment classification
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 4 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND monetary_score >= 4 THEN 'Can''t Lose Them'
        WHEN recency_score >= 3 AND monetary_score >= 3 THEN 'At Risk'
        WHEN recency_score < 2 AND frequency_score >= 3 THEN 'Need Reactivation'
        WHEN frequency_score = 1 AND monetary_value > 500 THEN 'High-Value Prospects'
        ELSE 'Developing'
    END AS customer_segment,
    -- Marketing action
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 
        THEN 'Reward & Upsell'
        WHEN recency_score >= 4 AND monetary_score <= 2 
        THEN 'Increase Frequency'
        WHEN recency_score <= 2 
        THEN 'Re-engage Campaign'
        ELSE 'Maintain Relationship'
    END AS recommended_action
FROM customer_rfm
ORDER BY rfm_score DESC;

USE GlobalShopDW;
GO

-- SOLUTION 6: Churn Risk Analysis
-- CONCEPTS: Subqueries, CASE, Window Functions, Date Calculations
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.country,
    cm.total_purchases,
    cm.total_spent,
    cm.last_purchase_date,
    DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) AS days_since_last_purchase,
    DATEDIFF(DAY, c.registration_date, GETDATE()) AS customer_lifetime_days,
    -- Average days between purchases (using c.registration_date)
    CASE 
        WHEN cm.total_purchases > 1
        THEN ROUND(DATEDIFF(DAY, c.registration_date, cm.last_purchase_date) / CAST(cm.total_purchases AS FLOAT), 0)
        ELSE NULL
    END AS avg_days_between_purchases,
    -- Churn risk score
    CASE 
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 180 THEN 'Critical'
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 120 THEN 'High'
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 90 THEN 'Medium'
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 60 THEN 'Low'
        ELSE 'None'
    END AS churn_risk_level,
    -- Estimated CLV loss if churned (using c.registration_date)
    ROUND(cm.average_order_value * 12 * (DATEDIFF(YEAR, c.registration_date, GETDATE()) + 1), 2) AS estimated_annual_value_at_risk,
    -- Recommended retention action
    CASE 
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 180 
        THEN 'Win-Back Campaign'
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 120 
        THEN 'Personal Outreach'
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 90 
        THEN 'Special Offer'
        ELSE 'Monitor'
    END AS retention_action
FROM silver_customers c
LEFT JOIN gold_customer_metrics cm ON c.customer_id = cm.customer_id
WHERE cm.total_purchases > 0 
    AND DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 60
ORDER BY 
    CASE 
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 180 THEN 1
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 120 THEN 2
        WHEN DATEDIFF(DAY, cm.last_purchase_date, GETDATE()) > 90 THEN 3
        ELSE 4
    END,
    cm.total_spent DESC;
/*
═══════════════════════════════════════════════════════════════════════════════
QUESTION 7: PAYMENT METHOD ANALYSIS
"Which payment methods are most popular and secure?"
═══════════════════════════════════════════════════════════════════════════════
*/

-- SOLUTION 7: Payment Method Performance Analysis
-- CONCEPTS: GROUP BY, HAVING, Aggregate Functions, CASE
SELECT 
    s.payment_method,
    COUNT(s.transaction_id) AS total_transactions,
    SUM(s.total_amount) AS total_processed,
    ROUND(AVG(s.total_amount), 2) AS avg_transaction_value,
    COUNT(DISTINCT s.customer_id) AS unique_customers,
    -- Success rate calculation
    ROUND(
        SUM(CASE WHEN s.order_status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(s.transaction_id), 2
    ) AS success_rate_percent,
    -- Fraud/chargeback indicator
    ROUND(
        SUM(CASE WHEN s.order_status = 'Refunded' THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(s.transaction_id), 2
    ) AS refund_rate_percent,
    -- Market share
    ROUND(
        SUM(s.total_amount) * 100.0 / SUM(SUM(s.total_amount)) OVER (), 2
    ) AS market_share_percent,
    -- Preference classification
    CASE 
        WHEN SUM(CASE WHEN s.order_status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.transaction_id) >= 95
        THEN 'Preferred'
        WHEN SUM(CASE WHEN s.order_status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.transaction_id) >= 85
        THEN 'Acceptable'
        ELSE 'Monitor'
    END AS payment_method_status
FROM silver_sales s
WHERE s.order_status IN ('Completed', 'Refunded', 'Cancelled')
GROUP BY s.payment_method
HAVING COUNT(s.transaction_id) > 0
ORDER BY total_processed DESC;

/*
═══════════════════════════════════════════════════════════════════════════════
QUESTION 8: CROSS-SELL & UP-SELL OPPORTUNITIES
"What products can we cross-sell to existing customers?"
═══════════════════════════════════════════════════════════════════════════════
*/

-- SOLUTION 8: Product Affinity Analysis
-- CONCEPTS: Complex JOIN, Subqueries, Window Functions
WITH customer_products AS (
    SELECT 
        s.customer_id,
        s.product_id,
        COUNT(s.transaction_id) AS purchase_frequency
    FROM silver_sales s
    WHERE s.order_status = 'Completed'
    GROUP BY s.customer_id, s.product_id
)
SELECT 
    p1.product_id AS primary_product_id,
    p1_detail.product_name AS primary_product_name,
    p1_detail.category AS primary_category,
    p1_detail.unit_price AS primary_price,
    p2.product_id AS recommended_product_id,
    p2_detail.product_name AS recommended_product_name,
    p2_detail.category AS recommended_category,
    p2_detail.unit_price AS recommended_price,
    COUNT(DISTINCT p1.customer_id) AS customers_bought_both,
    -- Affinity score
    ROUND(
        COUNT(DISTINCT p1.customer_id) * 100.0 / 
        (SELECT COUNT(DISTINCT customer_id) FROM customer_products WHERE product_id = p1.product_id),
        2
    ) AS affinity_percentage,
    -- Ranking
    ROW_NUMBER() OVER (PARTITION BY p1.product_id ORDER BY COUNT(DISTINCT p1.customer_id) DESC) AS recommendation_rank
FROM customer_products p1
INNER JOIN customer_products p2 ON p1.customer_id = p2.customer_id AND p1.product_id < p2.product_id
INNER JOIN silver_products p1_detail ON p1.product_id = p1_detail.product_id
INNER JOIN silver_products p2_detail ON p2.product_id = p2_detail.product_id
WHERE p1_detail.category <> p2_detail.category  -- Different categories = cross-sell
GROUP BY p1.product_id, p1_detail.product_name, p1_detail.category, p1_detail.unit_price,
         p2.product_id, p2_detail.product_name, p2_detail.category, p2_detail.unit_price
HAVING COUNT(DISTINCT p1.customer_id) >= 2
ORDER BY p1.product_id, customers_bought_both DESC;

/*
═══════════════════════════════════════════════════════════════════════════════
QUESTION 9: DATA QUALITY REPORT
"What's the quality of our data and where are the issues?"
═══════════════════════════════════════════════════════════════════════════════
*/

-- SOLUTION 9: Comprehensive Data Quality Assessment
-- CONCEPTS: Aggregate Functions, CASE, Subqueries
SELECT 
    'Customers' AS data_entity,
    COUNT(*) AS total_records,
    -- Missing data checks
    SUM(CASE WHEN email IS NULL OR email = '' THEN 1 ELSE 0 END) AS missing_email,
    SUM(CASE WHEN phone IS NULL OR phone = '' THEN 1 ELSE 0 END) AS missing_phone,
    SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS missing_country,
    -- Data quality calculations
    ROUND(
        (1 - (SUM(CASE WHEN email IS NULL OR email = '' THEN 1 ELSE 0 END) +
              SUM(CASE WHEN phone IS NULL OR phone = '' THEN 1 ELSE 0 END) +
              SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END)) /
         CAST(COUNT(*) * 3 AS FLOAT)) * 100, 2
    ) AS overall_quality_score
FROM silver_customers

UNION ALL

SELECT 
    'Products' AS data_entity,
    COUNT(*) AS total_records,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS missing_email,
    SUM(CASE WHEN stock_quantity < 0 THEN 1 ELSE 0 END) AS missing_phone,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_country,
    ROUND(
        (1 - (SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) +
              SUM(CASE WHEN stock_quantity < 0 THEN 1 ELSE 0 END) +
              SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END)) /
         CAST(COUNT(*) * 3 AS FLOAT)) * 100, 2
    ) AS overall_quality_score
FROM silver_products

UNION ALL

SELECT 
    'Sales' AS data_entity,
    COUNT(*) AS total_records,
    SUM(CASE WHEN quantity_sold <= 0 THEN 1 ELSE 0 END) AS missing_email,
    SUM(CASE WHEN total_amount <= 0 THEN 1 ELSE 0 END) AS missing_phone,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS missing_country,
    ROUND(
        (1 - (SUM(CASE WHEN quantity_sold <= 0 THEN 1 ELSE 0 END) +
              SUM(CASE WHEN total_amount <= 0 THEN 1 ELSE 0 END) +
              SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END)) /
         CAST(COUNT(*) * 3 AS FLOAT)) * 100, 2
    ) AS overall_quality_score
FROM silver_sales;

/*
═══════════════════════════════════════════════════════════════════════════════
QUESTION 10: FORECAST & PREDICTIVE ANALYSIS
"What will be our sales next month and customer demand?"
═══════════════════════════════════════════════════════════════════════════════
*/

-- SOLUTION 10: Sales Forecast (Simple Moving Average Method)
-- CONCEPTS: Window Functions, Date Functions, Subqueries
WITH sales_history AS (
    SELECT 
        dss.transaction_date,
        dss.total_sales_amount,
        AVG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_7day,
        AVG(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) AS avg_14day,
        STDEV(dss.total_sales_amount) OVER (ORDER BY dss.transaction_date ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) AS std_dev
    FROM gold_daily_sales_summary dss
),
forecast_data AS (
    SELECT 
        DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY transaction_date), MAX(transaction_date)) AS forecast_date,
        (SELECT AVG(total_sales_amount) FROM sales_history WHERE transaction_date >= DATEADD(DAY, -7, (SELECT MAX(transaction_date) FROM sales_history))) AS predicted_daily_sales,
        (SELECT AVG(total_sales_amount) FROM sales_history WHERE transaction_date >= DATEADD(DAY, -7, (SELECT MAX(transaction_date) FROM sales_history))) * 1.05 AS optimistic_forecast,
        (SELECT AVG(total_sales_amount) FROM sales_history WHERE transaction_date >= DATEADD(DAY, -7, (SELECT MAX(transaction_date) FROM sales_history))) * 0.95 AS pessimistic_forecast
    FROM sales_history
    WHERE transaction_date = (SELECT MAX(transaction_date) FROM sales_history)
    GROUP BY transaction_date
)
SELECT TOP 30
    forecast_date,
    ROUND(predicted_daily_sales, 2) AS predicted_daily_sales,
    ROUND(optimistic_forecast, 2) AS optimistic_forecast,
    ROUND(pessimistic_forecast, 2) AS pessimistic_forecast,
    'Forecast' AS forecast_type
FROM forecast_data
ORDER BY forecast_date;

/*
═══════════════════════════════════════════════════════════════════════════════
SUMMARY OF CONCEPTS COVERED IN THESE QUESTIONS:
═══════════════════════════════════════════════════════════════════════════════
1. ✓ SELECT, WHERE, ORDER BY, DISTINCT, TOP
2. ✓ Aggregate Functions (SUM, AVG, COUNT, MIN, MAX)
3. ✓ GROUP BY with HAVING clauses
4. ✓ CASE statements for business logic
5. ✓ Multiple types of JOINs
6. ✓ Subqueries for complex filtering
7. ✓ CTEs (Common Table Expressions) for readability
8. ✓ Window Functions (ROW_NUMBER, RANK, NTILE, LAG, LEAD, AVG OVER)
9. ✓ Date functions (DATEDIFF, DATEADD, DATE calculations)
10. ✓ Mathematical calculations (percentages, rankings, forecasting)
11. ✓ Data quality assessment
12. ✓ Performance analysis and optimization patterns
═══════════════════════════════════════════════════════════════════════════════
*/

-- ============================================================================
-- EXECUTION EXAMPLES (uncomment to run)
-- ============================================================================

-- Run Query 1: Top Customers
-- SELECT TOP 5 ... (see above)

-- Run Query 2: Country Analysis  
-- WITH country_metrics AS ...

-- Test the stored procedures
-- DECLARE @message NVARCHAR(255);
-- EXEC sp_insert_customer 'Aarav', 'Mishra', 'aarav.mishra@email.com', 'India', '9876543213', 'Active', @message OUTPUT;
-- PRINT @message;

-- Refresh customer metrics
-- EXEC sp_refresh_customer_metrics;

PRINT '═══════════════════════════════════════════════════════════════════════════════';
PRINT 'All Business Question Solutions Ready!';
PRINT 'Execute each query section to analyze your e-commerce data warehouse.';
PRINT '═══════════════════════════════════════════════════════════════════════════════';
GO
