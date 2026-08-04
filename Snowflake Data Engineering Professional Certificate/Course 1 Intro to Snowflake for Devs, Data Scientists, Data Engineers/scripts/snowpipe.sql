CREATE OR REPLACE STORAGE INTEGRATION S3_role_integration
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = "arn:aws:iam::849350360261:role/snowflake_role_snowpipe"
STORAGE_ALLOWED_LOCATIONS = ("s3://intro-to-snowflake-snowpipe/");

DESCRIBE INTEGRATION S3_role_integration;
CREATE OR REPLACE DATABASE S3_db;
CREATE OR REPLACE TABLE s3_table(food STRING, taste INT);

USE SCHEMA s3_db.public;
CREATE OR REPLACE STAGE s3_stage 
url = ('s3://intro-to-snowflake-snowpipe/')
storage_integration = S3_role_integration;


SHOW STAGES;

-- AT THIS STAGE REQURIES AN AWS ACCOUNT TO PROCEED THIS
LIST @S3_stage;
SELECT $1,$2 FROM @S3_stage;

USE WAREHOUSE COMPUTE_WH;

CREATE PIPE S3_db.public.S3_pipe AUTO_INGEST = TRUE as
COPY INTO S3_db.public.S3_table 
FROM @S3_db.public.S3_stage;

SHOW PIPES;
DESCRIBE PIPE S3_db.public.S3_pipe;

ALTER PIPE S3_db_public.S3_pipe SET PIPE_EXECUTION_PAUSED = TRUE;
DROP PIPE S3_pipe;

SHOW PIPES;
