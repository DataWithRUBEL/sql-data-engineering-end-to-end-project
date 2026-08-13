-- CASE Statement


-- Simple CASE
CASE order_status
    WHEN 'Completed' THEN 'Success'
    WHEN 'Pending' THEN 'In Progress'
    WHEN 'Refunded' THEN 'Returned'
    ELSE 'Unknown'
END AS status_label

-- Searched CASE (more flexible)
CASE
    WHEN total_spent > 2000 THEN 'Gold'
    WHEN total_spent > 1000 THEN 'Silver'
    WHEN total_spent > 500 THEN 'Bronze'
    ELSE 'Standard'
END AS customer_tier

-- CASE with aggregates
SELECT 
    country,
    SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active_customers,
    SUM(CASE WHEN status = 'Inactive' THEN 1 ELSE 0 END) AS inactive_customers
FROM silver_customers
GROUP BY country;

-- Nested CASE
CASE
    WHEN total_spent > 2000 THEN
        CASE WHEN total_purchases > 10 THEN 'Loyal Gold' ELSE 'Recent Gold' END
    ELSE 'Standard'
END

Use Case: Implement business logic and classifications
Production Example: Segment customers by spending and purchase frequency






