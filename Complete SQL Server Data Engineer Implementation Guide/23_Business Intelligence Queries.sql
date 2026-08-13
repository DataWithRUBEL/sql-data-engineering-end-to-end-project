-- Business Intelligence Queries

## Query 1: Customer Analysis
SELECT TOP 10
    cm.customer_id,
    CONCAT(cm.first_name, ' ', cm.last_name) AS customer_name,
    cm.total_spent,
    cm.total_purchases,
    cm.customer_segment
FROM gold_customer_metrics cm
WHERE cm.customer_status = 'Active'
ORDER BY cm.total_spent DESC;



## Query 2: Sales Trend
SELECT 
    transaction_date,
    total_sales_amount,
    AVG(total_sales_amount) OVER (ORDER BY transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_7day
FROM gold_daily_sales_summary
ORDER BY transaction_date DESC;



## Query 3: Product Performance
SELECT 
    product_name,
    category,
    total_units_sold,
    total_revenue,
    RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS category_rank
FROM gold_product_metrics
ORDER BY category, total_revenue DESC;
