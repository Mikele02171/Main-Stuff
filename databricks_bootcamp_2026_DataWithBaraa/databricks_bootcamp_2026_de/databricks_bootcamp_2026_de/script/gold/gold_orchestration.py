# Databricks notebook source
# MAGIC %md
# MAGIC ## Orchestration Logic
# MAGIC This notebook programmatically runs all Gold notebooks in sequence.  
# MAGIC It becomes the **single entry point** for the Gold layer in Databricks Jobs.

# COMMAND ----------

notebooks = [
    "./gold_dim_customers",
    "./gold_dim_products",
    "./gold_fact_sales"
]

for nb in notebooks:
    print(f"Running {nb}")
    dbutils.notebook.run(nb, timeout_seconds=0)