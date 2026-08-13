-- CTE (Common Table Expressions)

-- Basic CTE
WITH top_customers AS (
    SELECT customer_id, first_name, total_spent
    FROM gold_customer_metrics
    WHERE total_spent > 1000
)
SELECT * FROM top_customers
WHERE total_spent > 2000;

-- Multiple CTEs
WITH sales_by_country AS (
    SELECT country, SUM(total_amount) AS country_sales
    FROM silver_customers c
    INNER JOIN silver_sales s ON c.customer_id = s.customer_id
    GROUP BY country
),
avg_sales AS (
    SELECT AVG(country_sales) AS avg_country_sales
    FROM sales_by_country
)
SELECT * FROM sales_by_country
WHERE country_sales > (SELECT avg_country_sales FROM avg_sales);

-- Recursive CTE (for hierarchies)
WITH RECURSIVE date_series AS (
    SELECT '2024-01-01' AS date_value
    UNION ALL
    SELECT DATEADD(DAY, 1, date_value)
    FROM date_series
    WHERE date_value < '2024-03-31'
)
SELECT date_value FROM date_series;

Use Case: Improve query readability and reusability
Production Example: Sales by country with comparisons to average





