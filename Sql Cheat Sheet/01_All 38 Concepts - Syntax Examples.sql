-- All 38 Concepts - Syntax Examples


1️⃣ SELECT
SELECT column1, column2 FROM table_name;
SELECT * FROM table_name;
SELECT DISTINCT country FROM customers;
SELECT TOP 10 * FROM sales ORDER BY amount DESC;



2️⃣ WHERE
WHERE column = value;
WHERE column > 100 AND status = 'Active';
WHERE date BETWEEN '2024-01-01' AND '2024-12-31';
WHERE email LIKE '%@gmail.com';
WHERE value IS NOT NULL;
WHERE id IN (1, 2, 3);





3️⃣ ORDER BY
ORDER BY column ASC;
ORDER BY column DESC;
ORDER BY col1 ASC, col2 DESC;
ORDER BY column NULLS FIRST;
ORDER BY 1, 2;  -- By column position







4️⃣ DISTINCT
SELECT DISTINCT country FROM customers;
SELECT DISTINCT country, status FROM customers;
SELECT COUNT(DISTINCT customer_id) FROM sales;








5️⃣ TOP
SELECT TOP 10 * FROM sales ORDER BY amount DESC;
SELECT TOP 5 PERCENT * FROM customers;
SELECT TOP 10 WITH TIES * FROM sales ORDER BY amount DESC;







6️⃣ AGGREGATE FUNCTIONS
COUNT(*) or COUNT(column)      -- Count non-NULL
SUM(amount)                    -- Total
AVG(price)                     -- Average
MIN(date)                      -- Minimum
MAX(value)                     -- Maximum
STDEV(amount)                  -- Standard deviation
VAR(amount)                    -- Variance





7️⃣ GROUP BY
SELECT country, COUNT(*) AS count
FROM customers
GROUP BY country;

SELECT country, status, SUM(amount)
FROM sales
GROUP BY country, status;






8️⃣ HAVING
SELECT country, COUNT(*) AS count
FROM customers
GROUP BY country
HAVING COUNT(*) > 5;

HAVING SUM(amount) > 1000 AND AVG(amount) > 500;






9️⃣ CASE
-- Simple CASE
CASE status
    WHEN 'Active' THEN 'Yes'
    WHEN 'Inactive' THEN 'No'
    ELSE 'Unknown'
END

-- Searched CASE
CASE
    WHEN amount > 1000 THEN 'High'
    WHEN amount > 500 THEN 'Medium'
    ELSE 'Low'
END

-- Count by condition
SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active_count







🔟 JOIN
-- INNER JOIN (matching records only)
SELECT * FROM A
INNER JOIN B ON A.id = B.id;

-- LEFT JOIN (all from left)
SELECT * FROM A
LEFT JOIN B ON A.id = B.id;

-- RIGHT JOIN (all from right)
SELECT * FROM A
RIGHT JOIN B ON A.id = B.id;

-- FULL OUTER JOIN (all records)
SELECT * FROM A
FULL OUTER JOIN B ON A.id = B.id;

-- CROSS JOIN (Cartesian product)
SELECT * FROM A
CROSS JOIN B;

-- Multiple joins
SELECT * FROM A
INNER JOIN B ON A.id = B.id
INNER JOIN C ON B.id = C.id;






1️⃣1️⃣ SET OPERATORS
-- UNION (remove duplicates)
SELECT col1 FROM table1
UNION
SELECT col1 FROM table2;

-- UNION ALL (keep duplicates)
SELECT col1 FROM table1
UNION ALL
SELECT col1 FROM table2;

-- INTERSECT (common records)
SELECT col1 FROM table1
INTERSECT
SELECT col1 FROM table2;

-- EXCEPT (in first but not second)
SELECT col1 FROM table1
EXCEPT
SELECT col1 FROM table2;






1️⃣2️⃣ SUBQUERIES
-- Scalar subquery
SELECT name, (SELECT COUNT(*) FROM orders WHERE customer_id = c.id)
FROM customers c;

-- IN subquery
SELECT * FROM customers
WHERE id IN (SELECT customer_id FROM orders);

-- EXISTS subquery
SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders WHERE customer_id = c.id);

-- Correlated subquery
SELECT * FROM sales s1
WHERE amount > (SELECT AVG(amount) FROM sales s2 WHERE s2.category = s1.category);





1️⃣3️⃣ CTE (Common Table Expression)
WITH cte_name AS (
    SELECT column1, column2
    FROM table_name
    WHERE condition
)
SELECT * FROM cte_name;

-- Multiple CTEs
WITH cte1 AS (...),
     cte2 AS (...)
SELECT * FROM cte1 JOIN cte2 ON cte1.id = cte2.id;





1️⃣4️⃣ WINDOW FUNCTIONS
-- ROW_NUMBER (sequential)
ROW_NUMBER() OVER (ORDER BY salary DESC) AS rank

-- RANK (with ties)
RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank

-- DENSE_RANK (no gaps)
DENSE_RANK() OVER (ORDER BY salary DESC) AS rank

-- NTILE (quartiles)
NTILE(4) OVER (ORDER BY salary) AS quartile

-- LAG (previous value)
LAG(amount) OVER (ORDER BY date) AS prev_amount

-- LEAD (next value)
LEAD(amount) OVER (ORDER BY date) AS next_amount

-- Running total
SUM(amount) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)

-- Moving average
AVG(amount) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)

-- PERCENT_RANK
PERCENT_RANK() OVER (ORDER BY salary) AS percentile

-- CUME_DIST
CUME_DIST() OVER (ORDER BY salary) AS cumulative_dist

-- PARTITION BY
ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC)






  
1️⃣5️⃣ VIEWS
-- Create view
CREATE VIEW view_name AS
SELECT column1, column2
FROM table_name
WHERE condition;

-- Drop view
DROP VIEW IF EXISTS view_name;

-- Use view
SELECT * FROM view_name;

-- Create indexed view
CREATE VIEW view_name WITH SCHEMABINDING AS
SELECT column1, COUNT(*) AS cnt
FROM table_name
GROUP BY column1;

CREATE UNIQUE CLUSTERED INDEX idx_name ON view_name(column1);





1️⃣6️⃣ DML (INSERT, UPDATE, DELETE)
-- INSERT single row
INSERT INTO table_name (col1, col2)
VALUES (val1, val2);

-- INSERT multiple rows
INSERT INTO table_name
SELECT * FROM source_table;

-- UPDATE
UPDATE table_name
SET col1 = val1, col2 = val2
WHERE condition;

-- UPDATE with join
UPDATE t1
SET t1.col1 = t2.col2
FROM table1 t1
INNER JOIN table2 t2 ON t1.id = t2.id;

-- DELETE
DELETE FROM table_name
WHERE condition;

-- DELETE with join
DELETE FROM t1
WHERE id IN (SELECT id FROM t2 WHERE condition);






1️⃣7️⃣ DDL (CREATE, ALTER, DROP)
-- CREATE TABLE
CREATE TABLE table_name (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);

-- ALTER TABLE - add column
ALTER TABLE table_name
ADD new_column INT;

-- ALTER TABLE - modify column
ALTER TABLE table_name
ALTER COLUMN column_name VARCHAR(200);

-- ALTER TABLE - drop column
ALTER TABLE table_name
DROP COLUMN column_name;

-- CREATE INDEX
CREATE INDEX idx_name ON table_name(column);

-- DROP INDEX
DROP INDEX idx_name ON table_name;

-- DROP TABLE
DROP TABLE IF EXISTS table_name;

-- TRUNCATE (fast delete, can't rollback in auto-commit)
TRUNCATE TABLE table_name;






1️⃣8️⃣ CONSTRAINTS
-- PRIMARY KEY
PRIMARY KEY (column)

-- UNIQUE
UNIQUE (column)

-- FOREIGN KEY
FOREIGN KEY (column) REFERENCES other_table(column)

-- CHECK
CHECK (salary > 0)

-- NOT NULL
NOT NULL

-- DEFAULT
DEFAULT GETDATE()

-- Composite Primary Key
PRIMARY KEY (col1, col2)

-- Named constraint
CONSTRAINT pk_name PRIMARY KEY (column)
CONSTRAINT fk_name FOREIGN KEY (column) REFERENCES table(column)






  
1️⃣9️⃣ STORED PROCEDURES
-- Create procedure
CREATE PROCEDURE sp_name
AS
BEGIN
    SELECT * FROM table_name;
END;

-- Procedure with parameters
CREATE PROCEDURE sp_name
    @param1 INT,
    @param2 VARCHAR(50)
AS
BEGIN
    SELECT * FROM table_name
    WHERE id = @param1 AND name = @param2;
END;

-- Output parameter
CREATE PROCEDURE sp_name
    @input INT,
    @output INT OUTPUT
AS
BEGIN
    SELECT @output = COUNT(*)
    FROM table_name
    WHERE id = @input;
END;

-- Execute procedure
EXEC sp_name @param1 = 10, @param2 = 'test';

-- Execute with output
DECLARE @result INT;
EXEC sp_name @input = 5, @output = @result OUTPUT;
SELECT @result;

-- Drop procedure
DROP PROCEDURE IF EXISTS sp_name;







2️⃣0️⃣ FUNCTIONS
-- Scalar function
CREATE FUNCTION fn_name (@param INT)
RETURNS INT
AS
BEGIN
    DECLARE @result INT;
    SELECT @result = COUNT(*)
    FROM table_name
    WHERE id = @param;
    RETURN @result;
END;

-- Table-valued function
CREATE FUNCTION fn_name (@param INT)
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM table_name WHERE id = @param
);

-- Use function
SELECT dbo.fn_name(10);

-- Drop function
DROP FUNCTION IF EXISTS fn_name;






2️⃣1️⃣ TRANSACTIONS
-- Basic transaction
BEGIN TRANSACTION;
    UPDATE table1 SET col = val WHERE id = 1;
    UPDATE table2 SET col = val WHERE id = 1;
COMMIT;

-- Rollback
BEGIN TRANSACTION;
    INSERT INTO table_name VALUES (...);
    IF @@ERROR <> 0
        ROLLBACK;
    ELSE
        COMMIT;

-- Savepoint
BEGIN TRANSACTION;
    INSERT INTO t1 VALUES (...);
    SAVE TRANSACTION sp1;
    INSERT INTO t2 VALUES (...);
    IF (some error) ROLLBACK TRANSACTION sp1;
COMMIT;

-- Isolation levels
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;







2️⃣2️⃣ ERROR HANDLING
-- Basic try-catch
BEGIN TRY
    -- SQL statements
    INSERT INTO table_name VALUES (...);
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
END CATCH;

-- Throw error
IF @value IS NULL
    THROW 50001, 'Value cannot be null', 1;

-- Rethrow in catch block
BEGIN CATCH
    -- Handle error
    THROW;  -- Rethrow original error
END CATCH;

-- Check error functions
ERROR_NUMBER()
ERROR_MESSAGE()
ERROR_SEVERITY()
ERROR_STATE()
ERROR_LINE()
ERROR_PROCEDURE()




  
2️⃣3️⃣ INDEXES
-- Create nonclustered index
CREATE INDEX idx_name ON table_name(column);

-- Unique index
CREATE UNIQUE INDEX idx_name ON table_name(column);

-- Composite index
CREATE INDEX idx_name ON table_name(col1, col2, col3);

-- With included columns
CREATE INDEX idx_name ON table_name(col1)
INCLUDE (col2, col3);

-- Filtered index
CREATE INDEX idx_name ON table_name(column)
WHERE status = 'Active';

-- Drop index
DROP INDEX idx_name ON table_name;

-- Disable index
ALTER INDEX idx_name ON table_name DISABLE;

-- Rebuild index
ALTER INDEX idx_name ON table_name REBUILD;

-- Reorganize index
ALTER INDEX idx_name ON table_name REORGANIZE;






2️⃣8️⃣ SEQUENCE
-- Create sequence
CREATE SEQUENCE seq_name
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999;

-- Use sequence
INSERT INTO table_name VALUES (NEXT VALUE FOR seq_name, ...);

-- Get current value
SELECT CURRENT_VALUE FROM sys.sequences
WHERE name = 'seq_name';

-- Drop sequence
DROP SEQUENCE seq_name;






2️⃣9️⃣-3️⃣1️⃣ INDEXES
-- Clustered index (physical order)
CREATE CLUSTERED INDEX idx_name ON table_name(column);

-- Nonclustered index
CREATE NONCLUSTERED INDEX idx_name ON table_name(column);

-- Composite index
CREATE NONCLUSTERED INDEX idx_name ON table_name(col1, col2);





3️⃣2️⃣ INCLUDED COLUMNS
CREATE NONCLUSTERED INDEX idx_name ON table_name(col1)
INCLUDE (col2, col3, col4);





3️⃣3️⃣ FILTERED INDEX
CREATE NONCLUSTERED INDEX idx_name ON table_name(column)
WHERE status = 'Active'
AND amount > 100;






3️⃣5️⃣ EXECUTION PLAN
-- Enable statistics
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT * FROM table_name WHERE condition;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- Analyze missing indexes
SELECT * FROM sys.dm_db_missing_index_details;

-- Check index fragmentation
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED');







3️⃣7️⃣ PARTITIONING (Logical)
-- Group by date
SELECT 
    YEAR(date_column) AS year,
    MONTH(date_column) AS month,
    COUNT(*) AS count
FROM table_name
GROUP BY YEAR(date_column), MONTH(date_column);

-- DATEPART
SELECT DATEPART(QUARTER, date_column) AS quarter
FROM table_name;






3️⃣8️⃣ TEMPORAL TABLES
-- Create temporal table
CREATE TABLE table_name (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    valid_from DATETIME GENERATED ALWAYS AS ROW START HIDDEN,
    valid_to DATETIME GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (valid_from, valid_to)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = table_history));

-- Query at specific time
SELECT *
FROM table_name
FOR SYSTEM_TIME AS OF '2024-01-15 10:00:00';

-- View history
SELECT * FROM table_history WHERE id = 1;







🎯 Common Patterns
Customer Analysis
SELECT 
    customer_id,
    COUNT(*) AS purchase_count,
    SUM(amount) AS total_spent,
    AVG(amount) AS avg_purchase,
    MAX(order_date) AS last_purchase
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 0
ORDER BY total_spent DESC;






Time Series
SELECT 
    DATE_TRUNC('day', order_date) AS order_day,
    SUM(amount) AS daily_sales,
    AVG(amount) OVER (ORDER BY DATE_TRUNC('day', order_date) ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7day
FROM orders
GROUP BY DATE_TRUNC('day', order_date)
ORDER BY order_day DESC;





Ranking
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY amount DESC) AS rank,
    RANK() OVER (PARTITION BY category ORDER BY amount DESC) AS category_rank
FROM sales
ORDER BY rank;







Cumulative Sum
SELECT 
    order_date,
    amount,
    SUM(amount) OVER (ORDER BY order_date) AS cumulative_total
FROM orders;






Cohort Analysis
WITH cohorts AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS cohort_month,
        customer_id
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date), customer_id
)
SELECT 
    c1.cohort_month,
    DATE_TRUNC('month', o.order_date) AS activity_month,
    COUNT(DISTINCT c1.customer_id) AS customers
FROM cohorts c1
LEFT JOIN orders o ON c1.customer_id = o.customer_id
GROUP BY c1.cohort_month, DATE_TRUNC('month', o.order_date);

