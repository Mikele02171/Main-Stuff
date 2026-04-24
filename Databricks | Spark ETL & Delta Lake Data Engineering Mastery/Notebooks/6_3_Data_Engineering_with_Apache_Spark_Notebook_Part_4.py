# Databricks notebook source
# MAGIC %md
# MAGIC ## Customer Distribution Analysis – Gold Layer

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.customers; -- No Data Profiling (Preparation becomes a product)

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT customer_state AS state,
# MAGIC        COUNT(DISTINCT customer_city) AS distinct_cities
# MAGIC
# MAGIC FROM course_training_catalog.silver_olist.customers
# MAGIC GROUP BY state
# MAGIC ORDER BY distinct_cities DESC
# MAGIC LIMIT 5;

# COMMAND ----------

# MAGIC %sql
# MAGIC
# MAGIC --NOTE: Inside the Catalog inside the course_training_catelog you must create gold_olist schema before proceeding.
# MAGIC --Then refresh the Gold Schema. 
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.gold_olist.Customer_Top_5_States_by_City_Diversity AS
# MAGIC SELECT customer_state AS state,
# MAGIC        COUNT(DISTINCT customer_city) AS distinct_cities
# MAGIC
# MAGIC FROM course_training_catalog.silver_olist.customers
# MAGIC GROUP BY state
# MAGIC ORDER BY distinct_cities DESC
# MAGIC LIMIT 5;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Number of Distinct Cities by State

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.customer_top_5_states_by_city_diversity; 

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW customer_diversity_with_top_city AS
# MAGIC WITH city_counts AS(
# MAGIC   SELECT
# MAGIC     customer_state AS state,
# MAGIC     customer_city AS city,
# MAGIC     COUNT(*) AS customer_count
# MAGIC   FROM
# MAGIC     course_training_catalog.silver_olist.customers
# MAGIC   GROUP BY
# MAGIC     state,
# MAGIC     city
# MAGIC ),
# MAGIC ranked AS(
# MAGIC   SELECT
# MAGIC     state,
# MAGIC     city,
# MAGIC     customer_count,
# MAGIC     ROW_NUMBER() OVER(PARTITION BY state ORDER BY customer_count DESC) AS rn
# MAGIC   FROM
# MAGIC     city_counts
# MAGIC ),
# MAGIC state_summary AS(
# MAGIC   SELECT
# MAGIC     state,
# MAGIC     COUNT(DISTINCT city) AS distinct_cities,
# MAGIC     SUM(customer_count) AS total_customers,
# MAGIC     ROUND(AVG(customer_count), 2) AS avg_customers_per_city
# MAGIC   FROM city_counts
# MAGIC   GROUP BY
# MAGIC     state
# MAGIC )
# MAGIC SELECT
# MAGIC   s.state,
# MAGIC   s.distinct_cities,
# MAGIC   s.total_customers,
# MAGIC   s.avg_customers_per_city,
# MAGIC   r.city AS top_city,
# MAGIC   r.customer_count AS top_city_customers
# MAGIC FROM state_summary s
# MAGIC JOIN ranked r
# MAGIC   ON s.state = r.state AND r.rn == 1
# MAGIC ORDER BY s.total_customers DESC;
# MAGIC
# MAGIC
# MAGIC SELECT * FROM customer_diversity_with_top_city;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.gold_olist.customer_distribution_by_state AS
# MAGIC SELECT * FROM customer_diversity_with_top_city;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.customer_distribution_by_state;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Seller Metrics and Pareto Visualization in Databricks

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.sellers; -- No Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TEMP VIEW seller_clean AS
# MAGIC SELECT
# MAGIC   INITCAP(seller_city) AS city_display,
# MAGIC   UPPER(seller_state) AS state_code
# MAGIC FROM
# MAGIC   course_training_catalog.silver_olist.sellers
# MAGIC WHERE seller_id IS NOT NULL;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM seller_clean;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.gold_olist.seller_city_stats AS
# MAGIC WITH city_counts AS(
# MAGIC   SELECT
# MAGIC     city_display,
# MAGIC     state_code,
# MAGIC     COUNT(*) AS seller_count
# MAGIC     FROM
# MAGIC       seller_clean
# MAGIC     GROUP BY 
# MAGIC       city_display,
# MAGIC       state_code
# MAGIC ),
# MAGIC ranked AS(
# MAGIC   SELECT
# MAGIC     city_display,
# MAGIC     state_code,
# MAGIC     seller_count,
# MAGIC     DENSE_RANK() OVER(ORDER BY seller_count DESC, city_display) AS rnk,
# MAGIC     SUM(seller_count) OVER() AS total_all,
# MAGIC     SUM(seller_count) OVER(ORDER BY seller_count DESC, city_display ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_sellers --cumulative sellers
# MAGIC   FROM
# MAGIC     city_counts
# MAGIC )
# MAGIC SELECT
# MAGIC   city_display,
# MAGIC   state_code,
# MAGIC   seller_count,
# MAGIC   rnk,
# MAGIC   ROUND(cum_sellers / total_all, 3) AS cum_share
# MAGIC FROM
# MAGIC   ranked;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.seller_city_stats; -- No Data Profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.seller_city_stats
# MAGIC WHERE rnk <= 20
# MAGIC ORDER BY rnk;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Analyzing Product Categories by Weight, Volume and Density

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.products; --No Data Profiling

# COMMAND ----------

from pyspark.sql import functions as F

df_products = spark.table("course_training_catalog.silver_olist.products")

df_summary = (
    df_products
    .groupBy("product_category_name")
    .agg(
        F.round(F.avg("product_weight_g"), 2).alias("avg_weight_g"),
        F.round(F.avg("product_length_cm"), 2).alias("avg_length_cm"),
        F.round(F.avg("product_height_cm"), 2).alias("avg_height_cm"),
        F.round(F.avg("product_width_cm"), 2).alias("avg_width_cm"),
        F.round(F.avg("product_volume_cm3"), 2).alias("avg_volume_cm3"),
        F.round(F.avg(F.col("product_weight_g") / F.col("product_volume_cm3")), 3).alias("avg_density")
    )
    .filter(F.col("product_category_name").isNotNull())
    .orderBy(F.desc("avg_weight_g"))
)

# COMMAND ----------

display(df_summary) #No Data Profiling

# COMMAND ----------

df_summary.write.mode("overwrite").format("delta") \
    .saveAsTable("course_training_catalog.gold_olist.product_category_summary")

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.product_category_summary; --No data profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.category_lookup;

# COMMAND ----------

df = (
    spark.table("course_training_catalog.gold_olist.product_category_summary").alias("p")
    .join(spark.table("course_training_catalog.silver_olist.category_lookup").alias("l"),
          F.col("p.product_category_name") == F.col("l.category_pt"), "left")
    .selectExpr(
        "p.product_category_name AS category_pt",
        "COALESCE(l.category_en, p.product_category_name) AS category_en",
        "initcap(regexp_replace(COALESCE(l.category_en, p.product_category_name), '_', ' ')) AS category_en_display",
        "avg_weight_g","avg_length_cm","avg_height_cm","avg_width_cm","avg_volume_cm3","avg_density"
    )
)

# COMMAND ----------

df.write.mode("overwrite").format("delta") \
    .saveAsTable("course_training_catalog.gold_olist.product_category_summary_en")

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.product_category_summary_en;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.product_category_summary_en
# MAGIC ORDER BY avg_weight_g DESC
# MAGIC LIMIT 15;
# MAGIC
# MAGIC --Top 15 Rows ordered by avg_weight_g

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.product_category_summary_en
# MAGIC ORDER BY avg_weight_g DESC
# MAGIC LIMIT 25;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.product_category_summary_en
# MAGIC ORDER BY avg_weight_g DESC
# MAGIC LIMIT 15;

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1️⃣ order_items — Product and Item-Level Analysis

# COMMAND ----------

# MAGIC %md
# MAGIC * This table contains details of each product within an order, including price and shipping cost.
# MAGIC * Even on its own, it provides rich commercial insights.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.order_items; --No Data Profiling

# COMMAND ----------

# MAGIC %md
# MAGIC **1.1. Average Product Price and Freight Cost**
# MAGIC
# MAGIC * Calculate the average `price` and `freight_value` per order item.
# MAGIC * Analyze cost distribution across different product types.
# MAGIC
# MAGIC **1.2. Freight Ratio Analysis**
# MAGIC
# MAGIC * Compute `freight_value / price` to identify products with disproportionately high shipping costs.
# MAGIC
# MAGIC **1.3. Total Item Value (Per Order Line)**
# MAGIC
# MAGIC * Use `total_item_value = price + freight_value` to measure the average transaction value per product.
# MAGIC
# MAGIC **1.4. Time-Based Shipping Trends**
# MAGIC
# MAGIC * Use `shipping_limit_date` to build daily, monthly, or yearly shipping trend visualizations.
# MAGIC
# MAGIC ---
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC ## 2️⃣ order_payments — Financial Transactions and Payment Behavior
# MAGIC * This dataset records payment methods, installment counts, and payment amounts — perfect for financial behavior analysis.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.order_payments; --No Data Profiling 

# COMMAND ----------

# MAGIC %md
# MAGIC ## 3️⃣ order_reviews — Customer Feedback and Sentiment Analysis
# MAGIC
# MAGIC This table contains customer ratings and textual reviews, enabling analysis of satisfaction and quality trends.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.order_reviews; -- No Data Profiling

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC **3.1. Average Review Score Distribution**
# MAGIC
# MAGIC * Calculate the percentage of each score (1–5) to assess overall satisfaction.
# MAGIC
# MAGIC **3.2. Sentiment Distribution (Positive vs Negative)**
# MAGIC
# MAGIC * Classify 4–5 stars as “positive” and 1–2 stars as “negative” to analyze sentiment balance.
# MAGIC
# MAGIC **3.3. Missing Comment Ratio**
# MAGIC
# MAGIC * Determine how many customers gave a rating without writing a comment — a proxy for engagement quality.
# MAGIC
# MAGIC **3.4. Title-Only Reviews**
# MAGIC
# MAGIC * Identify reviews containing only a title to measure short-form feedback frequency.
# MAGIC
# MAGIC **3.5. Review Timing Analysis**
# MAGIC
# MAGIC * Analyze `review_creation_date` to understand how quickly customers provide feedback after purchase.
# MAGIC

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC ## **4️⃣ geolocation — Geographic Data Analysis**
# MAGIC
# MAGIC This table stores coordinates and zip prefixes, making it ideal for regional coverage and quality assessment.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.geolocation; --No Data Profiling

# COMMAND ----------

# MAGIC %md
# MAGIC **4.1. Zip Code Density Analysis**
# MAGIC
# MAGIC * Count the number of records per `zip_prefix` to identify geographic concentration areas.
# MAGIC
# MAGIC **4.2. Geographic Centroid Validation**
# MAGIC
# MAGIC * Use average `lat` and `lng` to determine the representative geographic center for each region.
# MAGIC * This helps verify data consistency and detect outliers.
# MAGIC
# MAGIC ---

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC ## 5️⃣ _reviews_bad_rows — Data Quality and Error Audit
# MAGIC
# MAGIC This quarantine table contains invalid or malformed records excluded from the main dataset.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist._reviews_bad_rows; --No Data Profiling

# COMMAND ----------

# MAGIC %md
# MAGIC
# MAGIC **5.1. Error Row Ratio**
# MAGIC
# MAGIC * Measure the proportion of invalid rows relative to the total dataset — a key data quality metric.
# MAGIC
# MAGIC **5.2. Error Type Distribution**
# MAGIC
# MAGIC * Identify which columns most frequently cause errors (e.g., incorrect date or text types).
# MAGIC
# MAGIC **5.3. Missing Field Analysis**
# MAGIC
# MAGIC * Determine which columns have the highest proportion of null or empty values.
# MAGIC
# MAGIC **5.4. Fixable Error Ratio**
# MAGIC
# MAGIC * Measure how many errors could be corrected automatically (e.g., format or null-related).
# MAGIC ---

# COMMAND ----------

# MAGIC %md
# MAGIC ## **6️⃣ orders — Order Lifecycle and Performance Analysis**
# MAGIC
# MAGIC This dataset captures the entire order process — from purchase to delivery.
# MAGIC It’s ideal for time, completeness, and performance-based analytics.

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.silver_olist.orders; --No Data Profiling

# COMMAND ----------

# MAGIC %md
# MAGIC **6.1. Order Status Breakdown**
# MAGIC
# MAGIC * Group by `order_status` to measure completed, canceled, and pending order ratios.
# MAGIC * Pie or bar chart → visualize operational success rates.
# MAGIC
# MAGIC **6.2. Time-of-Day Purchase Analysis**
# MAGIC
# MAGIC * Use `purchase_hour` or `purchase_day_of_week` to identify when customers shop most frequently.
# MAGIC
# MAGIC **6.3. Weekend Purchase Behavior**
# MAGIC
# MAGIC * Analyze `is_weekend_purchase` to compare weekday vs weekend order patterns.
# MAGIC
# MAGIC **6.4. Timeflow Integrity Check**
# MAGIC
# MAGIC * Use `is_invalid_timeflow` to detect temporal inconsistencies (e.g., delivery before approval).
# MAGIC
# MAGIC **6.5. Missing Date Completeness Analysis**
# MAGIC
# MAGIC * Analyze `is_missing_customer_date`, `is_missing_carrier_date`, and `is_missing_approved`
# MAGIC   to see where data is most often incomplete.
# MAGIC
# MAGIC **6.6. Monthly Order Trends (Seasonality)**
# MAGIC
# MAGIC * Use `purchase_date` or `approved_date` to build time-series visualizations of order volumes.
# MAGIC
# MAGIC **6.7. Estimated Delivery Benchmark**
# MAGIC
# MAGIC * Compare actual vs. estimated delivery dates to evaluate forecast accuracy.

# COMMAND ----------

# MAGIC %md
# MAGIC ## Unified Order Gold Analytics 

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE course_training_catalog.gold_olist.order_performance AS
# MAGIC WITH
# MAGIC item_summary AS (
# MAGIC   SELECT
# MAGIC     order_id,
# MAGIC     ROUND(SUM(price + freight_value), 2) AS order_value,
# MAGIC     COUNT(*) AS item_count
# MAGIC   FROM course_training_catalog.silver_olist.order_items
# MAGIC   GROUP BY order_id
# MAGIC ),
# MAGIC payment_summary AS (
# MAGIC   SELECT
# MAGIC     order_id,
# MAGIC     FIRST(payment_type) AS payment_type,
# MAGIC     ROUND(SUM(payment_value), 2) total_payment,
# MAGIC     AVG(NULLIF(payment_installments, 0)) AS avg_installments
# MAGIC   FROM course_training_catalog.silver_olist.order_payments
# MAGIC   GROUP BY order_id
# MAGIC ),
# MAGIC reviews_summary AS (
# MAGIC   SELECT
# MAGIC     order_id,
# MAGIC     ROUND(AVG(review_score), 2) AS avg_review_score,
# MAGIC     COUNT(*) AS review_count
# MAGIC   FROM course_training_catalog.silver_olist.order_reviews
# MAGIC   GROUP BY order_id
# MAGIC )
# MAGIC SELECT
# MAGIC   o.order_id,
# MAGIC   DATE(o.order_purchase_timestamp) AS purchase_date,
# MAGIC   o.order_status_group,
# MAGIC   o.delivery_days,
# MAGIC   o.delay_days,
# MAGIC   i.order_value,
# MAGIC   i.item_count,
# MAGIC   p.payment_type,
# MAGIC   p.total_payment,
# MAGIC   ROUND(p.avg_installments, 2) AS avg_installments,
# MAGIC   r.avg_review_score
# MAGIC
# MAGIC FROM course_training_catalog.silver_olist.orders AS o
# MAGIC LEFT JOIN item_summary AS i ON o.order_id = i.order_id
# MAGIC LEFT JOIN payment_summary AS p ON o.order_id = p.order_id
# MAGIC LEFT JOIN reviews_summary AS r ON o.order_id = r.order_id 

# COMMAND ----------

# MAGIC %md
# MAGIC #### Always to note when running SQL queries or viewing the dataset do not show data profiling

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.gold_olist.order_performance;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT
# MAGIC   ROUND(AVG(order_value), 2) AS avg_order_value
# MAGIC FROM course_training_catalog.gold_olist.order_performance;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE SCHEMA IF NOT EXISTS course_training_catalog.analytics_fn;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE FUNCTION course_training_catalog.analytics_fn.avg_order_value()
# MAGIC RETURNS DOUBLE
# MAGIC RETURN (
# MAGIC   SELECT
# MAGIC   ROUND(AVG(order_value), 2) AS avg_order_value
# MAGIC FROM course_training_catalog.gold_olist.order_performance
# MAGIC );

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT course_training_catalog.analytics_fn.avg_order_value();

# COMMAND ----------

## Now running into Python (PySpark)
from pyspark.sql import functions as F

def avg_order_value2():
    df = spark.table("course_training_catalog.gold_olist.order_performance")

    result = (
        df.agg(F.round(F.avg("order_value"), 2).alias("avg_order_value"))
        .collect()[0]["avg_order_value"]
    )

    return result

# COMMAND ----------

print(avg_order_value2())

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE FUNCTION course_training_catalog.analytics_fn.fn_order_performance_summary(
# MAGIC   payment_filter STRING,
# MAGIC   min_order_value DOUBLE,
# MAGIC   max_delivery_days INT
# MAGIC )
# MAGIC RETURNS TABLE(
# MAGIC   payment_type STRING,
# MAGIC   order_count BIGINT,
# MAGIC   avg_order_value DOUBLE,
# MAGIC   avg_review DOUBLE,
# MAGIC   avg_delivery_days DOUBLE
# MAGIC )
# MAGIC RETURN
# MAGIC SELECT
# MAGIC   payment_type,
# MAGIC   COUNT(*) AS order_count,
# MAGIC   ROUND(AVG(order_value), 2) AS avg_order_value,
# MAGIC   ROUND(AVG(avg_review_score), 2) AS avg_review,
# MAGIC   ROUND(AVG(delivery_days), 2) AS avg_delivery_days
# MAGIC
# MAGIC FROM course_training_catalog.gold_olist.order_performance
# MAGIC WHERE
# MAGIC   (payment_filter IS NULL OR payment_type = payment_filter)
# MAGIC     AND (min_order_value IS NULL OR order_value >= min_order_value)
# MAGIC     AND (max_delivery_days IS NULL OR delivery_days <= max_delivery_days)
# MAGIC
# MAGIC GROUP BY payment_type
# MAGIC ORDER BY order_count DESC;

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.analytics_fn.fn_order_performance_summary(NULL, NULL, NULL);

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * FROM course_training_catalog.analytics_fn.fn_order_performance_summary("credit_card", 100, 5);

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT
# MAGIC   CASE 
# MAGIC     WHEN delivery_days <= 3 THEN "0-3 day"
# MAGIC     WHEN delivery_days BETWEEN 4 AND 7 THEN '4-7 day'
# MAGIC     WHEN delivery_days BETWEEN 8 AND 14 THEN '8-14 day'
# MAGIC     ELSE '15+ day'
# MAGIC   END AS delivey_speed,
# MAGIC   COUNT(*) AS orders,
# MAGIC   ROUND(AVG(order_value), 2) AS avg_value,
# MAGIC   ROUND(AVG(avg_review_score), 2) AS avg_review
# MAGIC FROM course_training_catalog.gold_olist.order_performance
# MAGIC WHERE avg_review_score IS NOT NULL
# MAGIC GROUP BY 1
# MAGIC ORDER BY orders DESC;

# COMMAND ----------

# MAGIC %md
# MAGIC ## Designing Analytical Joins in the Gold Layer

# COMMAND ----------

# MAGIC %md
# MAGIC ## **1️⃣ Customer-Centric Joins**
# MAGIC
# MAGIC **Tables Involved:**
# MAGIC `customers + orders + order_payments + order_reviews`
# MAGIC
# MAGIC **Purpose:**
# MAGIC To analyze customer behavior — how often they buy, how much they spend, and how satisfied they are.
# MAGIC
# MAGIC **Possible Analyses:**
# MAGIC
# MAGIC * Average Order Value (AOV) per customer
# MAGIC * Loyalty analysis: how many customers made repeat purchases
# MAGIC * Relationship between purchase frequency and satisfaction
# MAGIC * Identifying “high-value” or VIP customers
# MAGIC
# MAGIC 💡 This join can produce a new Gold table like `customer_performance` or `customer_lifetime_value`, helping to measure retention and lifetime metrics.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## **2️⃣ Seller-Centric Joins**
# MAGIC
# MAGIC **Tables Involved:**
# MAGIC `sellers + order_items + orders + order_reviews`
# MAGIC
# MAGIC **Purpose:**
# MAGIC To evaluate seller performance based on sales volume, delivery speed, and review scores.
# MAGIC
# MAGIC **Possible Analyses:**
# MAGIC
# MAGIC * Total sales and number of products sold per seller
# MAGIC * Average delivery time per seller
# MAGIC * Average review score per seller
# MAGIC * Identifying top-performing sellers by speed and satisfaction
# MAGIC
# MAGIC 💡 This join could form a `seller_performance` table for logistics or marketplace quality analysis.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ##  **3️⃣ Product or Category Analytics**
# MAGIC
# MAGIC **Tables Involved:**
# MAGIC `products + order_items + category_lookup + order_reviews`
# MAGIC
# MAGIC **Purpose:**
# MAGIC To understand which product categories are most profitable, popular, or well-rated.
# MAGIC
# MAGIC **Possible Analyses:**
# MAGIC
# MAGIC * Average sales value and quantity per category
# MAGIC * Average review score by category
# MAGIC * Top-selling or most-returned categories
# MAGIC * Price vs. rating correlation
# MAGIC
# MAGIC 💡 This join could build a `category_performance` table for marketing or assortment optimization.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## **4️⃣ Geolocation-Based Joins**
# MAGIC
# MAGIC **Tables Involved:**
# MAGIC `geolocation + customers + orders + sellers`
# MAGIC
# MAGIC **Purpose:**
# MAGIC To explore how geography affects delivery times and order density.
# MAGIC
# MAGIC **Possible Analyses:**
# MAGIC
# MAGIC * Average delivery time by city or state
# MAGIC * Regional order volume distribution
# MAGIC * Customer–seller distance vs. delivery performance
# MAGIC * Identifying fastest or slowest delivery regions
# MAGIC
# MAGIC 💡 This can produce a `regional_performance` or `logistics_efficiency` table, ideal for delivery optimization and route planning.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## **5️⃣ Payment Behavior Joins**
# MAGIC
# MAGIC **Tables Involved:**
# MAGIC `order_payments + orders + customers`
# MAGIC
# MAGIC **Purpose:**
# MAGIC To analyze how customers pay and how payment type affects spending patterns.
# MAGIC
# MAGIC **Possible Analyses:**
# MAGIC
# MAGIC * Average order value per payment type
# MAGIC * Payment preference by region or customer segment
# MAGIC * Relationship between installment count and order value
# MAGIC * Detecting high-ticket vs. low-ticket orders by payment type
# MAGIC
# MAGIC 💡 A potential table could be `payment_behavior`, supporting financial and marketing decisions.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## **6️⃣ Time-Series or Trend Analysis Joins**
# MAGIC
# MAGIC **Tables Involved:**
# MAGIC `orders (+ order_items)`
# MAGIC
# MAGIC **Purpose:**
# MAGIC To analyze sales over time, detect seasonal trends, and measure growth.
# MAGIC
# MAGIC **Possible Analyses:**
# MAGIC
# MAGIC * Monthly or weekly revenue trends
# MAGIC * Weekend vs. weekday purchase behavior
# MAGIC * Sales peaks during holidays or campaigns
# MAGIC * Forecasting future sales volume
# MAGIC
# MAGIC 💡 This could form a `sales_trend` or `time_performance` table, supporting forecasting and planning models.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## **7️⃣ Business-Level KPI Joins**
# MAGIC
# MAGIC **Tables Involved:**
# MAGIC (All Silver tables, especially: `orders`, `order_items`, `payments`, `reviews`, `geolocation`)
# MAGIC
# MAGIC **Purpose:**
# MAGIC To create a business metrics layer that tracks key performance indicators (KPIs).
# MAGIC
# MAGIC **Possible Metrics:**
# MAGIC
# MAGIC * On-time delivery rate
# MAGIC * Customer satisfaction index
# MAGIC * Revenue per seller or per region
# MAGIC * Delay impact ratio
# MAGIC
# MAGIC 💡 These joins can evolve into a `metrics_layer` or `KPI_table`, used for dashboards and executive reports.
# MAGIC
# MAGIC ---
# MAGIC
# MAGIC ## **Final Summary**
# MAGIC
# MAGIC > “Now that we’ve completed our analysis with the orders table, our work in the Gold Layer doesn’t stop here.
# MAGIC > From this point on, we can build new joins from different perspectives — customer, seller, product, region, payment, and time.
# MAGIC > Each of these joins gives us a new way to understand the business: who our best customers are, which sellers perform best, which regions deliver fastest, and what patterns drive satisfaction.
# MAGIC > This is how data stops being just a table and becomes a **strategic foundation for decision-making**.”
# MAGIC
# MAGIC ---

# COMMAND ----------

