-- DDL - Data Definition Language

-- CREATE TABLE
CREATE TABLE product_categories (
    category_id INT PRIMARY KEY IDENTITY(1,1),
    category_name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    created_at DATETIME DEFAULT GETDATE()
);

-- ALTER TABLE - add column
ALTER TABLE silver_customers
ADD last_login DATETIME;

-- ALTER TABLE - modify column
ALTER TABLE silver_customers
ALTER COLUMN email VARCHAR(150);

-- ALTER TABLE - drop column
ALTER TABLE silver_customers
DROP COLUMN last_login;

-- CREATE INDEX
CREATE INDEX idx_email ON silver_customers(email);

-- DROP TABLE
DROP TABLE IF EXISTS temp_staging;

-- TRUNCATE TABLE (faster than DELETE)
TRUNCATE TABLE bronze_sales;

Use Case: Define and modify database structure
Production Example: Add tracking columns to customer table











