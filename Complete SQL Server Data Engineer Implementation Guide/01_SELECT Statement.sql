-- Basic column selection
SELECT customer_id, first_name, last_name, email
FROM silver_customers;

-- All columns
SELECT * FROM silver_products;

-- With aliases
SELECT c.customer_id, c.first_name AS 'Customer Name'
FROM silver_customers c;

Use Case: Retrieve specific columns from tables
Production Example: Select customer names and emails for marketing campaigns
