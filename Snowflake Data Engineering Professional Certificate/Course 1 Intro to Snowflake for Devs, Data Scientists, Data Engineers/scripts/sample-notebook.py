# Execute SQL from a Snowpark session in a Python file
# Co-authored with CoCo
from snowflake.snowpark.context import get_active_session

session = get_active_session()
result = session.sql("SELECT CURRENT_DATABASE(), CURRENT_ROLE(), CURRENT_WAREHOUSE()").collect()
print(result)
