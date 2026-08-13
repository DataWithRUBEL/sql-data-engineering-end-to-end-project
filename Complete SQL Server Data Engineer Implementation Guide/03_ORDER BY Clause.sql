-- Ascending order (default)
ORDER BY total_spent ASC;

-- Descending order
ORDER BY total_spent DESC;

-- Multiple columns
ORDER BY country ASC, total_spent DESC;

-- Explicit sorting
ORDER BY CASE WHEN status = 'VIP' THEN 1 ELSE 2 END;

Use Case: Sort results for better analysis
Production Example: Rank customers by lifetime value
