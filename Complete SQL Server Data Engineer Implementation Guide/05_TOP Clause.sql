-- Top 10 records
SELECT TOP 10 * FROM gold_customer_metrics
ORDER BY total_spent DESC;

-- Top with percentage
SELECT TOP 10 PERCENT * FROM silver_sales;

-- With ties (for rank equality)
SELECT TOP 5 WITH TIES * FROM gold_customer_metrics
ORDER BY total_spent DESC;

Use Case: Limit result set size
Production Example: Get top 10 spending customers
