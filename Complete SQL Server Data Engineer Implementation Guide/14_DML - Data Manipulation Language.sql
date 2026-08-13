-- DML - Data Manipulation Language

-- INSERT single row
INSERT INTO silver_customers (customer_id, first_name, last_name, email, country, status)
VALUES (51, 'Rahul', 'Kumar', 'rahul@email.com', 'India', 'Active');

-- INSERT multiple rows
INSERT INTO silver_customers
SELECT * FROM bronze_customers
WHERE customer_id > 100;

-- UPDATE records
UPDATE silver_customers
SET status = 'Inactive'
WHERE DATEDIFF(YEAR, registration_date, GETDATE()) > 5;

-- UPDATE with join
UPDATE c
SET c.status = 'Premium'
FROM silver_customers c
INNER JOIN gold_customer_metrics m ON c.customer_id = m.customer_id
WHERE m.total_spent > 5000;

-- DELETE records
DELETE FROM silver_sales
WHERE order_status = 'Cancelled'
AND transaction_date < DATEADD(YEAR, -2, GETDATE());

-- DELETE with conditions
DELETE FROM silver_customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM silver_sales
);


Use Case: Modify data in tables
Production Example: Batch update customer statuses based on activity













