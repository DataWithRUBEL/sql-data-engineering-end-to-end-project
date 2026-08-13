-- Indexes & Performance

## Clustered Index
-- Clustered index (default on PRIMARY KEY)
-- Only one per table - determines physical order
CREATE CLUSTERED INDEX idx_clust_customer_id
ON silver_customers(customer_id);

-- View clustered index info
SELECT * FROM sys.indexes 
WHERE object_id = OBJECT_ID('silver_customers') 
AND type = 1;



## Nonclustered Index
-- Simple nonclustered index
CREATE NONCLUSTERED INDEX idx_customer_email
ON silver_customers(email);

-- Index on multiple columns
CREATE NONCLUSTERED INDEX idx_sales_date_status
ON silver_sales(transaction_date, order_status);

-- Query plan shows index usage
SELECT * FROM silver_customers WHERE email = 'test@email.com';

-- Remove index
DROP INDEX IF EXISTS idx_customer_email ON silver_customers;




## Composite Index
-- Multiple columns in index
CREATE NONCLUSTERED INDEX idx_composite_customer
ON silver_customers(country, status, registration_date);

-- Useful for queries filtering by all three columns
SELECT * FROM silver_customers
WHERE country = 'India'
AND status = 'Active'
AND registration_date > '2023-01-01';



## Included Columns
-- Index with included columns (covered query)
CREATE NONCLUSTERED INDEX idx_sales_with_amount
ON silver_sales(transaction_date, order_status)
INCLUDE (total_amount, customer_id, product_id);

-- Query is satisfied entirely by index (faster)
SELECT transaction_date, order_status, total_amount
FROM silver_sales
WHERE transaction_date = '2024-01-15'
AND order_status = 'Completed';




## Filtered Index
-- Index on subset of rows
CREATE NONCLUSTERED INDEX idx_active_customers
ON silver_customers(country, total_spent)
WHERE status = 'Active';

-- Very efficient for queries on active customers
SELECT customer_id, first_name
FROM silver_customers
WHERE status = 'Active' AND country = 'USA';

-- Can't use filtered index for queries on inactive
SELECT * FROM silver_customers WHERE status = 'Inactive';



## Index Statistics & Maintenance
-- View index fragmentation
SELECT 
    OBJECT_NAME(ps.object_id) AS table_name,
    i.name AS index_name,
    ps.avg_fragmentation_in_percent,
    CASE 
        WHEN ps.avg_fragmentation_in_percent < 10 THEN 'Healthy'
        WHEN ps.avg_fragmentation_in_percent < 30 THEN 'Reorganize'
        ELSE 'Rebuild'
    END AS action
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ps
INNER JOIN sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id;

-- Reorganize index (for fragmentation 10-30%)
ALTER INDEX idx_sales_date_status ON silver_sales REORGANIZE;

-- Rebuild index (for fragmentation > 30%)
ALTER INDEX idx_sales_date_status ON silver_sales REBUILD;

-- Update statistics
UPDATE STATISTICS silver_sales;


