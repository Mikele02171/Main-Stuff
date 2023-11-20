// CSE3BDC/CSE5BDC Lab 06 - Spark DataFrames and Datasets
/*******************************************************************************
 * Exercise 1
 * Write a case class called Fruit which corresponds to the data in
 * Lab6/Input_data/TaskA/fruit.csv
 */
// TODO: Write your code here
case class Fruit(name: String, price: Double, stock: Int)


/*******************************************************************************
 * Exercise 2
 * Convert fridgeParquetDF into a Dataset and show the first 10 rows.
 */
// TODO: Write your code here
val fridgeParquetDS = fridgeParquetDF.as[Fridge]
fridgeParquetDS.show(10)// TODO
/*+---------------+-----------+----------+-------------+
|          brand|    country|     model|   efficiency|
+---------------+-----------+----------+-------------+
|          KOXKA|      Spain|     M61M1|         11.1|
|          KOXKA|      Spain|     M62M1|         11.1|
|          KOXKA|      Spain|     M63M1|         11.1|
|HUSSMANN IMPACT|New Zealand|C2.2NXLE-M|13.6513844757|
|HUSSMANN IMPACT|New Zealand|  C2.2NXLE|10.7959605233|
|HUSSMANN IMPACT|New Zealand|      C6HE|13.3664104882|
|HUSSMANN IMPACT|New Zealand|      C6LE|13.3664104882|
|HUSSMANN IMPACT|New Zealand|      C6HE|11.5788878843|
|HUSSMANN IMPACT|New Zealand|      C6LE|11.5788878843|
|HUSSMANN IMPACT|New Zealand|       D5E| 9.7306346827|
+---------------+-----------+----------+-------------+
only showing top 10 rows */




/*******************************************************************************
 * Exercise 3
 * Using DataFrames, find the full name of every country in Oceania (continent “OC”).
 * Show the first 10 country names in ascending alphabetical order.
 */
// TODO: Write your code here
val continentDF = spark.read.json("Lab6/Input_data/TaskC/continent.json")
val namesDF = spark.read.json("Lab6/Input_data/TaskC/names.json")
continentDF.
  filter($"continent" === "OC").
  select($"countryCode").
  join(namesDF, "countryCode").
  orderBy($"name".asc).
  show(10)
/*+-----------+----------------+
|countryCode|            name|
+-----------+----------------+
|         AS|  American Samoa|
|         AU|       Australia|
|         CK|    Cook Islands|
|         TL|      East Timor|
|         FJ|            Fiji|
|         PF|French Polynesia|
|         GU|            Guam|
|         KI|        Kiribati|
|         MH|Marshall Islands|
|         FM|      Micronesia|
+-----------+----------------+
only showing top 10 rows */






/*******************************************************************************
 * Exercise 4
 * Calculate the average refrigerator efficiency for each brand. Order the results
 * in descending order of average efficiency and show the first 5 rows.
 */
// TODO: Write your code here
fridgeDF.groupBy("brand").avg("efficiency").
  orderBy($"avg(efficiency)".desc).show(5)
/*+--------------------+------------------+
|               brand|   avg(efficiency)|
+--------------------+------------------+
|Minus Forty Techn...|     34.5190774644|
|             INFRICO|24.447894024066667|
|  Jono Refrigeration|     22.2967678746|
|              Imbera| 21.74823766813333|
|  TRUE MANUFACTURING|20.504535147400002|
+--------------------+------------------+
only showing top 5 rows */


/*******************************************************************************
 * Exercise 5
 * Redo Exercise 3 using spark.sql instead of the DataFrames API.
 */
// TODO: Write your code here
spark.read.json("Lab6/Input_data/TaskC/continent.json").createOrReplaceTempView("continents")
spark.read.json("Lab6/Input_data/TaskC/names.json").createOrReplaceTempView("names")
spark.sql("""SELECT name FROM
  continents INNER JOIN names
  ON continents.countryCode = names.countryCode
  WHERE continent = 'OC'
  ORDER BY name ASC""").show(10)

/*+----------------+
|            name|
+----------------+
|  American Samoa|
|       Australia|
|    Cook Islands|
|      East Timor|
|            Fiji|
|French Polynesia|
|            Guam|
|        Kiribati|
|Marshall Islands|
|      Micronesia|
+----------------+
only showing top 10 rows*/



/*******************************************************************************
 * Exercise 6
 * Using toPercentageUdf, add a new column to fractionDF called “percentage”
 * containing the fraction as a formatted percentage string and drop the original
 * fraction column.
 */
// TODO: Write your code here
val percentageDF = fractionDF.
  withColumn("percentage", toPercentageUdf($"fraction")).
  drop("fraction") // TODO
percentageDF.show()
// TODO: Copy and paste the result here
/*+---------+-----+----------+
|continent|count|percentage|
+---------+-----+----------+
|       NA|   41|    16.40%|
|       SA|   14|     5.60%|
|       AS|   52|    20.80%|
|       AN|    5|     2.00%|
|       OC|   27|    10.80%|
|       EU|   53|    21.20%|
|       AF|   58|    23.20%|
+---------+-----+----------+*/




/*
 * SCRATCHPAD
 * Play around, and save any helpful Scala/Spark commands below this section
 */



