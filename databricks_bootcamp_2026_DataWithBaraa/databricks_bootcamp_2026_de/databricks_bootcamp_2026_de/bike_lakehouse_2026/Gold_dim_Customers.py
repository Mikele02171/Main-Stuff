# Databricks notebook source
# MAGIC %md
# MAGIC ## Init

# COMMAND ----------

import pyspark.sql.functions as F
from pyspark.sql.types import StringType
from pyspark.sql.functions import trim,col

# COMMAND ----------

query = """
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.customer_id) AS customer_key,
    ci.customer_id,
    ci.customer_number,
    ci.first_name,
    ci.last_name,
    la.country,
    ci.marital_status,

    CASE
        WHEN ci.gender <> 'n/a' THEN ci.gender
        ELSE COALESCE(ca.gender, 'n/a')
    END AS gender,
    ca.birth_date AS birthdate,
    ci.created_date AS create_date
FROM silver_de.crm_customers ci
LEFT JOIN silver_de.erp_customers ca
    ON ci.customer_number = ca.customer_number
LEFT JOIN silver_de.erp_customer_location la
    ON ci.customer_number = la.customer_number
"""
df = spark.sql(query)

# COMMAND ----------


df.limit(10).display()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Business Transformation and Modeling

# COMMAND ----------

# MAGIC %md
# MAGIC ## Write it to Gold Table

# COMMAND ----------


df.write.mode("overwrite").format("delta").saveAsTable("workspace.gold_de.dim_customers")

# COMMAND ----------

# MAGIC %md
# MAGIC ### Sanity checks of Gold table

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM workspace.gold_de.dim_customers LIMIT 10
# MAGIC      