# Databricks notebook source
# MAGIC %md
# MAGIC # Select Catalog

# COMMAND ----------

# MAGIC %sql
# MAGIC USE CATALOG workspace;

# COMMAND ----------

# MAGIC %md
# MAGIC # Create Lakehouse Schemas

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE SCHEMA IF NOT EXISTS bronze
# MAGIC COMMENT 'Bronze layer: raw ingested data';
# MAGIC
# MAGIC CREATE SCHEMA IF NOT EXISTS silver
# MAGIC COMMENT 'Silver layer: cleaned and transformed data';
# MAGIC
# MAGIC CREATE SCHEMA IF NOT EXISTS gold
# MAGIC COMMENT 'Gold layer: business-ready data';

# COMMAND ----------

# MAGIC %md
# MAGIC #Create Volume
# MAGIC

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE VOLUME IF NOT EXISTS workspace.bronze.raw_sources
# MAGIC COMMENT 'Volume for raw source files (CSV)';