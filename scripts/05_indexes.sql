-- CONCEPT #30: Nonclustered Index (Fixed clause order: INCLUDE then WHERE)
CREATE NONCLUSTERED INDEX idx_silver_sales_composite
    ON silver_sales (order_status, transaction_date)
    INCLUDE (total_amount, customer_id)
    WHERE order_status IN ('Completed', 'Pending');

-- CONCEPT #31: Composite Filtered Index
CREATE NONCLUSTERED INDEX idx_composite_customer_country
    ON silver_customers (country, status)
    WHERE status = 'Active';

-- CONCEPT #32: Included Columns Index
CREATE NONCLUSTERED INDEX idx_product_revenue
    ON silver_products (category, unit_price)
    INCLUDE (product_name, stock_quantity);

-- CONCEPT #33: Filtered Index with Included Columns (Fixed: INCLUDE before WHERE)
CREATE NONCLUSTERED INDEX idx_high_value_products
    ON silver_products (unit_price DESC)
    INCLUDE (product_name, category)
    WHERE unit_price > 100;
