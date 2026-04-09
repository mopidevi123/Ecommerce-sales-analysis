CREATE TABLE ecommerce 
(
invoice_no VARCHAR(20),
stock_code	VARCHAR(20),
description	TEXT,
quantity INT,	
invoice_date TIMESTAMP,	
unit_price DECIMAL(10,2),	
customer_id	INT,
country	VARCHAR(50),
date DATE,
month VARCHAR(10),
sales DECIMAL(12,2)

);




\copy ecommerce FROM 
'C:\Users\mopid\Desktop\Ecommerce_customer\data\cleaned_online_retail.csv' DELIMITER ',' CSV HEADER;


select * from ecommerce;


------- 1. Monthly revenue trend

SELECT DATE_TRUNC('month', invoice_date) AS Month,
		SUM(quantity * unit_price) AS revenue
FROM ecommerce
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY Month;


---------- 2. Top customers 

SELECT * FROM (
		SELECT customer_id,
				SUM(quantity * unit_price) AS total_spent,
				RANK() OVER (ORDER BY SUM(quantity * unit_price) DESC) AS rank
		FROM ecommerce
		GROUP BY customer_id
) t
WHERE rank <= 10;



--------- 3. Customer segmentation

WITH customer_data AS (
	SELECT customer_id,
			SUM(quantity * unit_price) AS total_spent
	FROM ecommerce
	GROUP BY customer_id
)
SELECT customer_id, total_spent,
		CASE
			WHEN total_spent > 5000 THEN 'High Value'
			WHEN total_spent > 2000 THEN 'Medium Value'
			ELSE 'Low Value'
		END AS segment
FROM customer_data;



---------- 4. Retention analysis

SELECT customer_id,
		COUNT(DISTINCT invoice_no) AS orders
FROM ecommerce
GROUP BY customer_id
HAVING COUNT(DISTINCT invoice_no) > 1;


------- 5. Running total

SELECT invoice_date, 
		SUM(quantity * unit_price) AS daily_sales,
		SUM(SUM(quantity * unit_price)) OVER (ORDER BY invoice_date) AS running_total
FROM ecommerce
GROUP BY invoice_date
ORDER BY invoice_date;


------- 6. Month over month growth

WITH monthly_sales AS (
	SELECT DATE_TRUNC('month', invoice_date) AS Month,
			SUM(quantity * unit_price) AS revenue
	FROM ecommerce
	GROUP BY DATE_TRUNC('month', invoice_date)
)
SELECT Month, revenue,
		LAG(revenue) OVER (ORDER BY Month) AS prev_month,
		(revenue - LAG(revenue) OVER (ORDER BY Month)) AS growth
FROM  monthly_sales;



-------- 7. Top customer per country

SELECT * FROM (
	SELECT country, customer_id,
			SUM(quantity * unit_price) AS total_spent,
			RANK() OVER (PARTITION BY country ORDER BY SUM(quantity * unit_price) DESC) AS rank
	FROM ecommerce
	GROUP BY country, customer_id
) t
WHERE rank = 1;


-------- 8. Repeat vs new customers

SELECT CASE 
		WHEN COUNT(DISTINCT invoice_no) = 1 THEN 'New'
		ELSE 'Repeat'
	   END AS customer_type,
	   COUNT(*) AS total_customers
FROM ecommerce
GROUP BY customer_id;


-------- 9. Basket size

SELECT invoice_no,
		COUNT(stock_code) AS items_per_order
FROM ecommerce
GROUP BY invoice_no
ORDER BY items_per_order;


--------- 10. Top 3 products per country

SELECT * FROM (
	SELECT country, description,
			SUM(quantity) AS total_sold,
			DENSE_RANK() OVER (PARTITION BY country ORDER BY SUM(quantity) DESC) AS rank
	FROM ecommerce
	GROUP BY country, description
) t
WHERE rank <= 3;


-------- 11. Customer lifetime value

SELECT customer_id, 
		SUM(quantity * unit_price) AS total_revenue,
		COUNT(DISTINCT invoice_no) AS total_orders,
		AVG(quantity * unit_price) AS avg_order_value
FROM ecommerce
GROUP BY customer_id
ORDER BY total_revenue DESC;



-------- 12. Churn indicator

SELECT customer_id,
		MAX(invoice_date) AS last_purchase,
		EXTRACT(DAY FROM CURRENT_DATE - MAX(invoice_date)) AS days_inactive
FROM ecommerce
GROUP BY customer_id
HAVING EXTRACT(DAY FROM CURRENT_DATE - MAX(invoice_date)) > 90;







