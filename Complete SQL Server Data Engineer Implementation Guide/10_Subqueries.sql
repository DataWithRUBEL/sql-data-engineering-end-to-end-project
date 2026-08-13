-- Subqueries
-- Scalar subquery (returns single value)
SELECT 
    customer_id,
    first_name,
    total_spent,
    (SELECT AVG(total_spent) FROM gold_customer_metrics) AS avg_spending
FROM gold_customer_metrics;

-- IN subquery
SELECT * FROM silver_customers
WHERE customer_id IN (
    SELECT customer_id FROM silver_sales
    WHERE total_amount > 500
);

-- Correlated subquery
SELECT 
    c.customer_id,
    c.first_name,
    (SELECT COUNT(*) FROM silver_sales s 
     WHERE s.customer_id = c.customer_id) AS purchase_count
FROM silver_customers c;

-- EXISTS subquery
SELECT c.customer_id, c.first_name
FROM silver_customers c
WHERE EXISTS (
    SELECT 1 FROM silver_sales s
    WHERE s.customer_id = c.customer_id
    AND s.order_status = 'Completed'
);

-- Nested subqueries
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS rank
    FROM gold_customer_metrics
) subquery
WHERE rank <= 10;

Use Case: Complex filtering and calculations
Production Example: Get customers with above-average spending





















