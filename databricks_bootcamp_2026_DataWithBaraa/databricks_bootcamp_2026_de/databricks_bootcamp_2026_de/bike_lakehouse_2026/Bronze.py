# Databricks notebook source
# MAGIC %md
# MAGIC # Manual version
# MAGIC ## Reading From CSV File, for crm_prd_info.csv

# COMMAND ----------

# DBTITLE 1,Cell 2
df = (spark.read.option("header","true").option("inferSchema","true").csv("/Volumes/workspace/bronze_de/source_systems/source_crm/prd_info.csv"))
display(df)

# COMMAND ----------

# MAGIC %md
# MAGIC #Write it to Bronze Layer

# COMMAND ----------

df.write.mode("overwrite").saveAsTable("workspace.bronze_de.crm_prd_info")

# COMMAND ----------

# MAGIC %md
# MAGIC ## crm_cust_info

# COMMAND ----------

df = (spark.read.option("header","true").option("inferSchema","true").csv("/Volumes/workspace/bronze_de/source_systems/source_crm/cust_info.csv"))
df.write.mode("overwrite").saveAsTable("workspace.bronze_de.crm_cust_info")

# COMMAND ----------

# MAGIC %md
# MAGIC ## crm_sales_details

# COMMAND ----------

df = (spark.read.option("header","true").option("inferSchema","true").csv("/Volumes/workspace/bronze_de/source_systems/source_crm/sales_details.csv"))
df.write.mode("overwrite").saveAsTable("workspace.bronze_de.crm_sales_details")

# COMMAND ----------

# MAGIC %md
# MAGIC ## erp_cust_az12

# COMMAND ----------


df = spark.read.option("header", "true").option("inferSchema", "true").csv('/Volumes/workspace/bronze_de/source_systems/source_erp/CUST_AZ12.csv', header=True)
df.write.mode("overwrite").saveAsTable("workspace.bronze.erp_cust_az12")

# COMMAND ----------

# MAGIC %md
# MAGIC ## erp_loc_a101

# COMMAND ----------


df = spark.read.option("header", "true").option("inferSchema", "true").csv('/Volumes/workspace/bronze_de/source_systems/source_erp/LOC_A101.csv', header=True)
df.write.mode("overwrite").saveAsTable("workspace.bronze.erp_loc_a101")

# COMMAND ----------

# MAGIC %md
# MAGIC ## erp_px_cat_g1v2

# COMMAND ----------

df = spark.read.option("header", "true").option("inferSchema", "true").csv('/Volumes/workspace/bronze_de/source_systems/source_erp/PX_CAT_G1V2.csv', header=True)
df.write.mode("overwrite").saveAsTable("workspace.bronze.erp_px_cat_g1v2")

# COMMAND ----------

# MAGIC %md
# MAGIC # Improved version

# COMMAND ----------


INGESTION_CONFIG = [
    {
        "source": "crm",
        "path": "/Volumes/workspace/bronze_de/source_systems/source_crm/cust_info.csv",
        "table": "crm_cust_info"
    },
    {
        "source": "crm",
        "path": "/Volumes/workspace/bronze_de/source_systems/source_crm/prd_info.csv",
        "table": "crm_prd_info"
    },
    {
        "source": "crm",
        "path": "/Volumes/workspace/bronze_de/source_systems/source_crm/sales_details.csv",
        "table": "crm_sales_details"
    },
    {
        "source": "erp",
        "path": "/Volumes/workspace/bronze_de/source_systems/source_erp/CUST_AZ12.csv",
        "table": "erp_cust_az12"
    },
    {
        "source": "erp",
        "path": "/Volumes/workspace/bronze_de/source_systems/source_erp/LOC_A101.csv",
        "table": "erp_loc_a101"
    },
    {
        "source": "erp",
        "path": "/Volumes/workspace/bronze_de/source_systems/source_erp/PX_CAT_G1V2.csv",
        "table": "erp_px_cat_g1v2"
    }
]


# COMMAND ----------

# MAGIC %md
# MAGIC ## Ingest Files into Bronze Tables

# COMMAND ----------


for item in INGESTION_CONFIG:
    print(f"Ingesting {item['source']} → workspace.bronze_de.{item['table']}")

    df = (
        spark.read
             .option("header", "true")
             .option("inferSchema", "true")
             .csv(item["path"])
    )

    (
        df.write
          .mode("overwrite")
          .option("overwriteSchema", "true")
          .format("delta")
          .saveAsTable(f"workspace.bronze_de.{item['table']}")
    )

# COMMAND ----------

# MAGIC %md
# MAGIC