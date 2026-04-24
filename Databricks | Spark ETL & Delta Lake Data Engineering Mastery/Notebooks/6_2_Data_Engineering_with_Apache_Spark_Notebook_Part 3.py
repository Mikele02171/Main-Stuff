# Databricks notebook source
# MAGIC %md
# MAGIC ## Payments Data Validation and Transformation

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.bronze.order_payments;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT 
# MAGIC   COUNT(*) AS total_rows,
# MAGIC   SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS n_null_order_id,
# MAGIC   SUM(CASE WHEN payment_sequential    IS NULL THEN 1 ELSE 0 END) AS n_null_payment_sequential,
# MAGIC   SUM(CASE WHEN payment_type          IS NULL THEN 1 ELSE 0 END) AS n_null_payment_type,
# MAGIC   SUM(CASE WHEN payment_installments  IS NULL THEN 1 ELSE 0 END) AS n_null_payment_installments,
# MAGIC   SUM(CASE WHEN payment_value         IS NULL THEN 1 ELSE 0 END) AS n_null_payment_value
# MAGIC
# MAGIC FROM course_training_catalog.bronze.order_payments;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Duplicate records
# MAGIC SELECT order_id, payment_sequential, COUNT(*) AS cnt
# MAGIC FROM course_training_catalog.bronze.order_payments
# MAGIC GROUP BY order_id, payment_sequential
# MAGIC HAVING COUNT(*) > 1
# MAGIC ORDER BY cnt DESC;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW payments_norm AS
# MAGIC SELECT
# MAGIC   order_id,
# MAGIC   TRY_CAST(payment_sequential AS INT) AS payment_sequential,
# MAGIC   LOWER(TRIM(payment_type)) AS payment_type,
# MAGIC   TRY_CAST(payment_installments AS INT) AS payment_installments,
# MAGIC   CAST(ROUND(TRY_CAST(payment_value AS DOUBLE), 2) AS DECIMAL(18, 2)) AS payment_value
# MAGIC
# MAGIC FROM course_training_catalog.bronze.order_payments;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM payments_norm;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW payments_flagged AS
# MAGIC SELECT
# MAGIC   *,
# MAGIC   CASE WHEN payment_installments > 0 AND payment_value IS NOT NULL
# MAGIC   THEN ROUND(payment_value / payment_installments, 2)
# MAGIC   ELSE NULL END AS payment_per_installment
# MAGIC   FROM payments_norm;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM payments_flagged; --No Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.silver_olist.order_payments
# MAGIC USING DELTA
# MAGIC AS
# MAGIC SELECT
# MAGIC   order_id,
# MAGIC   payment_sequential,
# MAGIC   payment_type,
# MAGIC   payment_installments,
# MAGIC   payment_value,
# MAGIC   payment_per_installment
# MAGIC
# MAGIC FROM payments_flagged;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.order_payments;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Building the Silver Version of Order_Reviews Data 

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.bronze.order_reviews;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW reviews_stage AS
# MAGIC SELECT
# MAGIC   TRIM(review_id) AS review_id,
# MAGIC   TRIM(order_id) AS order_id,
# MAGIC
# MAGIC   TRY_CAST(review_score AS INT) AS review_score,
# MAGIC
# MAGIC   review_creation_date AS review_creation_str,
# MAGIC   review_answer_timestamp AS review_answer_str,
# MAGIC
# MAGIC   TRY_CAST(review_creation_date    AS TIMESTAMP) AS review_creation_ts,
# MAGIC   TRY_CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_ts,
# MAGIC
# MAGIC   REGEXP_REPLACE(TRIM(review_comment_title), '\\s+', ' ') AS review_comment_title,
# MAGIC   REGEXP_REPLACE(TRIM(review_comment_message), '\\s+', ' ') AS review_comment_message
# MAGIC
# MAGIC FROM course_training_catalog.bronze.order_reviews;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM reviews_stage; --Avoid Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.silver_olist._reviews_bad_rows AS
# MAGIC SELECT
# MAGIC   *
# MAGIC FROM reviews_stage
# MAGIC WHERE review_id IS NULL
# MAGIC   OR review_score IS NULL
# MAGIC   OR (review_creation_ts IS NULL AND COALESCE(TRIM(review_creation_str), '') <> '')
# MAGIC   OR (review_answer_ts IS NULL AND COALESCE(TRIM(review_answer_ts), '') <> '');

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist._reviews_bad_rows;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW reviews_valid_dedup AS
# MAGIC SELECT *
# MAGIC FROM (
# MAGIC   SELECT
# MAGIC     s.*,
# MAGIC     ROW_NUMBER() OVER(
# MAGIC       PARTITION BY s.review_id
# MAGIC       ORDER BY s.review_answer_ts DESC NULLS LAST, s.review_creation_ts DESC NULLS LAST
# MAGIC     ) AS rn
# MAGIC   FROM reviews_stage s
# MAGIC   WHERE s.review_id IS NOT NULL AND s.review_score BETWEEN 1 AND 5
# MAGIC ) t
# MAGIC WHERE rn = 1;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM reviews_valid_dedup; --Avoid Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW reviews_enriched AS
# MAGIC SELECT
# MAGIC   review_id,
# MAGIC   order_id,
# MAGIC   review_score,
# MAGIC   review_creation_ts,
# MAGIC   review_answer_ts,
# MAGIC   CASE 
# MAGIC     WHEN review_comment_title IS NULL AND review_comment_message IS NOT NULL THEN SUBSTRING(review_comment_message, 1, 50)
# MAGIC     ELSE review_comment_title
# MAGIC   END AS review_comment_title,
# MAGIC
# MAGIC   CASE WHEN review_comment_title IS NULL AND review_comment_message IS NULL THEN TRUE ELSE FALSE END AS is_missing_comment,
# MAGIC
# MAGIC   CASE WHEN review_comment_title IS NOT NULL AND review_comment_message IS NULL THEN TRUE ELSE FALSE END AS has_title_only,
# MAGIC
# MAGIC   CASE WHEN review_comment_title IS NULL AND review_comment_message IS NOT NULL THEN TRUE ELSE FALSE END AS has_message_only
# MAGIC
# MAGIC FROM reviews_valid_dedup;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM reviews_enriched; --No Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.silver_olist.order_reviews AS
# MAGIC SELECT *
# MAGIC FROM reviews_enriched;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.order_reviews; -- Avoid Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC COMMENT ON TABLE course_training_catalog.silver_olist.order_reviews IS
# MAGIC   'Order reviews (Silver): typed, deduplicated, normalized, with quality flags. 1 row = 1 review_id'

# COMMAND ----------

# MAGIC %sql
# MAGIC COMMENT ON COLUMN course_training_catalog.silver_olist.order_reviews.review_score IS
# MAGIC   'Customer rating (1..5)';

# COMMAND ----------

# MAGIC %sql
# MAGIC ALTER TABLE course_training_catalog.silver_olist.order_reviews
# MAGIC ADD CONSTRAINT chk_review_score_1_5 CHECK (review_score BETWEEN 1 AND 5);

# COMMAND ----------

# MAGIC %sql
# MAGIC USE CATALOG course_training_catalog;

# COMMAND ----------

# MAGIC %sql
# MAGIC DESCRIBE EXTENDED silver_olist.order_reviews;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.bronze.geolocation; --No Data Profiling

# COMMAND ----------

geo_base = spark.table("course_training_catalog.bronze.geolocation")
geo_base.createOrReplaceTempView("geo_base")

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM geo_base;

# COMMAND ----------

from pyspark.sql import functions as F

geo_typed = (geo_base
    .withColumn("zip_prefix", F.col("geolocation_zip_code_prefix").cast("int"))
    .withColumn("lat",        F.col("geolocation_lat").cast("double"))
    .withColumn("lng",        F.col("geolocation_lng").cast("double"))
    .withColumnRenamed("geolocation_city", "city_raw")
    .withColumnRenamed("geolocation_state", "state_raw")
)

geo_typed.createOrReplaceTempView("geo_typed")

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM geo_typed; --No Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW geo_norm AS
# MAGIC SELECT
# MAGIC   zip_prefix,
# MAGIC   lat, lng,
# MAGIC   lower(
# MAGIC     regexp_replace(
# MAGIC       translate(trim(regexp_replace(city_raw, '\\s+', ' ')),
# MAGIC         'áàãâäéèêëíìîïóòõôöúùûüçñýÿÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇÑÝ',
# MAGIC         'aaaaaeeeeiiiiooooouuuucnyyAAAAAEEEEIIIIOOOOOUUUUCNY'
# MAGIC         ),
# MAGIC         '[^a-z ]', ''
# MAGIC     )
# MAGIC   ) AS city_lc,
# MAGIC   upper(trim(regexp_replace(state_raw, '\\s+', ' '))) AS state_uc
# MAGIC FROM geo_typed;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM geo_norm; -- No Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT COUNT(*) AS total_rows,
# MAGIC   COUNT(DISTINCT zip_prefix) AS distinct_zip
# MAGIC FROM geo_norm;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT zip_prefix, COUNT(*) AS n
# MAGIC FROM geo_norm
# MAGIC GROUP BY zip_prefix
# MAGIC ORDER BY n DESC
# MAGIC LIMIT 10;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW mode_city AS 
# MAGIC SELECT 
# MAGIC   zip_prefix,
# MAGIC   city_lc AS city,
# MAGIC   state_uc AS state
# MAGIC FROM (
# MAGIC   SELECT
# MAGIC     zip_prefix,
# MAGIC     city_lc,
# MAGIC     state_uc,
# MAGIC     COUNT(*) AS c,
# MAGIC     ROW_NUMBER() OVER(
# MAGIC       PARTITION BY zip_prefix
# MAGIC       ORDER BY COUNT(*) DESC, city_lc ASC
# MAGIC     ) AS rn
# MAGIC   FROM geo_norm
# MAGIC   GROUP BY zip_prefix, city_lc, state_uc
# MAGIC )
# MAGIC WHERE rn = 1;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM mode_city; --No Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT COUNT(*) AS total_rows,
# MAGIC   COUNT(DISTINCT zip_prefix) AS distinct_zip
# MAGIC FROM mode_city;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT zip_prefix, COUNT(*) AS n
# MAGIC FROM mode_city
# MAGIC GROUP BY zip_prefix
# MAGIC ORDER BY n DESC
# MAGIC LIMIT 10;
# MAGIC
# MAGIC --Check duplication for zipcodes

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW centroids AS
# MAGIC SELECT
# MAGIC   zip_prefix,
# MAGIC   AVG(lat) AS lat,
# MAGIC   AVG(lng) AS lng
# MAGIC
# MAGIC FROM geo_norm
# MAGIC GROUP BY zip_prefix;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM centroids;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW geo_dedup AS
# MAGIC SELECT
# MAGIC   c.zip_prefix,
# MAGIC   c.lat,
# MAGIC   c.lng,
# MAGIC   m.city,
# MAGIC   m.state
# MAGIC FROM centroids c
# MAGIC JOIN mode_city m USING (zip_prefix);

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM geo_dedup; -- No Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.silver_olist.geolocation AS
# MAGIC SELECT
# MAGIC   zip_prefix AS geolocation_zip_code_prefix,
# MAGIC   ROUND(lat, 6) AS geolocation_lat,
# MAGIC   ROUND(lng, 6) AS geolocation_lng,
# MAGIC   city AS geolocation_city,
# MAGIC   state AS geolocation_state
# MAGIC FROM geo_dedup;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.geolocation;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Clean Reference Tables in the Silver Layer: product_category_name_translation Table

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.bronze.product_category_name_translation; --No Data Profling

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.silver_olist.category_lookup AS
# MAGIC SELECT 
# MAGIC   product_category_name AS category_pt,
# MAGIC   product_category_name_english AS category_en
# MAGIC FROM course_training_catalog.bronze.product_category_name_translation;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.category_lookup; --No Data Profling