# Databricks notebook source
# MAGIC %md
# MAGIC #Initialization

# COMMAND ----------

import pyspark.sql.functions as F
from pyspark.sql.types import StringType
from pyspark.sql.functions import trim, col

# COMMAND ----------

# MAGIC %md
# MAGIC # Read Bronze table

# COMMAND ----------

df = spark.table("workspace.bronze.crm_cust_info")

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
# MAGIC ##Normalization

# COMMAND ----------


df = (
    df
    .withColumn(
        "cst_marital_status",
        F.when(F.upper(F.col("cst_marital_status")) == "S", "Single")
         .when(F.upper(F.col("cst_marital_status")) == "M", "Married")
         .otherwise("n/a")
    )
    .withColumn(
        "cst_gndr",
        F.when(F.upper(F.col("cst_gndr")) == "F", "Female")
         .when(F.upper(F.col("cst_gndr")) == "M", "Male")
         .otherwise("n/a")
    )
)

# COMMAND ----------

# MAGIC %md
# MAGIC ##Remove Records with Missing Customer ID

# COMMAND ----------

df = df.filter(col("cst_id").isNotNull())

# COMMAND ----------

# MAGIC %md
# MAGIC ## Renaming Columns

# COMMAND ----------

RENAME_MAP = {
    "cst_id": "customer_id",
    "cst_key": "customer_number",
    "cst_firstname": "first_name",
    "cst_lastname": "last_name",
    "cst_marital_status": "marital_status",
    "cst_gndr": "gender",
    "cst_create_date": "created_date"
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

df.write.mode("overwrite").format("delta").saveAsTable("workspace.silver.crm_customers")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Sanity checks of silver table

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM workspace.silver.crm_customers LIMIT 10