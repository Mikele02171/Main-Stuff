# Databricks notebook source
# MAGIC %md
# MAGIC # Initialization

# COMMAND ----------

import pyspark.sql.functions as F
from pyspark.sql.types import StringType
from pyspark.sql.functions import trim,col

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


# COMMAND ----------

# MAGIC %md
# MAGIC # Reading From Bronze Table

# COMMAND ----------

df = spark.table("workspace.bronze_de.crm_cust_info")

# COMMAND ----------

# MAGIC %md
# MAGIC # Data Transformations
# MAGIC

# COMMAND ----------

# Trim the string
# Normalization for martial_status, gndr
# Names are not friends
df.display()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Trimming

# COMMAND ----------


for field in df.schema.fields:
    if isinstance(field.dataType,StringType):
        df = df.withColumn(field.name,trim(col(field.name)))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Normalization

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
# MAGIC ## Remove Records with Missing Customer ID

# COMMAND ----------

df = df.filter(col("cst_id").isNotNull())

# COMMAND ----------

# MAGIC %md
# MAGIC ## Renaming the Columns

# COMMAND ----------

for old_name, new_name in RENAME_MAP.items():
    df = df.withColumnRenamed(old_name, new_name)

# COMMAND ----------

# MAGIC %md
# MAGIC # Write into Silver Table

# COMMAND ----------

(df.write.mode("overwrite").format("delta").saveAsTable("silver_de.crm_customers"))

# COMMAND ----------

# MAGIC %sql
# MAGIC select * from workspace.silver_de.crm_customers