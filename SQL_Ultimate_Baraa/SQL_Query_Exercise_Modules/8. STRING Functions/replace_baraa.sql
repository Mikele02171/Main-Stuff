--Remove dashes (-) from a phone number
SELECT 
'123-456-7890' as phone,
REPLACE('123-456-7890','-','') as clean_phone;

--Replace File Extence from txt to csv
SELECT
'report.txt' as old_filename,
REPLACE('report.txt','.txt','.csv') as new_filename;