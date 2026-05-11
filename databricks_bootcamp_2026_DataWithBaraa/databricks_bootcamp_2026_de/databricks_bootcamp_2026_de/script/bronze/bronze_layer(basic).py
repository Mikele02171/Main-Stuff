# Databricks notebook source
# MAGIC %md
# MAGIC #Read From CSV and Write Silver Table

# COMMAND ----------

# MAGIC %md
# MAGIC ## load "cust_info.csv"

# COMMAND ----------

df = spark.read.option("header", "true").option("inferSchema", "true").csv('/Volumes/workspace/bronze/raw_sources/source_crm/cust_info.csv', header=True)
df.write.mode("overwrite").saveAsTable("workspace.bronze.crm_cust_info")

# COMMAND ----------

# MAGIC %md
# MAGIC ## load "prd_info.csv"

# COMMAND ----------

df = spark.read.option("header", "true").option("inferSchema", "true").csv('/Volumes/workspace/bronze/raw_sources/source_crm/prd_info.csv', header=True)
df.write.mode("overwrite").saveAsTable("workspace.bronze.crm_prd_info")

# COMMAND ----------

# MAGIC %md
# MAGIC ## load "sales_details.csv"

# COMMAND ----------

df = spark.read.option("header", "true").option("inferSchema", "true").csv('/Volumes/workspace/bronze/raw_sources/source_crm/sales_details.csv', header=True)
df.write.mode("overwrite").saveAsTable("workspace.bronze.crm_sales_details")

# COMMAND ----------

# MAGIC %md
# MAGIC ## load "CUST_AZ12.csv"

# COMMAND ----------

df = spark.read.option("header", "true").option("inferSchema", "true").csv('/Volumes/workspace/bronze/raw_sources/source_erp/CUST_AZ12.csv', header=True)
df.write.mode("overwrite").saveAsTable("workspace.bronze.erp_cust_az12")

# COMMAND ----------

# MAGIC %md
# MAGIC ## load "LOC_A101.csv"

# COMMAND ----------

df = spark.read.option("header", "true").option("inferSchema", "true").csv('/Volumes/workspace/bronze/raw_sources/source_erp/LOC_A101.csv', header=True)
df.write.mode("overwrite").saveAsTable("workspace.bronze.erp_loc_a101")

# COMMAND ----------

# MAGIC %md
# MAGIC ## load "PX_CAT_G1V2.csv"

# COMMAND ----------

df = spark.read.option("header", "true").option("inferSchema", "true").csv('/Volumes/workspace/bronze/raw_sources/source_erp/PX_CAT_G1V2.csv', header=True)
df.write.mode("overwrite").saveAsTable("workspace.bronze.erp_px_cat_g1v2")