# Import the Snowflake Session class for connecting to Snowflake
# FIX: Import Session from snowpark, NOT the connector
from snowflake.snowpark import Session
from snowflake.snowpark.functions import col
import os

# Connection parameters - same pattern as above 
# In production, use secret management rather than environment variables
connection_params = {
    "account": os.environ["SNOWFLAKE_ACCOUNT"], ## MUST CHANGE TO YOUR ACCOUNT
    "user": "xxxxxxxx", ## MUST CHANGE TO YOUR USERNAME
    "password": "xoxoxoxox", ## MUST CHANGE TO YOUR PASSWORD
    "role": "ACCOUNTADMIN",
    "warehouse": "TASTY_DE_WH",
    "database": "TASTY_BYTES",
    "schema": "analytics"
}

# Establish the Snowflake session
session = Session.builder.configs(connection_params).create()

# Reference the menu table as a a Snowpark DataFrame
df = session.table("TASTY_BYTES_SAMPLE_DATA.raw_pos.menu")

# Filter for a specific truck brand and display results
df.filter(col("TRUCK_BRAND_NAME") == "Freezing Point").show()