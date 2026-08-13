-- Set Operators

-- UNION (combine results, remove duplicates)
SELECT customer_id, 'Customer' AS entity_type
FROM silver_customers
UNION
SELECT product_id, 'Product'
FROM silver_products;

-- UNION ALL (combine with duplicates)
SELECT country FROM silver_customers
UNION ALL
SELECT supplier_country FROM silver_products;

-- INTERSECT (common records)
SELECT customer_id FROM gold_customer_metrics
WHERE total_spent > 1000
INTERSECT
SELECT customer_id FROM silver_sales
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING COUNT(*) > 5;

-- EXCEPT (records in first but not second)
SELECT customer_id FROM silver_customers
EXCEPT
SELECT customer_id FROM silver_sales;

Use Case: Combine, filter, or compare datasets
Production Example: Find customers who never made a purchase
