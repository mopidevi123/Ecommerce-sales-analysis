E-Commerce Sales Analysis (UK Retail)
An end-to-end data analytics project analyzing transactional sales data from a UK-based online retailer — uncovering revenue trends, top products, customer behaviour, and geographic concentration, with strategic growth recommendations.
---
Problem Statement
A UK-based online retail business wants to understand:
How is revenue trending? — Are sales growing month-over-month?
What products drive volume? — Which items sell the most?
Who are the top customers? — Which customers contribute the most revenue?
Where is the business concentrated? — Is geographic dependency a risk?
When do sales peak? — Are there seasonal patterns to plan for?
---
Tools & Technologies
Tool	Purpose
Python (Pandas)	Data cleaning & feature engineering
PostgreSQL	Revenue & customer analysis
Power BI	Interactive dashboard & KPI reporting
---
Project Workflow
Step 1 — Data Cleaning (Python / Pandas)
This was the most complex cleaning task in the project due to the raw transactional nature of the data:
Removed cancelled orders — invoices starting with 'C' (e.g., C536379) represent returns/cancellations; dropped entirely
Removed negative Quantity rows — additional return records not caught by invoice prefix
Dropped null CustomerID rows — ~25% of rows had no CustomerID; removed as they cannot be used for customer-level analysis
Removed zero/negative UnitPrice rows — test entries and data errors
Engineered Revenue column — 'Revenue = Quantity × UnitPrice' (did not exist in raw data)
Extracted time features — parsed 'InvoiceDate' to datetime; extracted 'Month', 'Year', 'Quarter' for trend analysis
Before vs After Cleaning:
Metric	Raw Data	Cleaned Data
Total Rows	~541,909	~397,924
Null CustomerIDs	~135,080	0
Cancelled Orders	Included	Removed
Step 2 — SQL Analysis (PostgreSQL)
Used Advanced SQL including CTEs, window functions, aggregations, and CASE statements.
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

Step 3 — Power BI Dashboard
Monthly revenue trend line chart with data labels
Geographic map showing sales by country
Revenue distribution pie chart by country
Top 10 products by quantity bar chart
Top 10 customers by revenue bar chart
KPI cards for headline metrics
Slicers for Country and Month filtering
---
Key Findings
Metric	Value
Total Revenue	£8.89M
Total Orders	19K
Total Customers	4,338
Average Order Value	£479.56
Insights
UK dominates at 88.97% of total revenue — extreme geographic concentration
Q4 is peak season — November reaches £1.16M, the single highest month
Revenue grows steadily through the year from £0.45M (Jan) to £1.16M (Nov)
Top 10 customers contribute a disproportionately large share of revenue — losing one is high risk
Paper Craft and Ceramic items lead product sales at 81K and 78K units respectively
High AOV (£479.56) suggests many buyers are small businesses, not just individual consumers
---
Business Recommendations
Expand into Netherlands, EIRE, and Germany — these markets show organic demand already; targeted campaigns could grow their share from ~6% to 15%+
Build a VIP loyalty program for top 10 customers — revenue concentration is a risk; retain these accounts with dedicated account management
Stock top products before October — Q4 demand surge requires early inventory planning; focus on Paper Craft and Ceramic lines
Introduce minimum order incentives — encourage lower-spending customers to increase basket size, pushing AOV higher
Investigate Q4 December dip — revenue drops from £1.16M (Nov) to £1.09M (Dec); could indicate fulfilment delays or stock-outs
> Estimated impact: Geographic expansion + customer retention program could grow annual revenue by **15–20%** over 2 years.
---
Dashboard Preview
![Dashboard Preview](dashboard/dashboard_preview.png)
---
Dataset
Source: Online Retail Dataset — UCI Machine Learning Repository
Records: 541,909 raw transactions (397,924 after cleaning)
Period: December 2010 – December 2011
Features: 8 columns — InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country
---
Author
Pravallika Mopidevi
mopidevipravallika123@gmail.com
GitHub
SQL & Data Analytics | Power BI | Python
---
If you found this project useful, feel free to star the repository!
