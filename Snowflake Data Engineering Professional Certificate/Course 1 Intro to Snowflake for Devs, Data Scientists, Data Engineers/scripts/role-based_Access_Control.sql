-- Role-based access control examples with privilege grants
-- Co-authored with CoCo
USE ROLE accountadmin;

-- functional roles
CREATE ROLE tasty_de;

SHOW GRANTS TO ROLE tasty_de;
SHOW GRANTS TO ROLE accountadmin;
GRANT ROLE tasty_de TO USER mikeleen0217;
USE ROLE tasty_de;
CREATE WAREHOUSE tasty_de_test;
USE ROLE accountadmin;

-- privilege grants
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE tasty_de;
SHOW GRANTS TO ROLE tasty_de;

USE ROLE tasty_de;
CREATE WAREHOUSE tasty_de_test;
SHOW GRANTS TO ROLE securityadmin;
SHOW GRANTS TO ROLE useradmin;
SHOW GRANTS TO ROLE sysadmin;
SHOW GRANTS TO ROLE public;

-- ASSESSMENT 
USE ROLE accountadmin;
CREATE ROLE tasty_role;

SHOW GRANTS TO ROLE tasty_role;

GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE tasty_role;
SHOW GRANTS TO ROLE tasty_role;

SELECT CURRENT_USER;
GRANT ROLE tasty_role TO USER MIKELEEN0217;
USE ROLE tasty_role;
CREATE WAREHOUSE tasty_test_wh;
SHOW GRANTS TO ROLE tasty_role;

USE ROLE accountadmin;
SHOW GRANTS TO USER mikeleen0217;
SHOW GRANTS TO ROLE USERADMIN;