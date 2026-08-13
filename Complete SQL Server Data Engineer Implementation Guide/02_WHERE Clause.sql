-- Single condition
WHERE country = 'India'

-- Multiple conditions (AND)
WHERE country = 'USA' AND status = 'Active'

-- Complex conditions (OR)
WHERE total_spent > 1000 OR customer_segment = 'Gold'

-- Range filtering
WHERE transaction_date BETWEEN '2024-01-01' AND '2024-03-31'

-- String pattern matching
WHERE email LIKE '%@email.com'

-- Null handling
WHERE phone IS NOT NULL
WHERE email IS NULL


Use Case: Filter records based on conditions
Production Example: Get all active customers from premium markets
