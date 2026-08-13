-- Transactions
-- Basic transaction
BEGIN TRANSACTION;

UPDATE silver_customers
SET status = 'Inactive'
WHERE customer_id = 1;

UPDATE silver_sales
SET order_status = 'Cancelled'
WHERE customer_id = 1;

COMMIT;

-- Rollback on error
BEGIN TRANSACTION;

INSERT INTO silver_customers VALUES (100, 'Test', 'User', 'test@email.com', 'Test', NULL, '2024-01-01', 'Active', 1.0);

IF @@ERROR <> 0
    ROLLBACK;
ELSE
    COMMIT;

-- Savepoint (intermediate rollback point)
BEGIN TRANSACTION;

INSERT INTO silver_customers VALUES (101, 'User1', 'Last', 'user1@email.com', 'Country1', NULL, '2024-01-01', 'Active', 1.0);

SAVE TRANSACTION sp1;

INSERT INTO silver_customers VALUES (102, 'User2', 'Last', 'user2@email.com', 'Country2', NULL, '2024-01-01', 'Active', 1.0);

-- Rollback to savepoint if needed
ROLLBACK TRANSACTION sp1;

COMMIT;

-- Isolation levels
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION
    SELECT * FROM silver_customers;
COMMIT;



Use Case: Ensure data consistency
Production Example: Complex multi-table updates that must succeed or fail together









