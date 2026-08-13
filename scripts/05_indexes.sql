-- ============================================================================
-- 9. CREATE INDEXES FOR PERFORMANCE TUNING
-- CONCEPT #29-34: Clustered, Nonclustered, Composite, Filtered Indexes
-- ============================================================================

-- CONCEPT #29: Clustered Index (Primary Key already exists)

-- CONCEPT #30: Nonclustered Indexes
CREATE NONCLUSTERED INDEX idx_silver_sales_composite
    ON silver_sales (order_status, transaction_date)
    INCLUDE (total_amount, customer_id)
    WHERE order_status IN ('Completed', 'Pending');

-- CONCEPT #31: Composite Index
CREATE NONCLUSTERED INDEX idx_composite_customer_country
    ON silver_customers (country, status)
    WHERE status = 'Active';

-- CONCEPT #32: Included Columns (covered queries)
CREATE NONCLUSTERED INDEX idx_product_revenue
    ON silver_products (category, unit_price)
    INCLUDE (product_name, stock_quantity);

-- CONCEPT #33: Filtered Index
CREATE NONCLUSTERED INDEX idx_high_value_products
    ON silver_products (unit_price DESC)
    WHERE unit_price > 100
    INCLUDE (product_name, category);

