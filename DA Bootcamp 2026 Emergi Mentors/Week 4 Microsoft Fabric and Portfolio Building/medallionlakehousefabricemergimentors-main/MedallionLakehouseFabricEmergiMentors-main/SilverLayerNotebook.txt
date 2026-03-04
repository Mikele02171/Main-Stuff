# NOTEBOOK TITLE SILVER LAYER NOTEBOOK: DATA CLEANING AND INTEGRATION
# LOAD DATA FROM BRONZE LAYER
from pyspark.sql.functions import *

df_customers = spark.read.format("csv").option("header","true").load("Files/ShoppingMart_Bronze_Customers/ShoppingMart_customers.csv")
df_orders = spark.read.format("csv").option("header","true").load("Files/ShoppingMart_Bronze_Orders/ShoppingMart_orders.csv")
df_products = spark.read.format("csv").option("header","true").load("Files/ShoppingMart_Bronze_Products/ShoppingMart_products.csv")
df_reviews = spark.read.json("Files/ShoppingMart_Bronze_Reviews/ShoppingMart_review.json")
df_social = spark.read.json("Files/ShoppingMart_Bronze_Social_Media/ShoppingMart_social_media.json")
df_weblogs = spark.read.json("Files/ShoppingMart_Bronze_Web_Logs/ShoppingMart_web_logs.json")

# DATA CLEANING AND ENRICHING	
df_orders = df_orders.dropna(subset = ["OrderID", "CustomerID", "ProductID", "OrderDate", "TotalAmount"])
df_orders = df_orders.withColumn("OrderDate", to_date(col("OrderDate")))
# display(df_orders)

# JOIN WITH PRODUCTS & CUSTOMERS
df_orders = df_orders \
    .join (df_customers, on = 'CustomerID', how = "inner") \
    .join (df_products, on = 'ProductID', how = "inner")

# WRITE DATA TO SILVER LAYER	
df_orders.write.mode("overwrite").parquet("Files/ShoppingMart_Silver_Orders/ShoppingMart_customers_orderdata")

df_reviews.write.mode("overwrite").parquet("Files/ShoppingMart_Silver_Reviews/ShoppingMart_review")
df_social.write.mode("overwrite").parquet("Files/ShoppingMart_Silver_Social_Media/ShoppingMart_social_media")
df_weblogs.write.mode("overwrite").parquet("Files/ShoppingMart_Silver_Web_Logs/ShoppingMart_web_logs")
