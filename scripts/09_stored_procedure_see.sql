🖱️ Method 1: SSMS GUI (Easiest Way)
👆 Right-Click Method: Object Explorer-এ আপনার কাঙ্ক্ষিত Procedure (যেমন: dbo.sp_refresh_customer_metrics) এর ওপর Right-Click করুন।

📝 Modify Select করুন: Context Menu থেকে Modify সেকশনে ক্লিক করুন।

💻 Code Window: SSMS নতুন একটি Query Editor উইন্ডোতে পুরো CREATE OR ALTER PROCEDURE কোডটি ওপেন করে দেবে।



-- Stored Procedure এর ভেতরের পুরো SQL Script দেখার জন্য:
EXEC sp_helptext 'dbo.sp_refresh_customer_metrics';

EXEC sp_helptext 'dbo.sp_insert_customer';

EXEC sp_helptext 'dbo.sp_create_sales_transaction';




-- Metadata catalog থেকে সরাসরি Definition এক্সট্রাক্ট করা:
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.sp_refresh_customer_metrics')) AS procedure_code;



🚀 Executing / Testing the Procedure
Stored Procedure রান করে দেখার জন্য:

SQL
-- Full Refresh Test
EXEC dbo.sp_refresh_customer_metrics;

-- Single Customer Refresh Test
EXEC dbo.sp_refresh_customer_metrics @customer_id = 101;





🖱️ Method 1: SSMS GUI (Visual Scripting)
👆 Right-Click Method: Object Explorer-এ আপনার নির্দিষ্ট Function (যেমন: dbo.fn_top_products_by_category বা dbo.fn_calculate_clv) এর ওপর Right-Click করুন।

📝 Modify Select করুন: Menu থেকে Modify অপশনে ক্লিক করুন।

💻 View Code: SSMS একটি নতুন Query Editor-এ CREATE OR ALTER FUNCTION কোডটি সরাসরি Script আকারে দেখিয়ে দেবে।



-- Scalar বা Table-valued Function এর Definition দেখার জন্য:
EXEC sp_helptext 'dbo.fn_calculate_clv';


-- OBJECT_DEFINITION দিয়ে সরাসরি কোড বের করা:
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.fn_top_products_by_category')) AS function_code;



How to Execute & Test Functions
📊 1. Table-valued Function (TVF) Execution
Table-valued Function একটি Table রিটার্ন করে, তাই এটি FROM ক্লজে SELECT করে চালাতে হয়:
  
-- Table-valued function কল করার নিয়ম
SELECT * 
FROM dbo.fn_top_products_by_category('Electronics');




🔢 2. Scalar-valued Function Execution
Scalar Function একটি একক Value রিটার্ন করে, তাই এটি Schema Name (dbo.) সহ SELECT করতে হয়:
-- Scalar function কল করার নিয়ম
SELECT dbo.fn_calculate_clv(101) AS customer_clv;
SELECT dbo.fn_get_customer_segment(2500) AS segment;




