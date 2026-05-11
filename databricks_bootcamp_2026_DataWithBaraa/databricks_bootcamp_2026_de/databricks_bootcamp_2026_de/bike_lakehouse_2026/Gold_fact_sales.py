# Databricks notebook source
# MAGIC %md
# MAGIC ## The Transformation Logic

# COMMAND ----------


query = """
SELECT
    sd.order_number,
    pr.product_key,
    cu.customer_key,
    sd.order_date,
    sd.ship_date,
    sd.due_date,
    sd.sales_amount,
    sd.quantity,
    sd.price
FROM silver_de.crm_sales sd
LEFT JOIN gold_de.dim_products pr
    ON sd.product_number = pr.product_number
LEFT JOIN gold_de.dim_customers cu
    ON sd.customer_id = cu.customer_id;
"""
df = spark.sql(query)

# COMMAND ----------


df.limit(10).display()
     

# COMMAND ----------

# MAGIC %md
# MAGIC ## Writing Gold Table

# COMMAND ----------


df.write.mode("overwrite").format("delta").saveAsTable("workspace.gold_de.fact_sales")

# COMMAND ----------

# MAGIC %md
# MAGIC ### Sanity checks of Gold table

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM workspace.gold_de.fact_sales LIMIT 10