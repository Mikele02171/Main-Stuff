# Databricks notebook source
# MAGIC %md
# MAGIC #Initialization

# COMMAND ----------

import pyspark.sql.functions as F
from pyspark.sql.types import StringType, DateType
from pyspark.sql.functions import col, trim, length

# COMMAND ----------

# MAGIC %md
# MAGIC # Read Bronze table

# COMMAND ----------

df = spark.table("workspace.bronze.crm_sales_details")

# COMMAND ----------

# MAGIC %md
# MAGIC #Silver Transformations

# COMMAND ----------

# MAGIC %md
# MAGIC ##Trimming

# COMMAND ----------

for field in df.schema.fields:
    if isinstance(field.dataType, StringType):
        df = df.withColumn(field.name, trim(col(field.name)))

# COMMAND ----------

# MAGIC %md
# MAGIC ##Cleaning Dates

# COMMAND ----------

df = (
    df
    .withColumn(
        "sls_order_dt",
        F.when(
            (col("sls_order_dt") == 0) | (length(col("sls_order_dt")) != 8),
            None
        ).otherwise(F.to_date(col("sls_order_dt").cast("string"), "yyyyMMdd"))
    )
    .withColumn(
        "sls_ship_dt",
        F.when(
            (col("sls_ship_dt") == 0) | (length(col("sls_ship_dt")) != 8),
            None
        ).otherwise(F.to_date(col("sls_ship_dt").cast("string"), "yyyyMMdd"))
    )
    .withColumn(
        "sls_due_dt",
        F.when(
            (col("sls_due_dt") == 0) | (length(col("sls_due_dt")) != 8),
            None
        ).otherwise(F.to_date(col("sls_due_dt").cast("string"), "yyyyMMdd"))
    )
)

# COMMAND ----------

# MAGIC %md
# MAGIC ##Sales and Price Corrections

# COMMAND ----------


df = (
    df
    .withColumn(
        "sls_price",
        F.when(
            (col("sls_price").isNull()) | (col("sls_price") <= 0),
            F.when(
                col("sls_quantity") != 0,
                col("sls_sales") / col("sls_quantity")
            ).otherwise(None)
        ).otherwise(col("sls_price"))
    )
)


# COMMAND ----------

# MAGIC %md
# MAGIC ## Renaming Columns

# COMMAND ----------

RENAME_MAP = {
    "sls_ord_num": "order_number",
    "sls_prd_key": "product_number",
    "sls_cust_id": "customer_id",
    "sls_order_dt": "order_date",
    "sls_ship_dt": "ship_date",
    "sls_due_dt": "due_date",
    "sls_sales": "sales_amount",
    "sls_quantity": "quantity",
    "sls_price": "price"
}
for old_name, new_name in RENAME_MAP.items():
    df = df.withColumnRenamed(old_name, new_name)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Sanity checks of dataframe

# COMMAND ----------

df.limit(10).display()

# COMMAND ----------

# MAGIC %md
# MAGIC #Writing Silver Table

# COMMAND ----------

df.write.mode("overwrite").format("delta").saveAsTable("workspace.silver.crm_sales")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Sanity checks of silver table

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM workspace.silver.crm_sales LIMIT 10