
import pandas as pd

df = pd.read_csv('data/cleaned_online_retail.csv')

print(df.head())

'''
 #Time features

df['Year'] = df['InvoiceDate'].dt.year
df['Month'] = df['InvoiceDate'].dt.month
df['Day'] = df['InvoiceDate'].dt.day
df['Hour'] = df['InvoiceDate'].dt.hour

 #Customer Metrics

customer_sales = df.groupby('CustomerID')['Sales'].sum().reset_index()
customer_orders = df.groupby('CustomerID')['InvoiceNo'].nunique().nunique


'''

df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])

# 1. Monthly revenue trend

monthly_sales = df.groupby(df['InvoiceDate'].dt.to_period('M'))['Sales'].sum().reset_index()
monthly_sales['InvoiceDate'] = monthly_sales['InvoiceDate'].astype(str)

print(monthly_sales)


# 2. Top 10 customers(Revenue)

top_customers = df.groupby('CustomerID')['Sales'].sum().sort_values(ascending=False).head(10)
print(top_customers)



# 3. Top 10 products

top_products = df.groupby('Description')['Quantity'].sum().sort_values(ascending=False).head(10)
print(top_products)


# 4. Country wise Revenue

country_sales = df.groupby('Country')['Sales'].sum().sort_values(ascending=False)
print("Country-wise Revenue : ", country_sales)


# 5. Average order value

order_value = df.groupby('InvoiceNo')['Sales'].sum().mean()
print("Average order value : ", order_value)


# 6. Customer purchase frequency

purchase_freq = df.groupby('CustomerID')['InvoiceNo'].nunique()
print(purchase_freq.describe())



# 7. Cohort analysis

df['InvoiceMonth'] = df['InvoiceDate'].dt.to_period('M')
df['CohortMonth'] = df.groupby('CustomerID')['InvoiceDate'].transform('min').dt.to_period('M')

cohort_data = df.groupby(['CohortMonth', 'InvoiceMonth'])['CustomerID'].nunique().reset_index()

print(cohort_data.head())


# Profitability analysis

df['Profit'] = df['Sales'] * 0.2

profit_analysis = df.groupby('Description')['Profit'].sum().sort_values(ascending =False)
print(profit_analysis.head())



