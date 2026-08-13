-- Unique countries
SELECT DISTINCT country FROM silver_customers;

-- Unique combinations
SELECT DISTINCT country, status FROM silver_customers;

-- Count unique values
SELECT COUNT(DISTINCT country) AS unique_countries
FROM silver_customers;

Use Case: Identify unique values/combinations
Production Example: Find all markets we operate in
