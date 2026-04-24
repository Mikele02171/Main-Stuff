# Databricks notebook source
# MAGIC %run "/Resources/Databricks Building Blocks Udemy/6_Data_Engineering_with_Apache_Spark/6_Data_Engineering_with_Apache_Spark"

# COMMAND ----------

display(df_products) #Do not open data profile, or else the rest of the cells would not run.

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW product_cast AS
# MAGIC SELECT
# MAGIC   product_id,
# MAGIC   product_category_name,
# MAGIC   CAST(product_name_lenght        AS INT)   AS product_name_lenght,
# MAGIC   CAST(product_description_lenght AS INT)   AS product_description_lenght,
# MAGIC   CAST(product_photos_qty         AS INT)   AS product_photos_qty,
# MAGIC   CAST(product_weight_g           AS FLOAT) AS product_weight_g,
# MAGIC   CAST(product_length_cm          AS FLOAT) AS product_length_cm,
# MAGIC   CAST(product_height_cm          AS FLOAT) AS product_height_cm,
# MAGIC   CAST(product_width_cm           AS FLOAT) AS product_width_cm
# MAGIC FROM course_training_catalog.bronze.products;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM product_cast; --Do not open Data Profile unavaiable in the free edition.

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW products_clean AS
# MAGIC SELECT *
# MAGIC FROM product_cast
# MAGIC WHERE 
# MAGIC   product_weight_g > 0 AND product_weight_g < 10000 AND
# MAGIC   product_length_cm > 0 AND product_length_cm < 200 AND
# MAGIC   product_height_cm > 0 AND product_height_cm < 200 AND
# MAGIC   product_width_cm > 0 AND product_width_cm < 200;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM products_clean;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW p1 AS
# MAGIC SELECT
# MAGIC   product_id,
# MAGIC   COALESCE(product_category_name, "unknown_category") AS product_category_name,
# MAGIC   COALESCE(product_photos_qty, 1) AS product_photos_qty,
# MAGIC   product_name_lenght,
# MAGIC   product_description_lenght,
# MAGIC   product_weight_g, product_length_cm, product_height_cm, product_width_cm
# MAGIC FROM products_clean;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW products_filled AS
# MAGIC SELECT
# MAGIC   product_id,
# MAGIC   product_category_name,
# MAGIC   product_photos_qty,
# MAGIC   COALESCE(
# MAGIC       product_name_lenght, --product_name_length
# MAGIC       CAST(ROUND(AVG(product_name_lenght) OVER (PARTITION BY product_category_name)) AS INT)
# MAGIC   ) AS product_name_lenght,
# MAGIC   
# MAGIC   COALESCE(
# MAGIC       product_description_lenght,
# MAGIC       CAST(ROUND(AVG(product_description_lenght) OVER (PARTITION BY product_category_name)) AS INT)
# MAGIC   ) AS product_description_lenght,
# MAGIC   product_weight_g, product_length_cm, product_height_cm, product_width_cm
# MAGIC FROM p1;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Feature Engineering

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM products_filled;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW products_enriched AS
# MAGIC SELECT
# MAGIC   p.*,
# MAGIC   CAST(ROUND(p.product_length_cm * p.product_height_cm * p.product_width_cm, 2) AS DECIMAL(18, 2)) AS product_volume_cm3,
# MAGIC   CAST(ROUND(
# MAGIC     CASE WHEN(p.product_length_cm * p.product_height_cm * p.product_width_cm) > 0 THEN 
# MAGIC       p.product_weight_g / (p.product_length_cm * p.product_height_cm * p.product_width_cm)
# MAGIC       ELSE NULL END, 4) AS DECIMAL(18, 4)) AS product_density_g_per_cm3
# MAGIC FROM products_filled p;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM products_enriched; -- Do not run Data Profile

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.silver_olist.products AS
# MAGIC SELECT
# MAGIC   product_id,
# MAGIC   product_category_name,
# MAGIC   product_name_lenght,
# MAGIC   product_description_lenght,
# MAGIC   product_photos_qty,
# MAGIC   product_weight_g,
# MAGIC   product_length_cm, product_height_cm, product_width_cm,
# MAGIC   product_volume_cm3, product_density_g_per_cm3,
# MAGIC   current_timestamp() AS last_update_ts
# MAGIC FROM products_enriched;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.products;
# MAGIC
# MAGIC -- Check for missing values, inconsistences and outliers before proceeding.

# COMMAND ----------

# MAGIC %md
# MAGIC ## Quality, and Missing Data Management in Orders Table

# COMMAND ----------

display(df_orders) #Do not open Data Profile

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW v1_orders_base AS
# MAGIC SELECT * 
# MAGIC FROM course_training_catalog.bronze.orders;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW v2_orders_dates AS
# MAGIC SELECT
# MAGIC   *,
# MAGIC   TO_DATE(order_purchase_timestamp) AS purchase_date,
# MAGIC   TO_DATE(order_approved_at) AS approved_date,
# MAGIC   TO_DATE(order_delivered_carrier_date) AS carrier_date,
# MAGIC   TO_DATE(order_delivered_customer_date) AS delivered_date,
# MAGIC   TO_DATE(order_estimated_delivery_date) AS estimated_date
# MAGIC FROM v1_orders_base;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM v2_orders_dates; -- Do not open Data Profile

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW v3_orders_timeparts AS
# MAGIC SELECT
# MAGIC   *,
# MAGIC   HOUR(order_purchase_timestamp) AS purchase_hour,
# MAGIC   DAYOFWEEK(order_purchase_timestamp) AS purchase_weekday,
# MAGIC   DATE_FORMAT(order_purchase_timestamp, "E") AS purchase_weekday_name,
# MAGIC   CASE WHEN order_delivered_customer_date IS NOT NULL THEN HOUR(order_delivered_customer_date) END AS delivered_hour,
# MAGIC   CASE WHEN order_delivered_customer_date IS NOT NULL THEN DAYOFWEEK(order_delivered_customer_date) END AS delivered_weekday,
# MAGIC   CASE WHEN order_delivered_customer_date IS NOT NULL THEN DATE_FORMAT(order_delivered_customer_date, "E") END AS delivered_weekday_name
# MAGIC FROM v2_orders_dates;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM v3_orders_timeparts; --Avoid Data profile
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC ###REMINDER: In your own time to check any nulls, inconsistences and outliers before proceeding

# COMMAND ----------

# Basic stats
df_orders_timeparts = spark.table("v3_orders_timeparts")
df_orders_timeparts.describe().show()

# COMMAND ----------

# More detailed summary
df_orders_timeparts.summary().show()

# COMMAND ----------

# Check structure 
df_orders_timeparts.printSchema()

# COMMAND ----------

# Count missing values
from pyspark.sql.functions import col, sum
df_orders_timeparts.select([sum(col(c).isNull().cast("int")).alias(c) for c in df_orders_timeparts.columns]).show()

# COMMAND ----------

#Preview data
df_orders_timeparts.show()

# COMMAND ----------

# MAGIC %md
# MAGIC ### Continue where we left off.

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW v4_orders_metrics AS
# MAGIC SELECT
# MAGIC   *,
# MAGIC   DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_days,
# MAGIC   CASE WHEN order_delivered_customer_date IS NOT NULL THEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) END AS delay_days
# MAGIC
# MAGIC FROM v3_orders_timeparts;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM v4_orders_metrics;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW v4_orders_metrics AS
# MAGIC SELECT
# MAGIC   *,
# MAGIC   DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_days,
# MAGIC   CASE WHEN order_delivered_customer_date IS NOT NULL THEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) END AS delay_days
# MAGIC
# MAGIC FROM v3_orders_timeparts;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM v4_orders_metrics; --Avoid Data Profling 

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW v5_orders_dayparts AS
# MAGIC SELECT
# MAGIC   *, 
# MAGIC   CASE 
# MAGIC     WHEN purchase_hour BETWEEN 6 AND 11 THEN "morning"
# MAGIC     WHEN purchase_hour BETWEEN 12 AND 17 THEN "afternoon"
# MAGIC     WHEN purchase_hour BETWEEN 18 AND 22 THEN "evening"
# MAGIC     ELSE "night"
# MAGIC   END AS purchase_part_of_day,
# MAGIC   CASE WHEN purchase_weekday IN(1, 7) THEN TRUE ELSE FALSE END AS is_weekend_purchase
# MAGIC
# MAGIC FROM v4_orders_metrics;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM v5_orders_dayparts;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW v6_orders_status AS
# MAGIC SELECT
# MAGIC   *,
# MAGIC   LOWER(TRIM(order_status)) AS order_status_norm,
# MAGIC   CASE 
# MAGIC     WHEN LOWER(TRIM(order_status)) IN ("delivered", "invoiced") THEN "completed"
# MAGIC     WHEN LOWER(TRIM(order_status)) IN ("canceled", "unavaliable") THEN "canceled"
# MAGIC     ELSE "pending"
# MAGIC   END AS order_status_group
# MAGIC
# MAGIC FROM v5_orders_dayparts;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM v6_orders_status;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW v7_orders_quality AS
# MAGIC SELECT
# MAGIC   *,
# MAGIC   (
# MAGIC     (order_approved_at              < order_purchase_timestamp) OR
# MAGIC     (order_delivered_carrier_date   < order_approved_at) OR
# MAGIC     (order_delivered_customer_date  < order_delivered_carrier_date)
# MAGIC   ) AS is_invalid_timeflow
# MAGIC FROM v6_orders_status;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM v7_orders_quality; --Avoid Data Profile 

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.silver_olist.orders AS
# MAGIC SELECT
# MAGIC   order_id,
# MAGIC   customer_id,
# MAGIC   order_status_group,
# MAGIC   order_purchase_timestamp,
# MAGIC   order_delivered_customer_date,
# MAGIC   purchase_date,
# MAGIC   approved_date,
# MAGIC   carrier_date,
# MAGIC   delivered_date,
# MAGIC   estimated_date,
# MAGIC   purchase_hour,
# MAGIC   delivered_hour,
# MAGIC   purchase_weekday_name,
# MAGIC   delivered_weekday_name,
# MAGIC   delivery_days,
# MAGIC   delay_days,
# MAGIC   purchase_part_of_day,
# MAGIC   is_weekend_purchase,
# MAGIC   is_invalid_timeflow
# MAGIC FROM v7_orders_quality;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.orders; -- Avoid Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.silver_olist.orders AS
# MAGIC SELECT
# MAGIC   *,
# MAGIC   CASE WHEN order_delivered_customer_date IS NULL THEN TRUE ELSE FALSE END AS is_missing_customer_date,
# MAGIC   CASE WHEN carrier_date IS NULL THEN TRUE ELSE FALSE END AS is_missing_carrier_date,
# MAGIC   CASE WHEN approved_date IS NULL THEN TRUE ELSE FALSE END AS is_missing_approved
# MAGIC
# MAGIC FROM course_training_catalog.silver_olist.orders;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.orders;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Order_Items Data Transformation and Quality Checks

# COMMAND ----------

display(df_items) #Avoid Data profiling

# COMMAND ----------

from pyspark.sql import functions as F, Window

CATALOG = "course_training_catalog"
SILVER = "silver_olist"
TGT_TABLE = f"{CATALOG}.{SILVER}.order_items"

# COMMAND ----------

df_base = (
    df_items
    .select(
        F.trim("order_id").alias("order_id"),
        F.col("order_item_id").cast("int").alias("order_item_id"),
        F.trim("product_id").alias("product_id"),
        F.trim("seller_id").alias("seller_id"),
        F.to_timestamp("shipping_limit_date").alias("shipping_limit_date"),
        F.col("price").cast("double").alias("price"),
        F.col("freight_value").cast("double").alias("freight_value")
        )
)

display(df_base.limit(5))

# COMMAND ----------

w = Window.partitionBy("order_id", "order_item_id") \
    .orderBy(F.col("shipping_limit_date").desc_nulls_last(), F.col("price").desc_nulls_last())



df_nodup = (
    df_base
    .withColumn("rn", F.row_number().over(w))
    .where(F.col("rn") == 1)
    .drop("rn")
)


# COMMAND ----------

display(df_nodup) #No Data Profiling

# COMMAND ----------

df_flagged = (
    df_nodup
    .withColumn("is_price_nonpositive", F.col("price") <= 0)
    .withColumn("is_freight_negative", F.col("freight_value") < 0)
    .withColumn(
        "is_ship_date_outlier",
        (F.year("shipping_limit_date") < F.lit(2017)) | (F.year("shipping_limit_date") > F.lit(2019))
    )
)

# COMMAND ----------

display(df_flagged) #No Data Profiling

# COMMAND ----------

df_silver = (
    df_flagged
    .withColumn("total_item_value", F.round(F.col("price") + F.col("freight_value"), 2))
    .withColumn(
        "freight_ratio",
        F.when(F.col("price") > 0, F.round(F.col("freight_value") / F.col("price"), 3))
        .otherwise(F.lit(None))    
    )
    .withColumn("ship_year", F.year("shipping_limit_date"))
    .withColumn("ship_month", F.month("shipping_limit_date"))
    .withColumn("ship_day", F.dayofmonth("shipping_limit_date"))
)

# COMMAND ----------

display(df_silver) #No Data Profling

# COMMAND ----------

(df_silver.write
    .mode("overwrite")
    .format("delta")
    .saveAsTable(TGT_TABLE)
)

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.order_items; --No Data Profiling