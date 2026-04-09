
import pandas as pd

df = pd.read_csv('data/Online_retail.csv', encoding ='latin1')

print(df.head())

print(df.info())

print(df.describe())


# Data cleaning

# Handle missing values

df.isnull().sum()
df = df.dropna(subset=['CustomerID'])


# Remove invalid data

df = df[df['Quantity'] > 0]

df = df[df['UnitPrice'] > 0]


# Fix data types

df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])

df['CustomerID'] = df['CustomerID'].astype(int)


# Create columns

df['Date'] = df['InvoiceDate'].dt.date

df['Month'] = df['InvoiceDate'].dt.to_period('M').astype(str)
                                                         

# Create sales column

df['Sales'] = df['Quantity'] * df['UnitPrice']


# Remove duplicates

df = df.drop_duplicates()



# Save cleaned file

df.to_csv("data/cleaned_online_retail.csv", index = False)






print("Data cleaned successfully")

print(df.columns)

