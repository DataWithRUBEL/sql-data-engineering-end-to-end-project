-- Constraints & Data Integrity

-- PRIMARY KEY - unique identifier
CREATE TABLE customers_temp (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- UNIQUE constraint - no duplicates
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE
);

-- FOREIGN KEY - referential integrity
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- CHECK constraint - validation
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    price DECIMAL(10,2) CHECK (price > 0),
    stock INT CHECK (stock >= 0)
);

-- DEFAULT constraint
CREATE TABLE logs (
    log_id INT PRIMARY KEY IDENTITY,
    message VARCHAR(500),
    created_at DATETIME DEFAULT GETDATE()
);

-- NOT NULL constraint
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);

-- Composite Primary Key
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);


Use Case: Enforce data quality and relationships
Production Example: Ensure products never have negative prices








