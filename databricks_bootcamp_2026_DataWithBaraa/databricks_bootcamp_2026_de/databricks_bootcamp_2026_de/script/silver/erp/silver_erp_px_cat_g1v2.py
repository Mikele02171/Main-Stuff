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

df = spark.table("workspace.bronze.erp_px_cat_g1v2")

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
# MAGIC ## Normalize Maintenance Flag to Boolean

# COMMAND ----------

df = df.withColumn(
    "maintenance",
    F.when(F.upper(col("maintenance")) == "YES", F.lit(True))
     .when(F.upper(col("maintenance")) == "NO", F.lit(False))
     .otherwise(None)
)


# COMMAND ----------

# MAGIC %md
# MAGIC ## Renaming Columns

# COMMAND ----------

RENAME_MAP = {
    "id": "category_id",
    "cat": "category",
    "subcat": "subcategory",
    "maintenance": "maintenance_flag"
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

df.write.mode("overwrite").format("delta").saveAsTable("workspace.silver.erp_product_category")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Sanity checks of silver table

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM workspace.silver.erp_product_category LIMIT 10