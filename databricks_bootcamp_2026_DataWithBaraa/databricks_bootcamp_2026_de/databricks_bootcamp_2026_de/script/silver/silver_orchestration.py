# Databricks notebook source
# MAGIC %md
# MAGIC ## Orchestration Logic
# MAGIC This notebook programmatically runs all Silver transformation notebooks in sequence.  
# MAGIC It becomes the **single entry point** for the Silver layer in Databricks Jobs.

# COMMAND ----------

notebooks = [
    "./crm/silver_crm_cust_info",
    "./crm/silver_crm_prd_info",
    "./crm/silver_crm_sales_details",
    "./erp/silver_erp_cust_az12",
    "./erp/silver_erp_loc_a101",
    "./erp/silver_erp_px_cat_g1v2"
]

for nb in notebooks:
    print(f"Running {nb}")
    dbutils.notebook.run(nb, timeout_seconds=0)