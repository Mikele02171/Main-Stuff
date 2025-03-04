DROP TABLE myinput;
DROP TABLE wordcount;

CREATE TABLE myinput (line STRING);

-- Load the text from the local filesystem
LOAD DATA LOCAL INPATH './Input_data/1/'
  INTO TABLE myinput;

-- Table containing all the words in the myinput table
-- The difference between this table and myinput is that myinput stores each line as a separate row
-- whereas mywords stores each word as a separate row.


-- Create a table with the words cleaned and counted
CREATE TABLE wordcount AS
SELECT word, count(1) AS count
FROM (SELECT EXPLODE(SPLIT(LCASE(REGEXP_REPLACE(line,'[\\p{Punct},\\p{Cntrl}]','')),' ')) AS word
FROM myinput) splitwords
WHERE word NOT LIKE ""
GROUP BY word
ORDER BY count DESC, word ASC
LIMIT 10;

-- Dump the output to file
INSERT OVERWRITE LOCAL DIRECTORY './task2-out/'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
SELECT * FROM wordcount;
