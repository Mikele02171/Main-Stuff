DROP TABLE trafficbycat;

CREATE TABLE trafficbycat AS
SELECT category, COUNT(1) as count
FROM mytraffic INNER JOIN mydomains
ON (mytraffic.url = mydomains.url)
GROUP BY mydomains.category
ORDER BY count DESC
LIMIT 5;

INSERT OVERWRITE LOCAL DIRECTORY './task2c-out/'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
SELECT * FROM trafficbycat;
