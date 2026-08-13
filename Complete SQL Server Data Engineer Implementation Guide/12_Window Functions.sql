-- Window Functions
-- ROW_NUMBER - sequential numbering
SELECT 
    customer_id,
    first_name,
    total_spent,
    ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS customer_rank
FROM gold_customer_metrics;

-- RANK - ranking with ties
SELECT 
    product_id,
    product_name,
    total_revenue,
    RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS category_rank
FROM gold_product_metrics;

-- DENSE_RANK - ranking without gaps
SELECT 
    customer_id,
    total_spent,
    DENSE_RANK() OVER (ORDER BY total_spent DESC) AS dense_rank
FROM gold_customer_metrics;

-- NTILE - quartile/percentile distribution
SELECT 
    customer_id,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent) AS quartile
FROM gold_customer_metrics;

-- LAG/LEAD - access previous/next row
SELECT 
    transaction_date,
    total_sales_amount,
    LAG(total_sales_amount) OVER (ORDER BY transaction_date) AS prev_day,
    LEAD(total_sales_amount) OVER (ORDER BY transaction_date) AS next_day
FROM gold_daily_sales_summary;

-- Running aggregates
SELECT 
    transaction_date,
    total_sales_amount,
    SUM(total_sales_amount) OVER (ORDER BY transaction_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(total_sales_amount) OVER (ORDER BY transaction_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7day
FROM gold_daily_sales_summary;

-- PERCENT_RANK / CUME_DIST
SELECT 
    customer_id,
    total_spent,
    PERCENT_RANK() OVER (ORDER BY total_spent) AS percentile_rank,
    CUME_DIST() OVER (ORDER BY total_spent) AS cumulative_distribution
FROM gold_customer_metrics;

-- PARTITION BY - window within groups
SELECT 
    country,
    customer_id,
    total_spent,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_spent DESC) AS country_rank
FROM gold_customer_metrics;

Use Case: Advanced analytics without self-joins
Production Example: Rank customers within each country


