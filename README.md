# E-Commerce Sales Analysis Dashboard

## Project Overview

This project analyzes e-commerce sales data using Python, SQL, and Power BI. It includes data cleaning, analysis, and dashboard creation to generate business insights.

## Objectives

* Clean and preprocess raw data
* Analyze sales trends and customer behavior
* Build an interactive dashboard

## Tools Used

* Python (Pandas)
* SQL (PostgreSQL)
* Power BI

## Project Structure

ecommerce-sales-analysis/
|
|-- data/
|   |-- cleaned_ecommerce.csv
|
|-- python/
|   |-- data_cleaning_analysis.py
|
|-- sql/
|   |-- advanced_queries.sql
|
|-- powerbi/
|   |-- ecommerce_dashboard.pbix
|
|-- images/
|   |-- dashboard.png
|
|-- README.md

## Data Cleaning (Python)

* Removed missing values and duplicates
* Converted InvoiceDate to datetime format
* Created new columns:

  * Sales = Quantity * UnitPrice
  * Month and Date extracted
* Used Pandas for data processing

## SQL Analysis

* Monthly revenue trend
* Top products by quantity
* Top customers by revenue
* Country-wise sales analysis

## Dashboard (Power BI)

* Total Revenue, Orders, Customers, Avg Order Value
* Monthly Revenue Trend chart
* Top 10 Products chart
* Top Customers chart
* Country-wise sales distribution
* Map visualization

## Key Insights

* Revenue is mostly from the UK (~82%)
* Few products contribute most of the sales
* Sales are highest in Q4 (seasonal trend)

## How to Run

Python:
pip install pandas numpy
python data_cleaning_analysis.py

SQL:
Run queries in PostgreSQL / pgAdmin

Power BI:
Open ecommerce_dashboard.pbix in Power BI Desktop

## Future Improvements

* Add customer segmentation (RFM)
* Automate data pipeline
* Deploy dashboard online

## Author

Pravallika Mopidevi