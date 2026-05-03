import pandas as pd

# Read CSV file
df = pd.read_csv('data.csv')

# Display basic information
print("Dataset Shape:")
print(f"Rows: {df.shape[0]}, Columns: {df.shape[1]}\n")

print("Column Names and Types:")
print(df.dtypes)
print()

print("First Few Rows:")
print(df.head())
print()

print("Summary Statistics:")
print(df.describe())
print()

print("Missing Values:")
print(df.isnull().sum())
print()

print("Data Info:")
df.info()
