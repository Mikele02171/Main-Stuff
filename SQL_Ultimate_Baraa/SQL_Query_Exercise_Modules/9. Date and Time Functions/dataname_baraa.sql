USE SalesDB;
SELECT 
OrderID,
CreationTime,
--DateName (Strings)
DATENAME(month, CreationTime) Month_dn,
DATENAME(weekday, CreationTime) weekday_dn,

--DateName (Int)
DATENAME(day, CreationTime) day_dn,
DATENAME(year, CreationTime) year_dn,

--Datepart
DATEPART(year,CreationTime) Year_dp,
DATEPART(month,CreationTime) Month_dp,
DATEPART(day,CreationTime) Day_dp,
DATEPART(hour,CreationTime) Hour_dp,
DATEPART(quarter,CreationTime) Quarter_dp,
DATEPART(Week,CreationTime) Week_dp,
YEAR(CreationTime) Year,
Month(CreationTime) Month,
DAY(CreationTime) Day
FROM Sales.Orders