-- In this task you will need to use a special type of join that
-- is called a cartesian product. By default Hive does not allow
-- this, so we need to use the two lines below to tell Hive to 
-- allow us to use the cartesian product.

--set hive.mapred.mode=nonstrict;
--set hive.strict.checks.cartesian.product=false;

-- Don't forget to drop the tables you create here
DROP TABLE ipcountries;
DROP TABLE fbtrafficcountries;
DROP TABLE fbregioncounts;

-- Task 2D step 1
-- Create a table with two columns - a list of ip addresses with
-- their associated region names.
CREATE TABLE ipcountries AS
SELECT myips.ipAddress AS ipAddress, myregions.regionName AS regionName
FROM myips JOIN myregions
WHERE myips.intAddress >= myregions.intMin
  AND myips.intAddress <= myregions.intMax;


-- Task 2D step 2
CREATE TABLE fbtrafficcountries AS
SELECT ipcountries.regionName, fbtraffic.time
FROM ipcountries INNER JOIN fbtraffic USING ipAddress;



-- Task 2D step 3
-- Create a table which contains the number of visits to facebook from
-- each country between the given dates.
CREATE TABLE fbregioncounts AS
SELECT ipcountries.regionName, count(*) as count
FROM fbtrafficcountries
GROUP BY ipcountries.regionName
ORDER BY count;



-- Task 2D step 4
-- Write the contents of the table created in step 4 to the directory './task2d-out/'
INSERT OVERWRITE LOCAL DIRECTORY './task2d-out/'
ROW FORMAT
DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
SELECT * FROM fbregioncounts;


