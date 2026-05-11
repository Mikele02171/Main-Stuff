# Databricks notebook source
# MAGIC %md
# MAGIC #Define Ingestion Configuration

# COMMAND ----------

INGESTION_CONFIG = [
    {
        "source": "crm",
        "path": "/Volumes/workspace/bronze/raw_sources/source_crm/cust_info.csv",
        "table": "crm_cust_info"
    },
    {
        "source": "crm",
        "path": "/Volumes/workspace/bronze/raw_sources/source_crm/prd_info.csv",
        "table": "crm_prd_info"
    },
    {
        "source": "crm",
        "path": "/Volumes/workspace/bronze/raw_sources/source_crm/sales_details.csv",
        "table": "crm_sales_details"
    },
    {
        "source": "erp",
        "path": "/Volumes/workspace/bronze/raw_sources/source_erp/CUST_AZ12.csv",
        "table": "erp_cust_az12"
    },
    {
        "source": "erp",
        "path": "/Volumes/workspace/bronze/raw_sources/source_erp/LOC_A101.csv",
        "table": "erp_loc_a101"
    },
    {
        "source": "erp",
        "path": "/Volumes/workspace/bronze/raw_sources/source_erp/PX_CAT_G1V2.csv",
        "table": "erp_px_cat_g1v2"
    }
]


# COMMAND ----------

# MAGIC %md
# MAGIC #Ingest Files into Bronze Tables

# COMMAND ----------


for item in INGESTION_CONFIG:
    print(f"Ingesting {item['source']} → workspace.bronze.{item['table']}")

    df = (
        spark.read
             .option("header", "true")
             .option("inferSchema", "true")
             .csv(item["path"])
    )

    (
        df.write
          .mode("overwrite")
          .format("delta")
          .saveAsTable(f"workspace.bronze.{item['table']}")
    )