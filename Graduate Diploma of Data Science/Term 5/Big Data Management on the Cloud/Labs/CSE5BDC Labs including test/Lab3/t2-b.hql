DROP TABLE fbtraffic;

CREATE TABLE fbtraffic AS
SELECT * FROM mytraffic
WHERE url = 'www.Facebook.com'
  AND time > unix_timestamp('2014-02-14 00:00:00')
  AND time < unix_timestamp('2014-02-15 00:00:00');

INSERT OVERWRITE LOCAL DIRECTORY './task2b-out/'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
SELECT * FROM fbtraffic;
