DROP TABLE myinput;
DROP TABLE includewords;
DROP TABLE mywords;
DROP TABLE includejoin;

CREATE TABLE myinput (line STRING);
CREATE TABLE includewords (line STRING);

-- Load the text from the local filesystem
LOAD DATA LOCAL INPATH './Input_data/1/'
  INTO TABLE myinput;

LOAD DATA LOCAL INPATH './Input_data/4/includelist.txt'
  INTO TABLE includewords;

-- Table containing all the words in the myinput table
-- The difference between this table and myinput is that myinput stores each line as a separate row
-- whereas mywords stores each word as a separate row.
CREATE TABLE mywords AS
SELECT EXPLODE(SPLIT(LCASE(REGEXP_REPLACE(line,'[\\p{Punct},\\p{Cntrl}]','')),' ')) AS word
FROM myinput;

CREATE TABLE includejoin AS
SELECT mywords.word AS mword, includewords.line AS sword
FROM  mywords INNER JOIN includewords
ON (mywords.word = includewords.line)
WHERE mywords.word NOT LIKE "";

CREATE TABLE includelistOut AS
SELECT mword, COUNT(1) AS count FROM includejoin
GROUP BY mword
ORDER BY count DESC, mword ASC
LIMIT 10;

-- Dump the output to file
INSERT OVERWRITE LOCAL DIRECTORY './task4-out/'
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
  SELECT * FROM includelistOut;
