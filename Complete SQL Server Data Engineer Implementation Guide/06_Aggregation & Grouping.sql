-- Aggregate Functions

-- COUNT - number of records
COUNT(*) AS total_records
COUNT(DISTINCT customer_id) AS unique_customers

-- SUM - total values
SUM(total_amount) AS total_revenue

-- AVG - average value
AVG(unit_price) AS average_price

-- MIN/MAX - minimum and maximum
MIN(transaction_date) AS first_sale
MAX(total_spent) AS highest_customer_value

-- Example query
SELECT 
    COUNT(*) AS total_transactions,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_transaction,
    MIN(total_amount) AS min_transaction,
    MAX(total_amount) AS max_transaction
FROM silver_sales
WHERE order_status = 'Completed';

Use Case: Calculate summary statistics
Production Example: Calculate total revenue and average order value





-- GROUP BY Clause
-- Group by single column
SELECT 
    country,
    COUNT(*) AS customer_count,
    SUM(total_spent) AS country_revenue
FROM gold_customer_metrics
GROUP BY country;

-- Group by multiple columns
SELECT 
    country,
    customer_segment,
    COUNT(*) AS count
FROM gold_customer_metrics
GROUP BY country, customer_segment;

-- Group with ORDER BY
SELECT 
    category,
    COUNT(*) AS product_count,
    SUM(total_revenue) AS category_revenue
FROM gold_product_metrics
GROUP BY category
ORDER BY category_revenue DESC;

Use Case: Aggregate data by categories
Production Example: Revenue by country and customer segment





-- HAVING Clause
-- Filter aggregated results
SELECT 
    country,
    COUNT(*) AS customer_count,
    AVG(total_spent) AS avg_spent
FROM gold_customer_metrics
GROUP BY country
HAVING AVG(total_spent) > 1000;

-- HAVING with multiple conditions
HAVING COUNT(*) > 5 AND SUM(total_spent) > 10000;

-- Compare aggregates
HAVING SUM(total_amount) > (SELECT AVG(total_amount) * 10 FROM silver_sales);

Use Case: Filter groups based on aggregate conditions
Production Example: Find countries with average spending > $1000















