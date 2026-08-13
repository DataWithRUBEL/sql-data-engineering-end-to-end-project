-- ============================================================================
-- PHASE 2: SILVER LAYER (Cleaned Data)
-- Transform, validate, and clean the bronze data
-- ============================================================================

-- ============================================================================
-- 4. CREATE SILVER TABLES
-- CONCEPT #1-4: SELECT, WHERE, ORDER BY, DISTINCT, TOP
-- ============================================================================

CREATE TABLE silver_customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    phone VARCHAR(20),
    registration_date DATE,
    status VARCHAR(20) CHECK (status IN ('Active', 'Inactive')),
    data_quality_score DECIMAL(3,2),
    cleaned_at DATETIME DEFAULT GETDATE(),
    -- CONCEPT #37: COMPOSITE KEYS & INDEXES (defined later)
    INDEX idx_silver_email (email),
    INDEX idx_silver_country (country)
);

CREATE TABLE silver_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_price DECIMAL(10,2) CHECK (unit_price > 0),
    currency VARCHAR(3),
    stock_quantity INT CHECK (stock_quantity >= 0),
    supplier_country VARCHAR(50),
    cleaned_at DATETIME DEFAULT GETDATE(),
    INDEX idx_silver_category (category),
    INDEX idx_silver_stock (stock_quantity)
);

CREATE TABLE silver_sales (
    transaction_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    transaction_date DATE,
    quantity_sold INT CHECK (quantity_sold > 0),
    unit_price DECIMAL(10,2) CHECK (unit_price > 0),
    total_amount DECIMAL(10,2) CHECK (total_amount > 0),
    payment_method VARCHAR(50),
    order_status VARCHAR(30),
    cleaned_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (customer_id) REFERENCES silver_customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES silver_products(product_id),
    INDEX idx_silver_date (transaction_date),
    INDEX idx_silver_status (order_status)
);

-- ============================================================================
-- 5. POPULATE SILVER LAYER - DATA CLEANING & TRANSFORMATION
-- CONCEPT #6: AGGREGATE FUNCTIONS, #7: GROUP BY, #8: HAVING, #9: CASE
-- ============================================================================

-- Clean and insert customers
INSERT INTO silver_customers
SELECT 
    customer_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    -- CONCEPT #9: CASE - Handle NULL emails
    CASE 
        WHEN email IS NULL OR email = '' THEN CONCAT(TRIM(first_name), '.', TRIM(last_name), '@auto.com')
        ELSE LOWER(TRIM(email))
    END AS email,
    TRIM(country) AS country,
    -- CONCEPT #9: CASE - Standardize phone format
    CASE 
        WHEN phone IS NULL THEN 'Unknown'
        ELSE TRIM(phone)
    END AS phone,
    CONVERT(DATE, registration_date) AS registration_date,
    CASE 
        WHEN status IN ('Active', 'Inactive') THEN status
        ELSE 'Active'
    END AS status,
    -- Calculate data quality score
    ROUND(
        (1.0 - (
            (CASE WHEN email IS NULL OR email = '' THEN 1 ELSE 0 END +
             CASE WHEN phone IS NULL THEN 1 ELSE 0 END +
             CASE WHEN country IS NULL THEN 1 ELSE 0 END) / 3.0
        )) * 100, 2
    ) / 100 AS data_quality_score,
    GETDATE()
FROM bronze_customers
WHERE customer_id IS NOT NULL;

-- Clean and insert products (remove negative stock, handle NULL values)
INSERT INTO silver_products
SELECT 
    product_id,
    TRIM(product_name) AS product_name,
    UPPER(TRIM(category)) AS category,
    unit_price AS unit_price,
    currency,
    -- CONCEPT #9: CASE - Fix negative stock values
    CASE 
        WHEN stock_quantity IS NULL THEN 0
        WHEN stock_quantity < 0 THEN 0
        ELSE stock_quantity
    END AS stock_quantity,
    supplier_country,
    GETDATE()
FROM bronze_products
WHERE product_id IS NOT NULL AND unit_price > 0;

-- Clean and insert sales (remove nulls, validate data)
INSERT INTO silver_sales
SELECT 
    transaction_id,
    customer_id,
    -- CONCEPT #9: CASE - Handle NULL products (filter out)
    product_id,
    CONVERT(DATE, transaction_date) AS transaction_date,
    quantity_sold,
    unit_price,
    total_amount,
    TRIM(payment_method) AS payment_method,
    CASE 
        WHEN order_status NOT IN ('Completed', 'Pending', 'Cancelled', 'Refunded') THEN 'Unknown'
        ELSE order_status
    END AS order_status,
    GETDATE()
FROM bronze_sales
WHERE customer_id IS NOT NULL 
    AND product_id IS NOT NULL
    AND quantity_sold > 0
    AND total_amount > 0;

