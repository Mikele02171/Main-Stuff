# Pandas Basics Tutorial
# This file demonstrates some basic concepts and operations in pandas, a powerful Python library for data manipulation and analysis.

import pandas as pd

# 1. Creating a Series
# A Series is a one-dimensional array-like object that can hold any data type.
# It is similar to a column in a spreadsheet or a single column in a database table.

print("1. Creating a Series:")
s = pd.Series([1, 3, 5, 6, 8])
print(s)
print()

# 2. Creating a DataFrame
# A DataFrame is a two-dimensional, size-mutable, and potentially heterogeneous tabular data structure.
# It is like a spreadsheet or SQL table, with rows and columns.

print("2. Creating a DataFrame:")
data = {
    'Name': ['Alice', 'Bob', 'Charlie', 'Diana'],
    'Age': [25, 30, 35, 28],
    'City': ['New York', 'Los Angeles', 'Chicago', 'Houston']
}
df = pd.DataFrame(data)
print(df)
print()

# 3. Accessing columns
# You can access a single column using square brackets or dot notation.

print("3. Accessing the 'Name' column:")
print(df['Name'])
print()

# 4. Filtering rows
# You can filter rows based on conditions.

print("4. Filtering rows where Age > 25:")
filtered_df = df[df['Age'] > 25]
print(filtered_df)
print()

# 5. Adding a new column
# You can add new columns to a DataFrame.

print("5. Adding a new 'Salary' column:")
df['Salary'] = [50000, 60000, 70000, 55000]
print(df)
print()

# 6. Basic statistics
# Pandas provides methods for basic statistical operations.

print("6. Basic statistics of the DataFrame:")
print(df.describe())
print()

# 7. Grouping and aggregating
# You can group data and perform aggregate operations.

print("7. Grouping by City and calculating mean Age:")
grouped = df.groupby('City')['Age'].mean()
print(grouped)
print()

# 8. Reading from CSV (example, assuming a file exists)
# Pandas can read data from various file formats like CSV, Excel, etc.
# Uncomment the following lines if you have a CSV file named 'data.csv' in the same directory.

# print("8. Reading from CSV:")
# df_csv = pd.read_csv('data.csv')
# print(df_csv.head())  # Shows the first 5 rows

print("End of Pandas Basics Tutorial.")