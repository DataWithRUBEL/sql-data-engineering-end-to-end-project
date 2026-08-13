/*
═══════════════════════════════════════════════════════════════════════════════
    END-TO-END DATA ENGINEER PROJECT - MEDALLION ARCHITECTURE
    SQL Server 2019+ | E-COMMERCE GLOBAL DATA WAREHOUSE
═══════════════════════════════════════════════════════════════════════════════

PROJECT: International E-Commerce Data Warehouse
COMPANY: GlobalShop International Ltd
SCOPE: Multi-country sales, customer, product, and transaction data
ARCHITECTURE: Bronze (Raw) → Silver (Cleaned) → Gold (Analytics)

COVERS: 38 Advanced SQL Concepts
═══════════════════════════════════════════════════════════════════════════════
*/

-- ============================================================================
-- 1. DATABASE CREATION & INITIAL SETUP
-- ============================================================================

-- Drop existing database if exists (for clean run)
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'GlobalShopDW')
BEGIN
    ALTER DATABASE GlobalShopDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GlobalShopDW;
END
GO

-- Create main data warehouse database
CREATE DATABASE GlobalShopDW
    ON PRIMARY (
        NAME = N'GlobalShopDW_data',
        FILENAME = N'C:\SQL_Data\GlobalShopDW.mdf',
        SIZE = 100MB,
        MAXSIZE = UNLIMITED,
        FILEGROWTH = 50MB
    )
    LOG ON (
        NAME = N'GlobalShopDW_log',
        FILENAME = N'C:\SQL_Log\GlobalShopDW_log.ldf',
        SIZE = 50MB,
        MAXSIZE = UNLIMITED,
        FILEGROWTH = 50MB
    );
GO

USE GlobalShopDW;
GO

-- ============================================================================
-- 2. CREATE SEQUENCES (Auto-increment alternative)
-- CONCEPT #28: SEQUENCE
-- ============================================================================

CREATE SEQUENCE SEQ_CustomerId
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999
    CYCLE;
GO

CREATE SEQUENCE SEQ_ProductId
    START WITH 1000
    INCREMENT BY 1;
GO

CREATE SEQUENCE SEQ_TransactionId
    START WITH 10001
    INCREMENT BY 1;
GO

-- ============================================================================
-- PHASE 1: BRONZE LAYER (Raw Data)
-- Raw data from multiple sources - unclean, as-is data
-- ============================================================================

-- ============================================================================
-- 2. CREATE BRONZE TABLES (Raw Data Layer)
-- CONCEPT #17: DDL - CREATE TABLE
-- CONCEPT #18: CONSTRAINTS - Primary Key, Foreign Key, Check, Default
-- ============================================================================

-- Bronze: Raw Customer Data (with dirty data)
CREATE TABLE bronze_customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50),
    phone VARCHAR(20),
    registration_date DATETIME,
    status VARCHAR(20) DEFAULT 'Active',
    created_at DATETIME DEFAULT GETDATE()
);

-- Bronze: Raw Product Data
CREATE TABLE bronze_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    currency VARCHAR(3),
    stock_quantity INT,
    supplier_country VARCHAR(50),
    created_at DATETIME DEFAULT GETDATE()
);

-- Bronze: Raw Sales Transactions (messy data from multiple sources)
CREATE TABLE bronze_sales (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    transaction_date DATETIME,
    quantity_sold INT,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    order_status VARCHAR(30),
    created_at DATETIME DEFAULT GETDATE()
);

-- ============================================================================
-- 3. INSERT RAW DATA (50+ rows with DIRTY DATA)
-- Represents real-world messy data
-- ============================================================================

-- Insert Customer Data (with issues: NULL emails, wrong dates, duplicate emails)
INSERT INTO bronze_customers VALUES
(1, 'Rajesh', 'Kumar', 'rajesh@email.com', 'India', '9876543210', '2023-01-15', 'Active', GETDATE()),
(2, 'Ahmed', 'Hassan', NULL, 'Egypt', '201012345678', '2023-02-20', 'Active', GETDATE()),
(3, 'Maria', 'Garcia', 'maria.garcia@email.com', 'Spain', '+34912345678', '2023-03-10', 'Inactive', GETDATE()),
(4, 'John', 'Smith', 'john@email.com', 'USA', '2025551234', '2023-04-05', 'Active', GETDATE()),
(5, 'Yuki', 'Tanaka', 'yuki@email.com', 'Japan', '09012345678', '2023-01-20', 'Active', GETDATE()),
(6, 'Pierre', 'Dupont', 'pierre@email.com', 'France', '+33123456789', '2023-05-15', 'Active', GETDATE()),
(7, 'Li', 'Wei', NULL, 'China', '13812345678', '2023-06-20', 'Active', GETDATE()),
(8, 'Anna', 'Mueller', 'anna@email.com', 'Germany', '+491234567890', '2023-02-10', 'Active', GETDATE()),
(9, 'Carlos', 'Rodriguez', 'carlos@email.com', 'Mexico', '+525541234567', '2023-07-18', 'Inactive', GETDATE()),
(10, 'Sophie', 'Martin', 'sophie@email.com', 'France', '+33456789012', '2023-03-25', 'Active', GETDATE()),
(11, 'Rajesh', 'Patel', 'rajesh@email.com', 'India', '9876543211', '2023-08-30', 'Active', GETDATE()), -- Duplicate email
(12, 'Deepak', 'Sharma', 'deepak.sharma@email.com', 'India', '9123456789', '2023-04-12', 'Active', GETDATE()),
(13, 'Amina', 'Ali', 'amina@email.com', 'Kenya', '+254712345678', '2023-05-22', 'Active', GETDATE()),
(14, 'Roberto', 'Silva', 'roberto@email.com', 'Brazil', '+5511987654321', '2023-06-11', 'Active', GETDATE()),
(15, 'Elena', 'Russo', 'elena@email.com', 'Italy', '+39123456789', '2023-02-08', 'Active', GETDATE()),
(16, 'Hassan', 'Ahmed', 'hassan@email.com', 'UAE', '+971501234567', '2023-07-03', 'Active', GETDATE()),
(17, 'Priya', 'Singh', 'priya@email.com', 'India', '9988776655', '2023-08-19', 'Inactive', GETDATE()),
(18, 'Lucas', 'Oliveira', NULL, 'Portugal', '+351912345678', '2023-03-15', 'Active', GETDATE()),
(19, 'Noor', 'Khan', 'noor@email.com', 'Pakistan', '03001234567', '2023-09-05', 'Active', GETDATE()),
(20, 'Fatima', 'Hassan', 'fatima@email.com', 'Morocco', '+212612345678', '2023-04-28', 'Active', GETDATE()),
(21, 'Wong', 'David', 'david.wong@email.com', 'Singapore', '+6581234567', '2023-10-02', 'Active', GETDATE()),
(22, 'Aisha', 'Mohammed', NULL, 'Nigeria', '+234802345678', '2023-05-14', 'Active', GETDATE()),
(23, 'Santiago', 'Flores', 'santiago@email.com', 'Argentina', '+542612345678', '2023-06-30', 'Active', GETDATE()),
(24, 'Nguyen', 'Tuan', 'tuan@email.com', 'Vietnam', '+84912345678', '2023-07-21', 'Inactive', GETDATE()),
(25, 'Isabelle', 'Leclerc', 'isabelle@email.com', 'Canada', '+14165551234', '2023-08-07', 'Active', GETDATE()),
(26, 'Vikram', 'Das', 'vikram@email.com', 'India', '9876543212', '2023-09-18', 'Active', GETDATE()),
(27, 'Mohammad', 'Ibrahim', 'mohammad@email.com', 'Saudi Arabia', '+966501234567', '2023-02-26', 'Active', GETDATE()),
(28, 'Amanda', 'Stevens', NULL, 'Australia', '+61412345678', '2023-10-10', 'Active', GETDATE()),
(29, 'Felix', 'Mueller', 'felix@email.com', 'Austria', '+43123456789', '2023-03-19', 'Active', GETDATE()),
(30, 'Suki', 'Yamamoto', 'suki@email.com', 'Japan', '09087654321', '2023-04-02', 'Inactive', GETDATE()),
(31, 'Andres', 'Lopez', 'andres@email.com', 'Colombia', '+57312345678', '2023-05-09', 'Active', GETDATE()),
(32, 'Zainab', 'Omar', 'zainab@email.com', 'Somalia', '+252616234567', '2023-11-01', 'Active', GETDATE()),
(33, 'Ivan', 'Petrov', 'ivan@email.com', 'Russia', '+79012345678', '2023-06-15', 'Active', GETDATE()),
(34, 'Natasha', 'Sokolov', NULL, 'Ukraine', '+380501234567', '2023-07-24', 'Active', GETDATE()),
(35, 'Javier', 'Santos', 'javier@email.com', 'Chile', '+56912345678', '2023-08-12', 'Active', GETDATE()),
(36, 'Mei', 'Chen', 'mei@email.com', 'Taiwan', '+886912345678', '2023-02-20', 'Inactive', GETDATE()),
(37, 'Olusola', 'Adeyemi', 'olusola@email.com', 'Nigeria', '+234901234567', '2023-09-27', 'Active', GETDATE()),
(38, 'Fatou', 'Diallo', 'fatou@email.com', 'Senegal', '+221701234567', '2023-10-14', 'Active', GETDATE()),
(39, 'Thanh', 'Le', NULL, 'Vietnam', '+84901234567', '2023-03-08', 'Active', GETDATE()),
(40, 'Kwame', 'Asante', 'kwame@email.com', 'Ghana', '+233501234567', '2023-11-05', 'Active', GETDATE()),
(41, 'Patricia', 'Chang', 'patricia@email.com', 'Taiwan', '+886212345678', '2023-04-21', 'Active', GETDATE()),
(42, 'Rashid', 'Al-Mansouri', 'rashid@email.com', 'UAE', '+971601234567', '2023-05-30', 'Inactive', GETDATE()),
(43, 'Lucia', 'Fernandez', 'lucia@email.com', 'Peru', '+51912345678', '2023-06-08', 'Active', GETDATE()),
(44, 'Shen', 'Liu', 'shen@email.com', 'China', '13912345678', '2023-07-17', 'Active', GETDATE()),
(45, 'Miriam', 'Cohen', 'miriam@email.com', 'Israel', '+972512345678', '2023-08-24', 'Active', GETDATE()),
(46, 'Paulo', 'Costa', NULL, 'Brazil', '+5521987654321', '2023-09-11', 'Active', GETDATE()),
(47, 'Greta', 'Svensson', 'greta@email.com', 'Sweden', '+46812345678', '2023-10-19', 'Active', GETDATE()),
(48, 'Amara', 'Okonkwo', 'amara@email.com', 'Nigeria', '+234702345678', '2023-11-08', 'Inactive', GETDATE()),
(49, 'Henrik', 'Andersen', 'henrik@email.com', 'Denmark', '+4540123456', '2023-02-14', 'Active', GETDATE()),
(50, 'Yasmin', 'Ahmed', 'yasmin@email.com', 'Egypt', '+201001234567', '2023-03-22', 'Active', GETDATE());

-- Insert Product Data (with pricing issues, missing stock info)
INSERT INTO bronze_products VALUES
(1000, 'Laptop Pro 15', 'Electronics', 1299.99, 'USD', 45, 'China', GETDATE()),
(1001, 'Wireless Mouse', 'Electronics', 29.99, 'USD', NULL, 'Vietnam', GETDATE()), -- NULL stock
(1002, 'USB-C Cable', 'Accessories', 9.99, 'USD', 500, 'China', GETDATE()),
(1003, 'Monitor 4K', 'Electronics', 599.99, 'USD', 20, 'South Korea', GETDATE()),
(1004, 'Keyboard Mechanical', 'Accessories', 149.99, 'USD', 80, 'China', GETDATE()),
(1005, 'Headphones Wireless', 'Electronics', 199.99, 'USD', 150, 'Japan', GETDATE()),
(1006, 'USB Hub', 'Accessories', 39.99, 'USD', -5, 'China', GETDATE()), -- Negative stock
(1007, 'Phone Stand', 'Accessories', 14.99, 'USD', 300, 'India', GETDATE()),
(1008, 'Screen Protector', 'Accessories', 4.99, 'USD', 1000, 'China', GETDATE()),
(1009, 'Power Bank', 'Electronics', 49.99, 'USD', 200, 'China', GETDATE()),
(1010, 'Tablet Case', 'Accessories', 19.99, 'USD', 250, 'Vietnam', GETDATE()),
(1011, 'Webcam HD', 'Electronics', 79.99, 'USD', 60, 'China', GETDATE()),
(1012, 'Mouse Pad', 'Accessories', 12.99, 'USD', 400, 'Vietnam', GETDATE()),
(1013, 'Speaker Bluetooth', 'Electronics', 89.99, 'USD', NULL, 'Japan', GETDATE()),
(1014, 'Cable Organizer', 'Accessories', 8.99, 'USD', 600, 'China', GETDATE()),
(1015, 'Monitor Stand', 'Accessories', 34.99, 'USD', 90, 'Vietnam', GETDATE()),
(1016, 'Laptop Stand', 'Accessories', 44.99, 'USD', 120, 'India', GETDATE()),
(1017, 'External SSD 1TB', 'Electronics', 129.99, 'USD', 75, 'South Korea', GETDATE()),
(1018, 'HDMI Cable', 'Accessories', 6.99, 'USD', 800, 'China', GETDATE()),
(1019, 'USB Adapter', 'Accessories', 11.99, 'USD', 500, 'China', GETDATE());

-- Insert Sales Transaction Data (50+ rows with issues)
INSERT INTO bronze_sales VALUES
-- January 2024 sales
(10001, 1, 1000, '2024-01-05 10:30:00', 1, 1299.99, 1299.99, 'Credit Card', 'Completed', GETDATE()),
(10002, 2, 1001, '2024-01-06 14:15:00', 2, 29.99, 59.98, 'PayPal', 'Completed', GETDATE()),
(10003, 3, 1003, '2024-01-07 09:45:00', 1, 599.99, 599.99, 'Debit Card', 'Completed', GETDATE()),
(10004, 4, 1005, '2024-01-08 16:20:00', 1, 199.99, 199.99, 'Apple Pay', 'Completed', GETDATE()),
(10005, 5, 1008, '2024-01-09 11:00:00', 5, 4.99, 24.95, 'Credit Card', 'Completed', GETDATE()),
(10006, 6, 1002, '2024-01-10 13:30:00', 3, 9.99, 29.97, 'PayPal', 'Pending', GETDATE()),
(10007, 7, NULL, '2024-01-11 10:15:00', 2, 49.99, 99.98, 'Credit Card', 'Cancelled', GETDATE()), -- NULL product
(10008, 8, 1011, '2024-01-12 15:45:00', 1, 79.99, 79.99, 'Google Pay', 'Completed', GETDATE()),
(10009, 9, 1004, '2024-01-13 12:20:00', 1, 149.99, 149.99, 'Credit Card', 'Completed', GETDATE()),
(10010, 10, 1017, '2024-01-14 09:30:00', 1, 129.99, 129.99, 'Debit Card', 'Completed', GETDATE()),
(10011, 11, 1000, '2024-01-15 14:00:00', 1, 1299.99, 1299.99, 'Credit Card', 'Completed', GETDATE()),
(10012, 12, 1006, '2024-01-16 10:45:00', 1, 39.99, 39.99, 'PayPal', 'Completed', GETDATE()),
(10013, 13, 1009, '2024-01-17 16:15:00', 2, 49.99, 99.98, 'Credit Card', 'Pending', GETDATE()),
(10014, 14, 1012, '2024-01-18 11:30:00', 3, 12.99, 38.97, 'Google Pay', 'Completed', GETDATE()),
(10015, 15, 1003, '2024-01-19 13:45:00', 1, 599.99, 599.99, 'Credit Card', 'Completed', GETDATE()),
-- February 2024 sales
(10016, 16, 1007, '2024-02-01 10:00:00', 4, 14.99, 59.96, 'PayPal', 'Completed', GETDATE()),
(10017, 17, 1005, '2024-02-02 15:30:00', 1, 199.99, 199.99, 'Credit Card', 'Refunded', GETDATE()),
(10018, 18, 1018, '2024-02-03 12:15:00', 2, 6.99, 13.98, 'Debit Card', 'Completed', GETDATE()),
(10019, 19, 1011, '2024-02-04 09:45:00', 1, 79.99, 79.99, 'Google Pay', 'Completed', GETDATE()),
(10020, 20, 1002, '2024-02-05 14:20:00', 5, 9.99, 49.95, 'Credit Card', 'Completed', GETDATE()),
(10021, 21, 1001, '2024-02-06 11:00:00', 3, 29.99, 89.97, 'Apple Pay', 'Pending', GETDATE()),
(10022, 22, 1004, '2024-02-07 16:30:00', 1, 149.99, 149.99, 'Credit Card', 'Completed', GETDATE()),
(10023, 23, 1017, '2024-02-08 10:15:00', 2, 129.99, 259.98, 'PayPal', 'Completed', GETDATE()),
(10024, 24, 1008, '2024-02-09 13:45:00', 10, 4.99, 49.90, 'Credit Card', 'Completed', GETDATE()),
(10025, 25, 1009, '2024-02-10 15:00:00', 1, 49.99, 49.99, 'Google Pay', 'Completed', GETDATE()),
(10026, 26, 1003, '2024-02-11 09:30:00', 1, 599.99, 599.99, 'Credit Card', 'Completed', GETDATE()),
(10027, 27, 1019, '2024-02-12 14:15:00', 10, 11.99, 119.90, 'Debit Card', 'Completed', GETDATE()),
(10028, 28, 1000, '2024-02-13 11:45:00', 1, 1299.99, 1299.99, 'PayPal', 'Completed', GETDATE()),
(10029, 29, 1010, '2024-02-14 16:20:00', 2, 19.99, 39.98, 'Credit Card', 'Pending', GETDATE()),
(10030, 30, 1011, '2024-02-15 10:00:00', 1, 79.99, 79.99, 'Apple Pay', 'Completed', GETDATE()),
-- March 2024 sales
(10031, 31, 1005, '2024-03-01 12:30:00', 1, 199.99, 199.99, 'Credit Card', 'Completed', GETDATE()),
(10032, 32, 1002, '2024-03-02 14:00:00', 2, 9.99, 19.98, 'Google Pay', 'Completed', GETDATE()),
(10033, 33, 1004, '2024-03-03 09:15:00', 1, 149.99, 149.99, 'PayPal', 'Completed', GETDATE()),
(10034, 34, 1008, '2024-03-04 15:45:00', 8, 4.99, 39.92, 'Credit Card', 'Completed', GETDATE()),
(10035, 35, 1017, '2024-03-05 10:30:00', 1, 129.99, 129.99, 'Debit Card', 'Completed', GETDATE()),
(10036, 36, 1003, '2024-03-06 13:15:00', 1, 599.99, 599.99, 'Credit Card', 'Refunded', GETDATE()),
(10037, 37, 1009, '2024-03-07 16:00:00', 3, 49.99, 149.97, 'Google Pay', 'Completed', GETDATE()),
(10038, 38, 1007, '2024-03-08 11:30:00', 5, 14.99, 74.95, 'PayPal', 'Completed', GETDATE()),
(10039, 39, 1001, '2024-03-09 14:45:00', 1, 29.99, 29.99, 'Credit Card', 'Completed', GETDATE()),
(10040, 40, 1011, '2024-03-10 09:00:00', 2, 79.99, 159.98, 'Apple Pay', 'Completed', GETDATE()),
(10041, 41, 1018, '2024-03-11 15:30:00', 5, 6.99, 34.95, 'Credit Card', 'Pending', GETDATE()),
(10042, 42, 1000, '2024-03-12 10:15:00', 1, 1299.99, 1299.99, 'Google Pay', 'Completed', GETDATE()),
(10043, 43, 1006, '2024-03-13 12:45:00', 2, 39.99, 79.98, 'PayPal', 'Completed', GETDATE()),
(10044, 44, 1012, '2024-03-14 14:20:00', 4, 12.99, 51.96, 'Credit Card', 'Completed', GETDATE()),
(10045, 45, 1005, '2024-03-15 11:00:00', 1, 199.99, 199.99, 'Debit Card', 'Completed', GETDATE()),
(10046, 46, 1003, '2024-03-16 16:15:00', 1, 599.99, 599.99, 'Credit Card', 'Completed', GETDATE()),
(10047, 47, 1009, '2024-03-17 10:30:00', 2, 49.99, 99.98, 'Apple Pay', 'Completed', GETDATE()),
(10048, 48, 1002, '2024-03-18 13:45:00', 3, 9.99, 29.97, 'Google Pay', 'Completed', GETDATE()),
(10049, 49, 1017, '2024-03-19 15:00:00', 1, 129.99, 129.99, 'PayPal', 'Refunded', GETDATE()),
(10050, 50, 1004, '2024-03-20 09:30:00', 1, 149.99, 149.99, 'Credit Card', 'Completed', GETDATE()),
(10051, 1, 1011, '2024-03-21 14:15:00', 1, 79.99, 79.99, 'Debit Card', 'Completed', GETDATE()),
(10052, 2, 1008, '2024-03-22 11:45:00', 6, 4.99, 29.94, 'Credit Card', 'Pending', GETDATE()),
(10053, 3, 1007, '2024-03-23 16:20:00', 2, 14.99, 29.98, 'Google Pay', 'Completed', GETDATE()),
(10054, 4, 1019, '2024-03-24 10:00:00', 8, 11.99, 95.92, 'PayPal', 'Completed', GETDATE());

