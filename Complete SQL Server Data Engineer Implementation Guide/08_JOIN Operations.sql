-- INNER JOIN (only matching records)
SELECT c.customer_id, c.first_name, s.total_amount
FROM silver_customers c
INNER JOIN silver_sales s ON c.customer_id = s.customer_id
WHERE s.order_status = 'Completed';

-- LEFT JOIN (all from left table)
SELECT c.customer_id, c.first_name, COUNT(s.transaction_id) AS purchases
FROM silver_customers c
LEFT JOIN silver_sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name;

-- RIGHT JOIN (all from right table)
SELECT p.product_id, p.product_name, COUNT(s.transaction_id) AS times_sold
FROM silver_sales s
RIGHT JOIN silver_products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name;

-- FULL OUTER JOIN (all records from both tables)
SELECT *
FROM silver_customers c
FULL OUTER JOIN silver_sales s ON c.customer_id = s.customer_id;

-- Self JOIN
SELECT c1.customer_id, c1.first_name, c2.first_name
FROM silver_customers c1
INNER JOIN silver_customers c2 ON c1.country = c2.country
WHERE c1.customer_id < c2.customer_id;

-- Multiple JOINs
SELECT 
    c.first_name,
    s.transaction_date,
    p.product_name,
    s.total_amount
FROM silver_customers c
INNER JOIN silver_sales s ON c.customer_id = s.customer_id
INNER JOIN silver_products p ON s.product_id = p.product_id
WHERE s.order_status = 'Completed';


Use Case: Combine data from multiple tables
Production Example: Get customer purchase history with product details








