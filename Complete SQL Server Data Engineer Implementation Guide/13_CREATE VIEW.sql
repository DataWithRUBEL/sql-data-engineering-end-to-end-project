-- CREATE VIEW
-- Simple view
CREATE VIEW vw_active_customers AS
SELECT customer_id, first_name, last_name, email, country
FROM silver_customers
WHERE status = 'Active';

-- Complex view with aggregation
CREATE VIEW vw_customer_summary AS
SELECT 
    c.customer_id,
    c.first_name,
    COUNT(s.transaction_id) AS total_purchases,
    SUM(s.total_amount) AS total_spent,
    MAX(s.transaction_date) AS last_purchase
FROM silver_customers c
LEFT JOIN silver_sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name;

-- View with window functions
CREATE VIEW vw_customer_ranking AS
SELECT 
    customer_id,
    first_name,
    total_spent,
    ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM gold_customer_metrics;

-- Using views
SELECT * FROM vw_active_customers WHERE country = 'India';

Use Case: Encapsulate complex logic, improve security
Production Example: Provide simplified customer data to non-technical users


