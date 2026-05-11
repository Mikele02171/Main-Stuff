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

df = spark.table("workspace.bronze.erp_cust_az12")

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
# MAGIC ##Customer ID Cleanup

# COMMAND ----------

df = df.withColumn(
    "cid",
    F.when(col("cid").startswith("NAS"),
           F.substring(col("cid"), 4, F.length(col("cid"))))
     .otherwise(col("cid"))
)


# COMMAND ----------

# MAGIC %md
# MAGIC ##Birthdate Validation

# COMMAND ----------

df = df.withColumn(
    "bdate",
    F.when(col("bdate") > F.current_date(), None)
     .otherwise(col("bdate"))
)

# COMMAND ----------

# MAGIC %md
# MAGIC ##Gender Normalization

# COMMAND ----------

df = df.withColumn(
    "gen",
    F.when(F.upper(col("gen")).isin("F", "FEMALE"), "Female")
     .when(F.upper(col("gen")).isin("M", "MALE"), "Male")
     .otherwise("n/a")
)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Renaming Columns

# COMMAND ----------

RENAME_MAP = {
    "cid": "customer_number",
    "bdate": "birth_date",
    "gen": "gender"
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

df.write.mode("overwrite").format("delta").saveAsTable("workspace.silver.erp_customers")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Sanity checks of silver table

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM workspace.silver.erp_customers LIMIT 10