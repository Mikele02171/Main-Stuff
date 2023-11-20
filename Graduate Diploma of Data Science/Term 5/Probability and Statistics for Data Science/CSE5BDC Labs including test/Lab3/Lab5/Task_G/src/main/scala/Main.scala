import org.apache.spark.sql._
import org.apache.spark.sql.types._

object Main {
  private val spark = SparkSession.builder.appName("Lab 5, task G application").getOrCreate()

  def main(args: Array[String]) {
    val sc = spark.sparkContext;

    // *** Start of application code ***

    // This application calculates the average amount of hours people work
    // in each occupation according to the census data.

    // 1. Load the data, and split the lines into fields
    val censusLines = sc.textFile("lab_5/Input_data/census.txt")
    val censusSplit = censusLines.map(_.split(", "))

    // 2. Remove records where the occupation is unknown
    val knownOccupation = censusSplit.filter(_(6) != "?")

    // 3. Turn records into pairs where the key is the occupation, and
    //    the value is a tuple containing (hours-per-week, 1)
    val pairs = knownOccupation.map(r => (r(6), (r(12).toFloat, 1)))

    // 4. Sum values within each occupation
    val summed = pairs.reduceByKey((a, b) => (a._1 + b._1, a._2 + b._2))

    // 5. Calculate average hours worked per occupation
    val averages = summed.map(r => (r._2._1 / r._2._2, r._1))

    // 6. Sort the occupations in descending order of hours worked
    val sorted = averages.sortByKey(false)

    // 7. Collect the results into a Scala array
    // !!! TODO: Collect the `sorted` RDD into an array called `results`
    val results = sorted.collect


    // 8. Print out the results
    println("****** RESULTS ******")
    results.foreach(println)
    println("*********************")

    // *** End of application code ***

    spark.stop()
  }
}
