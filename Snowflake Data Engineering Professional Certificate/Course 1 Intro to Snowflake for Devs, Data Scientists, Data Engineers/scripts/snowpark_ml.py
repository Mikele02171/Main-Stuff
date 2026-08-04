# Snowpark ML imports for XGBoost classification and preprocessing
# Co-authored with CoCo
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col
from snowflake.ml.modeling.preprocessing import LabelEncoder
import pandas as pd
from xgboost import XGBClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

## Creating the Dataset
month_days = [31,28,31,30,31,30,31,31,30,31,30,31]
pre = {}
for i,month_length in enumerate(month_days):
    month = i + 1
    for day in range(1,month_length + 1):
        if month == 1:
            if day % 7 == 1:
                pre[(month,day)] = 1
            else:
                pre[(month,day)] = 2
        elif month <= 11:
            pre[(month,day)] = (day - 1) % 7 + 1
        elif month == 12:
            pre[(month,day)] = 8

session = get_active_session()
print("Session connected successfully")
print(f"Warehouse: {session.get_current_warehouse()}")

# Create the dataframe from the dictionary and write to Snowflake
rows = [{"MONTH": k[0], "DAY": k[1], "NEIGHBORHOOD": v} for k, v in pre.items()]
pdf = pd.DataFrame(rows)
snowpark_df = session.create_dataframe(pdf)
snowpark_df.write.mode("overwrite").save_as_table("TEST_DATABASE.TEST_SCHEMA.DF_CLEAN")

# Read back from table
snowpark_df = session.table("TEST_DATABASE.TEST_SCHEMA.DF_CLEAN")

print(f"Row count: {snowpark_df.count()}")
snowpark_df.show(n=10)
snowpark_df.describe().show()
snowpark_df.group_by("NEIGHBORHOOD").count().show()

# Use LabelEncoder to encode NEIGHBORHOOD
le = LabelEncoder(input_cols=["NEIGHBORHOOD"], output_cols=["NEIGHBORHOOD2"], drop_input_cols=True)
fitted = le.fit(snowpark_df.select("NEIGHBORHOOD"))
snowpark_df_prepared = fitted.transform(snowpark_df)

snowpark_df_prepared.show()

# Convert to pandas for local XGBoost training (small dataset)
train_pdf = snowpark_df_prepared.to_pandas()

# Split the data
X = train_pdf[["MONTH", "DAY"]]
y = train_pdf["NEIGHBORHOOD2"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1, random_state=42)

# Save train/test to Snowflake
train_snowpark_df = session.create_dataframe(pd.concat([X_train, y_train], axis=1))
train_snowpark_df.write.mode("overwrite").save_as_table("TEST_DATABASE.TEST_SCHEMA.DF_CLEAN_TRAIN")

test_snowpark_df = session.create_dataframe(pd.concat([X_test, y_test], axis=1))
test_snowpark_df.write.mode("overwrite").save_as_table("TEST_DATABASE.TEST_SCHEMA.DF_CLEAN_TEST")

# Train XGBoost locally
xgboost_model = XGBClassifier(use_label_encoder=False, eval_metric="mlogloss")
xgboost_model.fit(X_train, y_train)

# Check the accuracy
y_pred = xgboost_model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
print("Accuracy: %.2f%%" % (accuracy * 100.0))
