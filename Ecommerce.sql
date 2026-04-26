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

--------- or

SELECT EXTRACT(MONTH FROM invoice_date) AS Month,
	SUM(quantity * unit_price) AS revenue
FROM ecommerce
GROUP BY EXTRACT(MONTH FROM invoice_date)
ORDER BY Month;


------Monthly Revenue Trend:

SELECT
  EXTRACT(MONTH FROM invoice_date) AS month_num,
  TO_CHAR(invoice_date, 'Month') AS month_name,
  ROUND(SUM(quantity * unit_price), 2) AS total_revenue,
  COUNT(DISTINCT invoice_no) AS total_orders
FROM ecommerce
GROUP BY month_num, month_name
ORDER BY month_num;

--------Revenue by Country:

SELECT
  country,
  ROUND(SUM(quantity * unit_price), 2) AS total_revenue,
  ROUND(SUM(quantity * unit_price) * 100.0 /
    SUM(SUM(quantity * unit_price)) OVER (), 2) AS revenue_pct
FROM ecommerce
GROUP BY country
ORDER BY total_revenue DESC;

--------Top 10 Customers by Revenue:

WITH customer_revenue AS (
  SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price), 2) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    RANK() OVER (ORDER BY SUM(quantity * unit_price) DESC) AS revenue_rank
  FROM ecommerce
  GROUP BY customer_id
)
SELECT * FROM customer_revenue
WHERE revenue_rank <= 10;

------Top 10 Products by Quantity Sold:

SELECT
  description,
  SUM(quantity) AS total_quantity,
  ROUND(SUM(quantity * unit_price), 2) AS total_revenue,
  RANK() OVER (ORDER BY SUM(quantity) DESC) AS quantity_rank
FROM ecommerce
GROUP BY description
ORDER BY total_quantity DESC
LIMIT 10;

-------Average Order Value (AOV):

SELECT
  ROUND(SUM(quantity * unit_price) / COUNT(DISTINCT invoice_no), 2) AS avg_order_value
FROM ecommerce;




------- Revenue by country

SELECT country,
		SUM(quantity * unit_price) AS revenue
FROM ecommerce
GROUP BY country
ORDER BY revenue DESC;

-------or

SELECT country,
		SUM(sales) AS revenue
FROM ecommerce
GROUP BY country
ORDER BY revenue DESC;


-------Top products by quality

SELECT description,
		SUM(quantity) AS total_quantity,
		RANK() OVER (ORDER BY SUM(quantity) DESC) AS rnk
FROM ecommerce
GROUP BY description;


---------- 2. Top customers 

SELECT * FROM (
		SELECT customer_id,
				SUM(quantity * unit_price) AS total_spent,
				RANK() OVER (ORDER BY SUM(quantity * unit_price) DESC) AS rank
		FROM ecommerce
		GROUP BY customer_id
) t
WHERE rank <= 10;


------ Top 10 customers by revenue

WITH customer_revenue AS (
SELECT customer_id,
		ROUND(SUM(quantity * unit_price), 2) AS total_revenue,
		COUNT(DISTINCT invoice_no) AS total_orders,
		ROUND(AVG(quantity * unit_price), 2) AS avg_order_value,
		RANK() OVER (ORDER BY SUM(quantity * unit_price) DESC) AS revenue_rnk
FROM ecommerce
GROUP BY customer_id
)
SELECT * FROM customer_revenue
WHERE revenue_rnk <= 10
ORDER BY revenue_rnk;


------Customers who haven't purchased in the last 3 months

SELECT customer_id,
		MAX(invoice_date) AS last_purchase_date,
		CURRENT_DATE - MAX(invoice_date) AS days_since_purchase
FROM ecommerce
GROUP BY customer_id
HAVING MAX(invoice_date) < CURRENT_DATE - INTERVAL '3 months'
ORDER BY last_purchase_date ASC;



------- Month over month revenue growth

WITH monthly_revenue AS (
SELECT EXTRACT(MONTH FROM invoice_date) AS month_num,
		ROUND(SUM(quantity * unit_price), 2) AS revenue
FROM ecommerce
GROUP BY month_num
),
growth AS (
SELECT month_num,revenue,
		LAG(revenue) OVER(ORDER BY month_num) AS prev_month_revenue
FROM monthly_revenue
)
SELECT month_num,revenue,prev_month_revenue,
		ROUND((revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 2) AS growth_pct
FROM growth;



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







